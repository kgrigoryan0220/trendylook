import { getEntry } from "astro:content";
import { APP_STORE_URL, GOOGLE_PLAY_URL, SITE_DESCRIPTION, SITE_NAME, SITE_URL, SUPPORT_EMAIL } from "../config";
import { categories, contactFaq, faqs, languages, plans, pricingNote, promise, steps, tiers } from "../data/site";

/** llms.txt (https://llmstxt.org): a short, link-rich summary of the site for AI assistants. */

const url = (path: string) => `${SITE_URL}${path}`;

const storeLine = () => {
  const stores = [
    APP_STORE_URL ? `[App Store](${APP_STORE_URL})` : "",
    GOOGLE_PLAY_URL ? `[Google Play](${GOOGLE_PLAY_URL})` : "",
  ].filter(Boolean);
  return stores.length ? `Download: ${stores.join(", ")}.` : "App Store and Google Play listings are coming soon.";
};

const pricingLines = () =>
  plans.map((p) => `- ${p.name}: ${p.price}${p.period ? ` ${p.period.replace("/", "per ")}` : ""}. ${p.features.join(", ")}.`);

const keyFacts = () => [
  "- Platforms: iOS and Android.",
  `- What it does: rates how on-trend an outfit is, from 0 to 100%, in 5–15 seconds, with a breakdown by ${categories
    .slice(0, -1)
    .map((c) => c.label.toLowerCase())
    .join(", ")} and ${categories.at(-1)?.label.toLowerCase()}, plus personal AI style tips.`,
  `- Score tiers: ${tiers.map((t) => `${t.range} ${t.label}`).join(", ")}.`,
  "- Sharing: every result becomes a 9:16 card for Instagram Stories, TikTok or Reels.",
  `- Body-positive by design: ${promise}`,
  "- What it is not: not a chatbot, not a wardrobe app, not a shopping app.",
  "- Audience: Gen Z and young millennials (16–30).",
  `- Languages: ${languages.join(", ")}.`,
  `- Contact: ${SUPPORT_EMAIL}`,
];

export function llmsTxt() {
  return [
    `# ${SITE_NAME}`,
    "",
    `> ${SITE_DESCRIPTION}`,
    "",
    `${SITE_NAME} is a mobile AI stylist app that answers one question: "How trendy is your look?" ${storeLine()}`,
    "",
    "Key facts:",
    "",
    ...keyFacts(),
    "",
    "Pricing (USD, may vary by region):",
    "",
    ...pricingLines(),
    "",
    "## Pages",
    "",
    `- [Home](${url("/")}): what the app does, how it works, score scale, pricing and FAQ`,
    `- [Privacy Policy](${url("/privacy")}): what data the app collects, how photos are processed and how to delete your account`,
    `- [Terms of Use](${url("/terms")}): subscription, auto-renewal, refunds and AI disclaimer`,
    "",
    "## Optional",
    "",
    `- [Full site text](${url("/llms-full.txt")}): every page in one plain-text file, including the full Privacy Policy and Terms`,
    "",
  ].join("\n");
}

export async function llmsFullTxt() {
  const [privacy, terms] = await Promise.all([getEntry("legal", "privacy"), getEntry("legal", "terms")]);
  const faqBlock = [...faqs.map((f) => ({ q: f.q, a: f.a })), { q: contactFaq.q, a: contactFaq.a(SUPPORT_EMAIL) }]
    .map((f) => `### ${f.q}\n\n${f.a}`)
    .join("\n\n");

  return [
    `# ${SITE_NAME}`,
    "",
    `> ${SITE_DESCRIPTION}`,
    "",
    `Source: ${url("/")}. ${storeLine()}`,
    "",
    "## Key facts",
    "",
    ...keyFacts(),
    "",
    "## How it works",
    "",
    ...steps.map((s) => `${Number(s.n)}. **${s.title}.** ${s.text}`),
    "",
    "## Score scale",
    "",
    "Every result has a color, so you read the verdict in a split second.",
    "",
    ...tiers.map((t) => `- ${t.range}%: ${t.label}${t.note ? ` (${t.note})` : ""}`),
    "",
    "## What the AI checks",
    "",
    `A real breakdown, not just a number: ${categories.map((c) => c.label).join(", ")}, plus personal tips you can apply right now.`,
    "",
    "## Made for Stories",
    "",
    "Every check turns into a bold 9:16 card with your photo and score. Share it to Instagram, TikTok or WhatsApp in one tap and challenge your friends to beat your score.",
    "",
    "## Our promise",
    "",
    `Style feedback. Zero body-shaming. ${promise} You can delete your account anytime in the app.`,
    "",
    "## Pricing",
    "",
    ...pricingLines(),
    "",
    pricingNote,
    "",
    "## FAQ",
    "",
    faqBlock,
    "",
    "---",
    "",
    `<!-- ${url("/privacy")} -->`,
    "",
    privacy?.body?.trim() ?? "",
    "",
    "---",
    "",
    `<!-- ${url("/terms")} -->`,
    "",
    terms?.body?.trim() ?? "",
    "",
  ].join("\n");
}

export const textResponse = (body: string) =>
  new Response(body, { headers: { "Content-Type": "text/plain; charset=utf-8" } });
