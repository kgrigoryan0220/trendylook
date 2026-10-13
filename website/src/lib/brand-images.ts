import fs from "node:fs/promises";
import path from "node:path";
import sharp from "sharp";
import { APP_ICON } from "../config";

/** Absolute path of the configured app icon inside /public (SVG placeholder or the real PNG). */
export const appIconPath = () => path.join(process.cwd(), "public", APP_ICON.replace(/^\//, ""));

/** Square PNG of the app icon at the given size, on the page background (for apple-touch-icon / favicon). */
export async function appIconPng(size: number, flatten = false) {
  const input = await fs.readFile(appIconPath());
  let img = sharp(input, { density: 300 }).resize(size, size, { fit: "cover" });
  if (flatten) img = img.flatten({ background: "#0B0B10" });
  return img.png().toBuffer();
}

export const pngResponse = (buffer: Buffer) =>
  new Response(new Uint8Array(buffer), { headers: { "Content-Type": "image/png" } });
