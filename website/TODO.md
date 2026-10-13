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
| `APP_ICON` | `/brand/app-icon.svg` | Keep it, or point to a PNG (see section 2) | Header logo, favicon, apple-touch-icon, OG image logo |

## 2. App icon (done: logo mark from the case study)

- **File:** `public/brand/app-icon.svg`: the logo mark from `TrendyLook_Case_Study.pdf` (pink → violet rounded square,
  white ring, lime dot), redrawn as a vector so it stays sharp at any size. The favicon, the 180x180
  `apple-touch-icon.png`, the 32x32 PNG favicon and the logo in the OG image are generated from it at build time.
- **To confirm:** the app repository has a different icon, `assets/brand/app_icon_1024.png` (a ring with a lime
  sparkle). If the App Store / Google Play icon will be that one, copy it to `website/public/brand/app-icon.png` and set
  `APP_ICON = "/brand/app-icon.png"` in `src/config.ts`, so the site and the store listing match.

## 3. Values from the legal texts that should go into `src/config.ts`

| Value in the legal texts | Where it appears | Suggested change |
|---|---|---|
| Email **`trendylook2026@outlook.com`** | Privacy §1, §11.1, §14 · Terms §1, §4.2, §4.4, §17.1, §22 | Set `SUPPORT_EMAIL = "trendylook2026@outlook.com"`, **or** if you switch to a domain address (e.g. `hello@trendylook.app`), update both legal documents too, so the site and the policies show the same email. |
| Data controller / contracting party **`Artur Arzumanian`** (individual) with the Tbilisi address | Privacy §1, §14 · Terms §1, §16, §18, §19, §22 | No config constant uses it today. The footer says "© 2026 Trendy Look" as requested. If you want the legal name in the footer (e.g. "© 2026 Artur Arzumanian"), add a `COMPANY_NAME` constant and use it in `src/components/Footer.astro`. |

## 4. Content and copy to confirm

| Item | File | Why |
|---|---|---|
| **Story card "top tip"**: copy says the 9:16 card has "your photo, score and top tip", and the coded mockup shows a "TOP TIP" box | `src/pages/index.astro` (section `#stories`) | The share screenshot (`share.png`, taken Sep 16) still shows the tip, but the later app commit `478c3d4` (Oct 2, "drop tip from share card") removed it. Either restore it in the app, or change the copy to "your photo and score" and delete the TOP TIP box from the mockup. `share.png` is off the site until this is decided. |
| `trendylook.app` text on the story-card mockup | `src/pages/index.astro` (section `#stories`) | Hard-coded as specified. Change it if the final domain is different. |
| Story-card photo | `src/assets/photos/story-look.jpg` | Copied from the app's onboarding photo (`assets/onboarding/look_1.jpg`). Replace it if you'd rather use another photo. Confirm you have the rights to use it on the web. |
| Prices $4.99/week and $29.99/6 months | `src/pages/index.astro` (`plans`) | Must match App Store Connect / Play Console. The small print already says prices may vary by region. |
| Screenshots | `src/assets/screens/*.png` | English UI: `result.png` (hero, Made for Stories, gallery, OG image), `snap.png` (How it works), `result-trendy.png` (Score scale), `tips.png` (What the AI checks), `home.png` (gallery). There are no English History or Paywall screens yet, so the gallery shows 4 screens. To swap one, replace the PNG with the same filename (transparent PNG in an iPhone frame). |
| **Share screen temporarily removed** | `src/assets/screens/share.png` (kept, not used) | Taken out of Made for Stories and the gallery until the share card is final (see the "top tip" row above). To bring it back: import `share.png` in `src/pages/index.astro`, use it as the phone next to the story-card mockup, and add a gallery item with the caption "Your result, ready for Stories." Retake the screenshot first if the card changed. |
| Hero and story-card numbers are **80%** to match the `result.png` screenshot | `src/pages/index.astro` (hero ring `value={80}`, background "80%" in hero and final CTA, story-card mockup) | If you replace `result.png` with a screen showing another score, update these numbers too. The 85% card in the Score scale section is just an example of the Icon Status tier. |
| Document naming: the site says **"Terms of Use"**, the document heading says **"Terms of Service"** | `src/components/Footer.astro`, `src/content/legal/terms.md` (frontmatter `title`) | Pick one name everywhere (see LEGAL_REVIEW.md). |

## 5. Deploy settings (one-time)

- Cloudflare Pages: root directory `website`, build command `npm run build`, output `dist`, `NODE_VERSION=22`
  (details in README.md).
- After the domain is connected, update `SITE_URL` (section 1) and redeploy. Then check `https://<domain>/og.png`,
  `/sitemap-index.xml` and `/robots.txt`.
- Optional: submit the sitemap in Google Search Console.
