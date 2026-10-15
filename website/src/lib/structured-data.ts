import { APP_STORE_URL, GOOGLE_PLAY_URL, SITE_DESCRIPTION, SITE_NAME, SITE_URL, SUPPORT_EMAIL } from "../config";
import { contactFaq, faqs, plans } from "../data/site";

/** schema.org JSON-LD for the landing page: organization, website, the app with its prices, and the FAQ. */
export function landingJsonLd() {
  const org = `${SITE_URL}/#organization`;
  const storeUrls = [APP_STORE_URL, GOOGLE_PLAY_URL].filter(Boolean);

  return {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "Organization",
        "@id": org,
        name: SITE_NAME,
        url: `${SITE_URL}/`,
        logo: `${SITE_URL}/icon-192.png`,
        email: SUPPORT_EMAIL,
        contactPoint: { "@type": "ContactPoint", contactType: "customer support", email: SUPPORT_EMAIL },
      },
      {
        "@type": "WebSite",
        "@id": `${SITE_URL}/#website`,
        name: SITE_NAME,
        url: `${SITE_URL}/`,
        inLanguage: "en",
        publisher: { "@id": org },
      },
      {
        "@type": "MobileApplication",
        "@id": `${SITE_URL}/#app`,
        name: SITE_NAME,
        description: SITE_DESCRIPTION,
        url: `${SITE_URL}/`,
        image: `${SITE_URL}/og.png`,
        operatingSystem: "iOS, Android",
        applicationCategory: "LifestyleApplication",
        inLanguage: ["en", "ru", "es", "it", "de", "fr", "pt"],
        publisher: { "@id": org },
        ...(storeUrls.length ? { downloadUrl: storeUrls, sameAs: storeUrls } : {}),
        offers: plans.map((p) => ({
          "@type": "Offer",
          name: p.name,
          price: p.amount.toFixed(2),
          priceCurrency: "USD",
          ...(p.amount ? { category: "subscription" } : {}),
        })),
      },
      {
        "@type": "FAQPage",
        "@id": `${SITE_URL}/#faq`,
        mainEntity: [...faqs.map((f) => ({ q: f.q, a: f.a })), { q: contactFaq.q, a: contactFaq.a(SUPPORT_EMAIL) }].map(
          (f) => ({ "@type": "Question", name: f.q, acceptedAnswer: { "@type": "Answer", text: f.a } }),
        ),
      },
    ],
  };
}
