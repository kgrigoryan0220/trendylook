import type { APIRoute } from "astro";
import { SITE_URL } from "../config";

export const GET: APIRoute = () =>
  new Response(
    `User-agent: *\nAllow: /\n\nSitemap: ${SITE_URL}/sitemap-index.xml\n\n# Summary for AI assistants: ${SITE_URL}/llms.txt\n`, {
    headers: { "Content-Type": "text/plain; charset=utf-8" },
  });
