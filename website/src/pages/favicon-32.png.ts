import type { APIRoute } from "astro";
import { appIconPng, pngResponse } from "../lib/brand-images";

// PNG favicon fallback for browsers without SVG favicon support. Generated from APP_ICON.
export const GET: APIRoute = async () => pngResponse(await appIconPng(32));
