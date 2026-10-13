# TODO: placeholders to replace before launch

Everything below is a placeholder or something to confirm. Most values live in **one file: `src/config.ts`**.
After editing, run `npm run build` (or push to deploy).

## 1. Values in `src/config.ts`

| Constant | Current value | What to put there | Effect |
|---|---|---|---|
| `SITE_URL` | `https://example.com` | Final production URL, no trailing slash (e.g. `https://trendylook.app`) | Canonical URLs, Open Graph/Twitter URLs, `og:image`, sitemap, robots.txt |
| `SUPPORT_EMAIL` | `hello@example.com` | Real support address (see section 3) | Footer "Contact" link, contact block, FAQ "How do I contact you?" |
| `APP_STORE_URL` | `""` | App Store listing URL | Empty = button shows **Coming soon** and is not a link. Filled = real link |
| `GOOGLE_PLAY_URL` | `""` | Google Play listing URL | Same as above |
| `INSTAGRAM_URL` | `""` | Instagram profile URL | Empty = icon hidden in the footer |
| `TIKTOK_URL` | `""` | TikTok profile URL | Empty = icon hidden in the footer |
| `APP_ICON` | `/brand/app-icon.svg` | `/brand/app-icon.png` once the real icon exists | Header logo, favicon, apple-touch-icon, OG image logo |

## 2. App icon (temporary placeholder)

- **File:** `public/brand/app-icon.svg`: pink → violet rounded square with a white ring/lens glyph.
- **To replace:** drop the real icon at `public/brand/app-icon.png` (1024x1024, square, no transparency needed) and set
  `APP_ICON = "/brand/app-icon.png"` in `src/config.ts`. The favicon, the 180x180 `apple-touch-icon.png`, the 32x32 PNG
  favicon and the logo in the OG image are generated from it at build time. Nothing else to change.
- Note: the app repository already has `assets/brand/app_icon_1024.png` (a pink/violet ring with a lime sparkle). If that is
  the final icon, copy it to `website/public/brand/app-icon.png` and switch the path.

## 3. Values from the legal texts that should go into `src/config.ts`

| Value in the legal texts | Where it appears | Suggested change |
|---|---|---|
| Email **`trendylook2026@outlook.com`** | Privacy §1, §11.1, §14 · Terms §1, §4.2, §4.4, §17.1, §22 | Set `SUPPORT_EMAIL = "trendylook2026@outlook.com"`, **or** if you switch to a domain address (e.g. `hello@trendylook.app`), update both legal documents too, so the site and the policies show the same email. |
| Data controller / contracting party **`Artur Arzumanian`** (individual) with the Tbilisi address | Privacy §1, §14 · Terms §1, §16, §18, §19, §22 | No config constant uses it today. The footer says "© 2026 Trendy Look" as requested. If you want the legal name in the footer (e.g. "© 2026 Artur Arzumanian"), add a `COMPANY_NAME` constant and use it in `src/components/Footer.astro`. |

## 4. Content and copy to confirm

| Item | File | Why |
|---|---|---|
| **Story card "top tip"**: copy says the 9:16 card has "your photo, score and top tip", and the coded mockup shows a "TOP TIP" box | `src/pages/index.astro` (section `#stories`) | The latest app commit (`478c3d4`, "drop tip from share card") removed the tip from the real share card. Either restore it in the app or change the copy to "your photo and score" and delete the TOP TIP box from the mockup. |
| `trendylook.app` text on the story-card mockup | `src/pages/index.astro` (section `#stories`) | Hard-coded as specified. Change it if the final domain is different. |
| Story-card photo | `src/assets/photos/story-look.jpg` | Copied from the app's onboarding photo (`assets/onboarding/look_1.jpg`). Replace it if you'd rather use another photo. Confirm you have the rights to use it on the web. |
| **Paywall screenshot shows "12,000+ checks today"** | `src/assets/screens/paywall.png` | That line is the app's `paywallSocialProof` string. The site itself invents no numbers, but the screenshot shows one. If the number isn't real yet, retake the screenshot or crop that line. |
| Prices $4.99/week and $29.99/6 months | `src/pages/index.astro` (`plans`) | Must match App Store Connect / Play Console. The small print already says prices may vary by region. |
| Screenshots | `src/assets/screens/*.png` | Russian UI, as agreed. To swap one, replace the PNG with the same filename (transparent PNG, iPhone frame, ~1600x3148). |
| Document naming: the site says **"Terms of Use"**, the document heading says **"Terms of Service"** | `src/components/Footer.astro`, `src/content/legal/terms.md` (frontmatter `title`) | Pick one name everywhere (see LEGAL_REVIEW.md). |

## 5. Deploy settings (one-time)

- Cloudflare Pages: root directory `website`, build command `npm run build`, output `dist`, `NODE_VERSION=22`
  (details in README.md).
- After the domain is connected, update `SITE_URL` (section 1) and redeploy. Then check `https://<domain>/og.png`,
  `/sitemap-index.xml` and `/robots.txt`.
- Optional: submit the sitemap in Google Search Console.
