// supabase/functions/revenuecat-webhook/index.ts
//
// PAY-04 (TECH_SPEC_v1.2.md 5.5, 6.5): RevenueCat webhook -> обновление subscriptions.
// Не проверяется через Supabase JWT (вызывается сервером RevenueCat) — аутентификация
// через статический Authorization-заголовок, заданный в RevenueCat Dashboard.
//
// Ожидание: клиент вызывает Purchases.logIn(supabase user.id), поэтому
// event.app_user_id в вебхуке совпадает с profiles.id.
//
// grace-период (PAY-05) НЕ выставляется этим вебхуком напрямую — переход
// active -> grace / grace -> expired выполняется по расписанию через pg_cron
// (см. миграцию grace_period_scheduler), а также лениво проверяется в analyze-look.
//
// PROMO_CODES_PLAN.md, разд. 5.4: промокоды выдаются через RevenueCat Grant
// Promotional Entitlement API (см. redeem-promo) — RC шлёт такой грант сюда как
// обычное активное событие (NON_RENEWING_PURCHASE), но product_id у него синтетический
// (rc_promo_...) и никогда не совпадает с реальным товаром из PRODUCT_TO_PLAN —
// такой случай трактуется как plan='promo'/source='promo', а не игнорируется.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

type Plan = "weekly" | "halfyear" | "promo";
type Source = "revenuecat" | "promo";

const PRODUCT_TO_PLAN: Record<string, "weekly" | "halfyear"> = {
  weekly_unlimited: "weekly",
  halfyear_unlimited: "halfyear",
};

const ACTIVE_EVENT_TYPES = new Set([
  "INITIAL_PURCHASE",
  "RENEWAL",
  "PRODUCT_CHANGE",
  "UNCANCELLATION",
  "NON_RENEWING_PURCHASE",
  "TRANSFER",
]);

const EXPIRE_EVENT_TYPES = new Set(["EXPIRATION"]);

interface RevenueCatEvent {
  type: string;
  app_user_id: string;
  product_id?: string;
  expiration_at_ms?: number | null;
  original_transaction_id?: string;
  transaction_id?: string;
}

async function upsertActiveSubscription(
  // deno-lint-ignore no-explicit-any
  supabase: any,
  userId: string,
  plan: Plan,
  source: Source,
  expiresAt: string | null,
  revenuecatId: string | undefined,
) {
  const { data: existing } = await supabase
    .from("subscriptions")
    .select("id, expires_at")
    .eq("user_id", userId)
    .in("status", ["active", "grace"])
    .maybeSingle();

  // Защита от регресса даты: не откатываем expires_at назад, если новое
  // событие (например, повторный promo-grant или гонка вебхуков из-за
  // внешней доставки) короче уже действующего срока (PROMO_CODES_PLAN.md 5.4).
  let finalExpiresAt = expiresAt;
  if (existing?.expires_at && expiresAt) {
    finalExpiresAt = new Date(existing.expires_at) > new Date(expiresAt)
      ? existing.expires_at
      : expiresAt;
  }

  if (existing) {
    await supabase
      .from("subscriptions")
      .update({
        plan,
        status: "active",
        expires_at: finalExpiresAt,
        grace_expires_at: null,
        revenuecat_id: revenuecatId,
        source,
        updated_at: new Date().toISOString(),
      })
      .eq("id", existing.id);
  } else {
    await supabase.from("subscriptions").insert({
      user_id: userId,
      plan,
      status: "active",
      expires_at: finalExpiresAt,
      revenuecat_id: revenuecatId,
      source,
    });
  }
}

async function expireSubscription(
  // deno-lint-ignore no-explicit-any
  supabase: any,
  userId: string,
) {
  await supabase
    .from("subscriptions")
    .update({ status: "expired", updated_at: new Date().toISOString() })
    .eq("user_id", userId)
    .in("status", ["active", "grace"]);
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return jsonResponse({ error: "method_not_allowed" }, 405);
  }

  const expectedSecret = Deno.env.get("REVENUECAT_WEBHOOK_SECRET");
  const authHeader = req.headers.get("Authorization");
  if (!expectedSecret || authHeader !== `Bearer ${expectedSecret}`) {
    return jsonResponse({ error: "unauthorized" }, 401);
  }

  let payload: { event?: RevenueCatEvent };
  try {
    payload = await req.json();
  } catch {
    return jsonResponse({ error: "invalid_body" }, 400);
  }

  const event = payload.event;
  if (!event || !event.app_user_id || !event.type) {
    return jsonResponse({ error: "invalid_body" }, 400);
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  if (ACTIVE_EVENT_TYPES.has(event.type)) {
    const knownPlan = event.product_id ? PRODUCT_TO_PLAN[event.product_id] : undefined;

    let plan: Plan;
    let source: Source;
    if (knownPlan) {
      plan = knownPlan;
      source = "revenuecat";
    } else if (event.expiration_at_ms) {
      // Нет известного product_id, но есть срок действия — трактуем как
      // promotional grant от redeem-promo.
      plan = "promo";
      source = "promo";
    } else {
      console.error(`Unknown product_id in RevenueCat event: ${event.product_id}`);
      return jsonResponse({ received: true, ignored: "unknown_product_id" });
    }

    const expiresAt = event.expiration_at_ms
      ? new Date(event.expiration_at_ms).toISOString()
      : null;
    await upsertActiveSubscription(
      supabase,
      event.app_user_id,
      plan,
      source,
      expiresAt,
      event.original_transaction_id ?? event.transaction_id,
    );
    return jsonResponse({ received: true });
  }

  if (EXPIRE_EVENT_TYPES.has(event.type)) {
    await expireSubscription(supabase, event.app_user_id);
    return jsonResponse({ received: true });
  }

  // CANCELLATION, BILLING_ISSUE и прочие события не меняют entitlement напрямую —
  // подписка остаётся активной до фактического истечения (EXPIRATION) либо до
  // срабатывания pg_cron grace-переключателя.
  return jsonResponse({ received: true, ignored: event.type });
});
