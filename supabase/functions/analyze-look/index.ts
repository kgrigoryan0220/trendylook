// supabase/functions/analyze-look/index.ts
//
// CHECK-01..08, PAY-03, PAY-05 (TECH_SPEC_v1.2.md 5.2, 5.5, 6.5)
// Проверка лимита/entitlement -> OpenAI Vision -> сохранение результата.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import OpenAI from "https://esm.sh/openai@4";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...corsHeaders },
  });
}

const FREE_CHECKS_LIMIT = 2;
const RATE_LIMIT_PER_HOUR = 10;
const ANALYSIS_TIMEOUT_MS = 30_000;
const SIGNED_URL_TTL_SECONDS = 300;

const CATEGORY_NAMES = [
  "color_palette",
  "silhouette",
  "accessories",
  "footwear",
] as const;

const LOOK_ANALYSIS_SCHEMA = {
  name: "look_analysis",
  strict: true,
  schema: {
    type: "object",
    additionalProperties: false,
    properties: {
      trend_score: { type: "integer", minimum: 0, maximum: 100 },
      trend_label: {
        type: "string",
        enum: ["Needs Work", "Getting There", "Trendy", "Icon Status"],
      },
      categories: {
        type: "array",
        items: {
          type: "object",
          additionalProperties: false,
          properties: {
            name: { type: "string", enum: CATEGORY_NAMES as unknown as string[] },
            score: { type: "integer", minimum: 0, maximum: 100 },
            comment: { type: "string" },
          },
          required: ["name", "score", "comment"],
        },
        minItems: 4,
        maxItems: 4,
      },
      recommendations: {
        type: "array",
        items: {
          type: "object",
          additionalProperties: false,
          properties: {
            priority: { type: "integer", minimum: 1 },
            title: { type: "string" },
            description: { type: "string" },
            category: { type: "string", enum: CATEGORY_NAMES as unknown as string[] },
          },
          required: ["priority", "title", "description", "category"],
        },
        minItems: 3,
        maxItems: 5,
      },
      trend_tags: {
        type: "array",
        items: { type: "string" },
        minItems: 1,
        maxItems: 6,
      },
      summary: { type: "string" },
    },
    required: [
      "trend_score",
      "trend_label",
      "categories",
      "recommendations",
      "trend_tags",
      "summary",
    ],
  },
};

function systemPrompt(locale: string): string {
  const lang = locale === "en" ? "English" : "Russian";
  return `Ты — AI-стилист приложения Trendy Look. Анализируй фото outfit пользователя.

Правила:
- Оцени трендовость образа по шкале 0-100.
- Учитывай актуальные тренды 2025-2026: quiet luxury, mob wife, office siren, coquette, gorpcore, etc.
- Дай 3-5 конкретных, actionable рекомендаций по улучшению.
- Оцени категории: color_palette, silhouette, accessories, footwear.
- Учитывай сезон по дате анализа, не спрашивай пользователя об этом явно.
- Будь конструктивным и дружелюбным, без токсичности.
- НЕ комментируй вес, телосложение, внешность лица.
- НЕ используй дискриминационные формулировки.
- Отвечай на языке: ${lang}.
- Верни ответ строго по предоставленной JSON-схеме.`;
}

