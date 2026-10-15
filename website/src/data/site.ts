/**
 * Landing-page content shared by the page itself, llms.txt / llms-full.txt and the JSON-LD structured data.
 * Edit copy here once and every output stays in sync.
 */

export const steps = [
  { n: "01", icon: "camera", title: "Snap your look", text: "Take a photo or pick one from your gallery." },
  { n: "02", icon: "gauge", title: "Get your score", text: "AI rates how on-trend your outfit is, from 0 to 100%." },
  { n: "03", icon: "sparkles", title: "Level it up", text: "Get personal tips you can apply right now." },
] as const;

export const tiers = [
  { value: 32, label: "Needs Work", range: "0–39", color: "#FF5C5C" },
  { value: 45, label: "Getting There", range: "40–59", color: "#FFD23D" },
  { value: 75, label: "Trendy", range: "60–79", color: "#FF3D8A" },
  { value: 85, label: "Icon Status", range: "80–100", color: "#C6FF3D", note: "comes with confetti" },
];

export const categories = [
  { label: "Color palette", value: 90 },
  { label: "Silhouette & fit", value: 80 },
  { label: "Accessories", value: 85 },
  { label: "Shoes", value: 80 },
];

export const tips = [
  { title: "Add a statement bag:", text: "a contrasting accessory instantly lifts the look." },
  { title: "Soften the silhouette:", text: "try a lighter layer under the blazer." },
  { title: "Define your proportions:", text: "a belt highlights the waist and pulls the outfit together." },
];

export const plans = [
  {
    name: "Free",
    price: "$0",
    amount: 0,
    period: "",
    features: ["2 outfit checks", "Full score and AI tips", "Share to Stories"],
    cta: "Start free",
    featured: false,
  },
  {
    name: "Half-year",
    price: "$29.99",
    amount: 29.99,
    period: "/6 months",
    features: ["Same benefits as Weekly", "Unlimited checks", "Priority AI analysis", "Early access to trends"],
    cta: "Go Half-year",
    featured: true,
  },
  {
    name: "Weekly",
    price: "$4.99",
    amount: 4.99,
    period: "/week",
    features: ["Unlimited checks", "Priority AI analysis", "Early access to trends"],
    cta: "Go Weekly",
    featured: false,
  },
];

export const pricingNote =
  "Prices may vary by region. Subscriptions renew automatically and can be canceled anytime in your App Store or Google Play settings.";

export const faqs = [
  {
    q: "How does it work?",
    a: "Snap your outfit, the AI looks at color, silhouette, accessories and shoes, and gives you a trend score and tips in seconds.",
  },
  { q: "Is it free?", a: "You get 2 free checks. After that, go Pro for unlimited checks." },
  { q: "Does the AI judge my body or face?", a: "Never. It only rates your outfit." },
  { q: "Can I share my results?", a: "Yes, as a 9:16 card for Stories, TikTok and Reels." },
  {
    q: "Which languages are supported?",
    a: "English, Russian, Spanish, Italian, German, French and Portuguese.",
  },
  { q: "Is it on iOS and Android?", a: "Yes, both." },
  { q: "How do I cancel my subscription?", a: "In your App Store or Google Play subscription settings." },
];

/** The last FAQ item; its answer links to SUPPORT_EMAIL on the page. */
export const contactFaq = { q: "How do I contact you?", a: (email: string) => `Email us at ${email}.` };

export const promisePoints = [
  { icon: "shirt", label: "Clothes only" },
  { icon: "lock", label: "Your data, your call" },
  { icon: "trash", label: "Delete your account anytime" },
] as const;

export const promise =
  "Trendy Look only looks at what you wear: clothes, colors, silhouette, accessories and shoes. Never your body, face or weight.";

export const languages = ["English", "Russian", "Spanish", "Italian", "German", "French", "Portuguese"];
