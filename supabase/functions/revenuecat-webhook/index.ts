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

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

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
  plan: "weekly" | "halfyear",
  expiresAt: string | null,
  revenuecatId: string | undefined,
) {
  const { data: existing } = await supabase
    .from("subscriptions")
    .select("id")
    .eq("user_id", userId)
    .in("status", ["active", "grace"])
    .maybeSingle();

  if (existing) {
    await supabase
      .from("subscriptions")
      .update({
        plan,
        status: "active",
        expires_at: expiresAt,
        grace_expires_at: null,
        revenuecat_id: revenuecatId,
        updated_at: new Date().toISOString(),
      })
      .eq("id", existing.id);
  } else {
    await supabase.from("subscriptions").insert({
      user_id: userId,
      plan,
      status: "active",
      expires_at: expiresAt,
      revenuecat_id: revenuecatId,
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
    const plan = event.product_id ? PRODUCT_TO_PLAN[event.product_id] : undefined;
    if (!plan) {
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
