import type { APIRoute } from "astro";
import fs from "node:fs/promises";
import path from "node:path";
import satori from "satori";
import sharp from "sharp";
import { appIconPng, pngResponse } from "../lib/brand-images";

/**
 * 1200x630 Open Graph / Twitter image, generated at build time in brand style
 * from src/assets/screens/result.png + the hero headline. Edit the markup below to change it.
 */

const W = 1200;
const H = 630;

const font = (weight: number) =>
  fs.readFile(path.join(process.cwd(), `node_modules/@fontsource/poppins/files/poppins-latin-${weight}-normal.woff`));

const dataUri = (buf: Buffer) => `data:image/png;base64,${buf.toString("base64")}`;

// Minimal hyperscript helper so this file needs no JSX setup.
type Node = { type: string; props: Record<string, unknown> };
const h = (type: string, style: Record<string, unknown>, ...children: unknown[]): Node => ({
  type,
  props: { style, children: children.length === 1 ? children[0] : children },
});
const img = (src: string, width: number, height: number, style: Record<string, unknown> = {}): Node => ({
  type: "img",
  props: { src, width, height, style },
});

export const GET: APIRoute = async () => {
  const phoneW = 296;
  const phoneH = Math.round((phoneW * 3148) / 1600);
  const phone = await sharp(path.join(process.cwd(), "src/assets/screens/result.png"))
    .resize(phoneW * 2)
    .png()
    .toBuffer();
  const icon = await appIconPng(112);

  const tree = h(
    "div",
    {
      width: W,
      height: H,
      display: "flex",
      position: "relative",
      backgroundColor: "#0B0B10",
      backgroundImage:
        "radial-gradient(circle at 8% 0%, rgba(123,92,255,0.55) 0%, rgba(123,92,255,0) 42%), radial-gradient(circle at 80% 60%, rgba(255,61,138,0.55) 0%, rgba(255,61,138,0) 40%), radial-gradient(circle at 100% 100%, rgba(123,92,255,0.45) 0%, rgba(123,92,255,0) 40%)",
      fontFamily: "Poppins",
      color: "#FFFFFF",
    },
    h(
      "div",
      { display: "flex", flexDirection: "column", justifyContent: "center", padding: "0 0 0 72px", width: 760 },
      h(
        "div",
        { display: "flex", alignItems: "center" },
        img(dataUri(icon), 56, 56, { borderRadius: 14 }),
        h("div", { marginLeft: 18, fontSize: 28, fontWeight: 800, letterSpacing: 3 }, "TRENDY LOOK"),
      ),
      h(
        "div",
        { marginTop: 44, fontSize: 18, fontWeight: 600, letterSpacing: 5, color: "#FF3D8A" },
        "AI STYLIST · iOS & ANDROID",
      ),
      h(
        "div",
        { display: "flex", flexWrap: "wrap", marginTop: 14, fontSize: 92, fontWeight: 800, lineHeight: 1, letterSpacing: -3.5 },
        h("span", { marginRight: 24 }, "How trendy"),
        h("span", { marginRight: 24 }, "is your"),
        h("span", { color: "#C6FF3D" }, "look?"),
      ),
      h(
        "div",
        { marginTop: 30, fontSize: 26, fontWeight: 600, color: "#9A9AA8", maxWidth: 600, lineHeight: 1.35 },
        "Trend score, AI style breakdown and tips in seconds.",
      ),
    ),
    h("div", {
      position: "absolute",
      right: 40,
      top: 70,
      width: 420,
      height: 520,
      borderRadius: 9999,
      backgroundImage: "radial-gradient(circle, rgba(255,61,138,0.55) 0%, rgba(123,92,255,0.35) 45%, rgba(123,92,255,0) 70%)",
    }),
    img(dataUri(phone), phoneW, phoneH, { position: "absolute", right: 100, top: 22 }),
  );

  const svg = await satori(tree as never, {
    width: W,
    height: H,
    fonts: [
      { name: "Poppins", data: await font(600), weight: 600, style: "normal" },
      { name: "Poppins", data: await font(800), weight: 800, style: "normal" },
    ],
  });

  return pngResponse(await sharp(Buffer.from(svg)).flatten({ background: "#0B0B10" }).png({ compressionLevel: 9 }).toBuffer());
};
