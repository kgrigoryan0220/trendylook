import type { APIRoute } from "astro";
import { llmsTxt, textResponse } from "../lib/llms";

// https://llmstxt.org — short summary for AI assistants, built from src/config.ts and src/data/site.ts.
export const GET: APIRoute = () => textResponse(llmsTxt());
