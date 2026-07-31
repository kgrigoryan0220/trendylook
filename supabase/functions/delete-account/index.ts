// supabase/functions/delete-account/index.ts
//
// GDPR right-to-erasure (TECH_SPEC_v1.2.md 6.2, 6.6, 13):
// удаляет фото пользователя из Storage, затем сам auth.users —
// profiles/subscriptions/checks удаляются каскадно через FK ON DELETE CASCADE.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
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
  const userId = userData.user.id;

  // 1. Удаляем все фото пользователя из приватного bucket look-photos
  const { data: files, error: listError } = await supabase.storage
    .from("look-photos")
    .list(userId, { limit: 1000 });

  if (listError) {
    return jsonResponse({ error: "storage_list_failed" }, 500);
  }

  if (files && files.length > 0) {
    const paths = files.map((f) => `${userId}/${f.name}`);
    const { error: removeError } = await supabase.storage
      .from("look-photos")
      .remove(paths);
    if (removeError) {
      return jsonResponse({ error: "storage_delete_failed" }, 500);
    }
  }

  // 2. Удаляем пользователя — profiles/subscriptions/checks каскадно уходят по FK
  const { error: deleteUserError } = await supabase.auth.admin.deleteUser(userId);
  if (deleteUserError) {
    return jsonResponse({ error: "delete_failed" }, 500);
  }

  return jsonResponse({ deleted: true });
});
