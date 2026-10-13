import type { APIRoute } from "astro";
import { appIconPng, pngResponse } from "../lib/brand-images";

// Generated at build time from APP_ICON (src/config.ts). iOS needs a PNG, it does not accept SVG here.
export const GET: APIRoute = async () => pngResponse(await appIconPng(180, true));
