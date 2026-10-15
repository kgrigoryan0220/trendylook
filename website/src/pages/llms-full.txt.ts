import type { APIRoute } from "astro";
import { llmsFullTxt, textResponse } from "../lib/llms";

// Every page as one plain-text file, including the full Privacy Policy and Terms.
export const GET: APIRoute = async () => textResponse(await llmsFullTxt());
