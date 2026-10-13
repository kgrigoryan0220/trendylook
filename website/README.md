# Trendy Look: marketing website

Static marketing site for the Trendy Look app, built with **Astro 7** and **Tailwind CSS 4**.
Pages: `/` (landing), `/privacy`, `/terms` and a custom 404.

- Placeholders still to replace: **[TODO.md](./TODO.md)**
- Consistency check of the legal texts: **[LEGAL_REVIEW.md](./LEGAL_REVIEW.md)**

## Requirements

- Node.js **22.12 or newer** (Astro 7 requirement; pinned in `.node-version`)
- npm

## Local development

```bash
cd website
npm install
npm run dev        # http://localhost:4321 with hot reload
```

Other scripts:

```bash
npm run build      # static build into dist/
npm run preview    # serve dist/ locally at http://localhost:4321
npm run check      # TypeScript / Astro diagnostics
```

## Where things live

| What | Where |
|---|---|
| Editable values (site URL, email, store and social links, app icon path) | `src/config.ts` |
| Landing page sections | `src/pages/index.astro` |
| Shared layout (head/SEO, header, footer) | `src/layouts/BaseLayout.astro`, `src/components/Header.astro`, `src/components/Footer.astro` |
| Legal texts (rendered as-is) | `src/content/legal/privacy.md`, `src/content/legal/terms.md` |
| Legal page layout and typography | `src/layouts/LegalLayout.astro` |
| Design tokens (colors, fonts, radii) and global styles | `src/styles/global.css` |
| App screenshots (optimized at build time) | `src/assets/screens/*.png` |
| App icon (source for logo and favicons) | `public/brand/app-icon.png` |
| OG image (1200x630, generated at build time) | `src/pages/og.png.ts` → `/og.png` |
| Logo, favicons, apple-touch-icon (generated from the app icon) | `src/pages/icon-192.png.ts`, `src/pages/favicon-32.png.ts`, `src/pages/apple-touch-icon.png.ts` |
| robots.txt (uses `SITE_URL`) | `src/pages/robots.txt.ts` |
| sitemap | `@astrojs/sitemap` → `/sitemap-index.xml` |
| Cloudflare response headers (caching, security) | `public/_headers` |

Notes:

- **Images.** Screenshots go through the Astro image pipeline: AVIF + WebP with a PNG fallback, responsive `srcset`,
  explicit `width`/`height`, lazy-loading below the fold. Transparency is preserved.
- **Fonts.** Poppins, Inter and JetBrains Mono are self-hosted via Fontsource (same Google Fonts families, bundled at
  build time). The site makes no requests to Google or any other third party: no analytics, no trackers, no cookies.
- **Motion.** Scroll reveals, the hero score count-up and the confetti burst all turn off with `prefers-reduced-motion`.
  Without JavaScript, all content is still visible.

## Deploy to Cloudflare Pages

The site lives in the `website/` folder of this repository, so set **Root directory** to `website`.

### Option A: Git integration (recommended)

1. Cloudflare dashboard → **Workers & Pages** → **Create** → **Pages** → **Connect to Git** → pick this repository.
2. Build settings:

   | Setting | Value |
   |---|---|
   | Framework preset | Astro |
   | Production branch | `main` (or the branch you deploy from) |
   | Root directory (advanced) | `website` |
   | Build command | `npm run build` |
   | Build output directory | `dist` |
   | Environment variable | `NODE_VERSION` = `22` |

   `NODE_VERSION` is a safeguard: the build image also reads `.node-version`, but an older default Node fails the
   Astro 7 build.
3. **Save and Deploy.** Every push to the production branch redeploys, and other branches get preview URLs.
4. **Custom domain.** Project → **Custom domains** → **Set up a custom domain** → enter your domain. The domain is
   already on Cloudflare, so DNS records are created automatically.
5. `SITE_URL` in `src/config.ts` is set to `https://trendylook.app`. If the domain ever changes, update it and push, so canonical
   URLs, Open Graph tags, the sitemap and robots.txt point to it.

### Option B: Direct upload with Wrangler

```bash
cd website
npm run build
npx wrangler pages deploy dist --project-name trendylook
```

### URLs on Cloudflare Pages

The build uses `build.format: "file"` (`privacy.html`, `terms.html`), which Cloudflare Pages serves at clean URLs
(`/privacy`, `/terms`). Unknown paths get `404.html` with a real 404 status.
