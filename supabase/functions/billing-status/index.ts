// supabase/functions/billing-status/index.ts
//
// TECH_SPEC_v1.2.md 6.3: { is_pro, plan, expires_at, free_checks_left }

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const FREE_CHECKS_LIMIT = 2;

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST" && req.method !== "GET") {
    return jsonResponse({ error: "method_not_allowed" }, 405);
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return jsonResponse({ error: "unauthorized" }, 401);

  const { data: userData, error: userError } = await supabase.auth.getUser(
    authHeader.replace("Bearer ", ""),
  );
  if (userError || !userData.user) {
    return jsonResponse({ error: "unauthorized" }, 401);
  }
  const user = userData.user;

  const { data: profile, error: profileError } = await supabase
    .from("profiles")
    .select("free_checks_used")
    .eq("id", user.id)
    .single();
  if (profileError || !profile) {
    return jsonResponse({ error: "profile_not_found" }, 404);
  }

  const { data: sub } = await supabase
    .from("subscriptions")
    .select("plan, status, expires_at, grace_expires_at")
    .eq("user_id", user.id)
    .in("status", ["active", "grace"])
    .maybeSingle();

  const now = new Date();
  const isPro = !!sub && (
    (sub.status === "active" && !!sub.expires_at && new Date(sub.expires_at) >= now) ||
    (sub.status === "grace" && !!sub.grace_expires_at && new Date(sub.grace_expires_at) >= now)
  );

  return jsonResponse({
    is_pro: isPro,
    plan: sub?.plan ?? null,
    status: sub?.status ?? null,
    expires_at: sub?.expires_at ?? null,
    grace_expires_at: sub?.grace_expires_at ?? null,
    free_checks_left: Math.max(0, FREE_CHECKS_LIMIT - profile.free_checks_used),
  });
});
