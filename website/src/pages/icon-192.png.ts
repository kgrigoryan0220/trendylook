import type { APIRoute } from "astro";
import { appIconPng, pngResponse } from "../lib/brand-images";

// Small app icon for the header/footer logo and the favicon, generated from APP_ICON at build time.
export const GET: APIRoute = async () => pngResponse(await appIconPng(192));
