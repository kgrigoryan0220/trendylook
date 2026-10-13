import fs from "node:fs/promises";
import path from "node:path";
import sharp from "sharp";
import { APP_ICON } from "../config";

/** Absolute path of the configured app icon inside /public (SVG placeholder or the real PNG). */
export const appIconPath = () => path.join(process.cwd(), "public", APP_ICON.replace(/^\//, ""));

/**
 * Square PNG of the app icon at the given size.
 * `fullBleed` (apple-touch-icon): iOS applies its own rounded mask, so the SVG's own corner rounding is removed
 * and any remaining transparency is filled with the page background.
 */
export async function appIconPng(size: number, fullBleed = false) {
  let input = await fs.readFile(appIconPath());
  if (fullBleed && APP_ICON.endsWith(".svg")) {
    input = Buffer.from(input.toString("utf8").replace(/(<rect\b[^>]*?)\srx="[^"]*"/, "$1"));
  }
  let img = sharp(input, { density: 300 }).resize(size, size, { fit: "cover" });
  if (fullBleed) img = img.flatten({ background: "#0B0B10" });
  return img.png().toBuffer();
}

export const pngResponse = (buffer: Buffer) =>
  new Response(new Uint8Array(buffer), { headers: { "Content-Type": "image/png" } });
