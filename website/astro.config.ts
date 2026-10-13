import { defineConfig } from "astro/config";
import sitemap from "@astrojs/sitemap";
import tailwindcss from "@tailwindcss/vite";
import { SITE_URL } from "./src/config";

export default defineConfig({
  site: SITE_URL,
  output: "static",
  trailingSlash: "never",
  build: {
    // privacy.html instead of privacy/index.html: Cloudflare Pages serves it at /privacy
    format: "file",
  },
  integrations: [
    sitemap({
      filter: (page) => !page.includes("/404"),
    }),
  ],
  vite: {
    plugins: [tailwindcss()],
  },
});
