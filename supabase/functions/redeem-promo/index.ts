// supabase/functions/redeem-promo/index.ts
//
// PROMO_CODES_PLAN.md, разд. 6: активация промокода -> grant Pro через
// RevenueCat Promotional Entitlement API. Атомарная резервация слота
// делается в Postgres (reserve_promo_redemption, FOR UPDATE), т.к.
// удерживать транзакцию открытой поперёк внешнего HTTP-вызова к RC нельзя —
// при неудаче RC резервация откатывается через release_promo_redemption.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const RC_TIMEOUT_MS = 15_000;

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

// Сообщения из reserve_promo_redemption (RAISE EXCEPTION 'code'...) ->
// HTTP-код и error-код ответа (PROMO_CODES_PLAN.md, разд. 6.1).
const RESERVE_ERROR_STATUS: Record<string, number> = {
  code_not_found: 404,
  code_expired: 410,
  code_exhausted: 409,
  already_redeemed: 409,
};

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return jsonResponse({ error: "method_not_allowed" }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const rcSecretKey = Deno.env.get("REVENUECAT_SECRET_API_KEY");
  const entitlementId = Deno.env.get("REVENUECAT_ENTITLEMENT_ID");

  // Проверяем конфигурацию ДО резервации слота в БД — иначе пришлось бы
  // тут же откатывать её через release_promo_redemption.
  if (!rcSecretKey || !entitlementId) {
    return jsonResponse(
      { error: "server_misconfigured", message: "RevenueCat promo secrets are not set" },
      500,
    );
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey);

  // 1. Auth
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return jsonResponse({ error: "unauthorized" }, 401);

  const { data: userData, error: userError } = await supabase.auth.getUser(
    authHeader.replace("Bearer ", ""),
  );
  if (userError || !userData.user) {
    return jsonResponse({ error: "unauthorized" }, 401);
  }
  const user = userData.user;

  // 2. Parse + validate input
  let body: { code?: string };
  try {
    body = await req.json();
  } catch {
    return jsonResponse({ error: "invalid_body" }, 400);
  }

  const rawCode = body.code;
  if (!rawCode || typeof rawCode !== "string" || rawCode.trim().length === 0) {
    return jsonResponse({ error: "invalid_code" }, 400);
  }

  // 3. Атомарная резервация (лочит promo_codes, валидирует, сразу
  // инкрементирует redemption_count и создаёт запись — см. миграцию).
  const { data: reserveRows, error: reserveError } = await supabase.rpc(
    "reserve_promo_redemption",
    { p_code: rawCode, p_user_id: user.id },
  );

  if (reserveError) {
    const status = RESERVE_ERROR_STATUS[reserveError.message];
    if (status) {
      return jsonResponse({ error: reserveError.message }, status);
    }
    console.error("reserve_promo_redemption failed:", reserveError.message);
    return jsonResponse({ error: "redeem_failed" }, 500);
  }

  const reservation = reserveRows?.[0];
  if (!reservation) {
    return jsonResponse({ error: "redeem_failed" }, 500);
  }
  const { redemption_id: redemptionId, granted_expires_at: grantedExpiresAt, extended } =
    reservation;

  // 4. Grant Promotional Entitlement в RevenueCat — app_user_id уже
  // совпадает с Supabase user.id (Purchases.logIn на клиенте).
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), RC_TIMEOUT_MS);
  let rcOk = false;
  try {
    const rcResponse = await fetch(
      `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(user.id)}/entitlements/${
        encodeURIComponent(entitlementId)
      }/promotional`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${rcSecretKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          end_time_ms: new Date(grantedExpiresAt).getTime(),
        }),
        signal: controller.signal,
      },
    );
    rcOk = rcResponse.ok;
    if (!rcOk) {
      console.error(`RevenueCat grant promotional failed: ${rcResponse.status}`);
    }
  } catch (e) {
    console.error("RevenueCat grant promotional request failed:", e);
  } finally {
    clearTimeout(timeout);
  }

  if (!rcOk) {
    // Откатываем резервацию — слот и лимит кода освобождаются, пользователь
    // может повторить попытку.
    const { error: releaseError } = await supabase.rpc("release_promo_redemption", {
      p_redemption_id: redemptionId,
    });
    if (releaseError) {
      console.error("release_promo_redemption failed:", releaseError.message);
    }
    return jsonResponse({ error: "revenuecat_error" }, 502);
  }

  // 5. Подтверждаем резервацию (best-effort, только для отладки — не
  // блокирует ответ пользователю при неудаче).
  const { error: confirmError } = await supabase.rpc("confirm_promo_redemption", {
    p_redemption_id: redemptionId,
    p_revenuecat_request_id: null,
  });
  if (confirmError) {
    console.error("confirm_promo_redemption failed:", confirmError.message);
  }

  // subscriptions обновится асинхронно через revenuecat-webhook (тот же
  // путь, что и для платных покупок) — клиент рефрешит billing-status
  // после этого ответа.
  return jsonResponse({
    success: true,
    expires_at: new Date(grantedExpiresAt).toISOString(),
    extended,
  });
});