function trendLabelForScore(score: number): string {
  if (score >= 80) return "Icon Status";
  if (score >= 60) return "Trendy";
  if (score >= 40) return "Getting There";
  return "Needs Work";
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return jsonResponse({ error: "method_not_allowed" }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const openaiApiKey = Deno.env.get("OPENAI_API_KEY");

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
  let body: { image_path?: string; locale?: string };
  try {
    body = await req.json();
  } catch {
    return jsonResponse({ error: "invalid_body" }, 400);
  }

  const imagePath = body.image_path;
  const locale = body.locale ?? "ru";
  if (!imagePath || typeof imagePath !== "string") {
    return jsonResponse({ error: "invalid_body", message: "image_path is required" }, 400);
  }
  if (!imagePath.startsWith(`${user.id}/`)) {
    return jsonResponse({ error: "forbidden" }, 403);
  }

  // 3. Check entitlement (free checks / active / grace subscription — PAY-05)
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
    .select("status, expires_at, grace_expires_at")
    .eq("user_id", user.id)
    .in("status", ["active", "grace"])
    .maybeSingle();

  const now = new Date();
  const isPro = !!sub && (
    (sub.status === "active" && sub.expires_at && new Date(sub.expires_at) >= now) ||
    (sub.status === "grace" && sub.grace_expires_at && new Date(sub.grace_expires_at) >= now)
  );

  if (!isPro && profile.free_checks_used >= FREE_CHECKS_LIMIT) {
    return jsonResponse({ error: "paywall" }, 402);
  }

  // 4. Rate limit: 10 checks/hour per user
  const { count: recentChecksCount } = await supabase
    .from("checks")
    .select("id", { count: "exact", head: true })
    .eq("user_id", user.id)
    .gte("created_at", new Date(now.getTime() - 60 * 60 * 1000).toISOString());
  if ((recentChecksCount ?? 0) >= RATE_LIMIT_PER_HOUR) {
    return jsonResponse({ error: "rate_limited" }, 429);
  }

  if (!openaiApiKey) {
    return jsonResponse(
      { error: "server_misconfigured", message: "OPENAI_API_KEY is not set" },
      500,
    );
  }

  // 5. Signed URL for OpenAI
  const { data: signed, error: signedError } = await supabase.storage
    .from("look-photos")
    .createSignedUrl(imagePath, SIGNED_URL_TTL_SECONDS);
  if (signedError || !signed) {
    return jsonResponse({ error: "image_not_found" }, 404);
  }

  // 6. Call OpenAI Vision — timeout 30s, retry 1 раз (CHECK-07)
  const openai = new OpenAI({ apiKey: openaiApiKey });

  const callOpenAI = () =>
    openai.chat.completions.create(
      {
        model: "gpt-4o",
        response_format: { type: "json_schema", json_schema: LOOK_ANALYSIS_SCHEMA },
        messages: [
          { role: "system", content: systemPrompt(locale) },
          {
            role: "user",
            content: [
              { type: "text", text: "Проанализируй мой outfit и оцени трендовость." },
              { type: "image_url", image_url: { url: signed.signedUrl, detail: "high" } },
            ],
          },
        ],
        max_tokens: 1500,
        temperature: 0.7,
      },
      { timeout: ANALYSIS_TIMEOUT_MS },
    );

  let completion;
  try {
    completion = await callOpenAI();
  } catch {
    try {
      completion = await callOpenAI();
    } catch {
      // CHECK-08: понятное сообщение, free_checks_used не инкрементируется
      return jsonResponse(
        {
          error: "analysis_failed",
          message:
            "Не получилось проанализировать фото. Попробуй ещё раз — проверка не списана.",
        },
        502,
      );
    }
  }

  let analysis;
  try {
    analysis = JSON.parse(completion.choices[0].message.content ?? "{}");
  } catch {
    return jsonResponse(
      {
        error: "analysis_failed",
        message: "Не получилось проанализировать фото. Попробуй ещё раз — проверка не списана.",
      },
      502,
    );
  }

  // Defensive: label всегда согласован со шкалой score (5.3), даже если модель ошиблась
  analysis.trend_label = trendLabelForScore(analysis.trend_score);

  // 7. Save check
  const { data: check, error: insertError } = await supabase
    .from("checks")
    .insert({
      user_id: user.id,
      image_path: imagePath,
      trend_score: analysis.trend_score,
      trend_label: analysis.trend_label,
      ai_response: analysis,
    })
    .select()
    .single();

  if (insertError || !check) {
    return jsonResponse({ error: "save_failed" }, 500);
  }

  // 8. Increment free_checks_used if not pro
  if (!isPro) {
    await supabase
      .from("profiles")
      .update({ free_checks_used: profile.free_checks_used + 1 })
      .eq("id", user.id);
  }

  return jsonResponse({ check_id: check.id, ...analysis });
});
