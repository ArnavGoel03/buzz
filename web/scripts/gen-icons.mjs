#!/usr/bin/env node
/**
 * Draws the Buzz mark and rasterizes it into every icon the PWA manifest and the iOS
 * home screen need. iOS ignores SVG for home-screen icons, so these have to be real
 * bitmaps checked into the repo.
 *
 * The mark's colours are read from design/tokens.json like everything else, so
 * rebranding is a one-line edit there followed by `pnpm icons`.
 *
 * Run from web/: `pnpm icons`. Output is committed; nothing rasterizes at request time.
 */

import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import sharp from "sharp";

const WEB = join(dirname(fileURLToPath(import.meta.url)), "..");
const tokens = JSON.parse(readFileSync(join(WEB, "design/tokens.json"), "utf8"));
const { accent, accentInk } = tokens.color.brand;
const { background } = tokens.color.surface;

/** A hex string as the {r,g,b,alpha} object sharp wants for canvas fills. */
function rgb(hex) {
  const n = parseInt(hex.slice(1, 7), 16);
  return { r: (n >> 16) & 255, g: (n >> 8) & 255, b: n & 255, alpha: 1 };
}

/**
 * The mark: a lightning bolt cut out of a rounded square. Reads as energy and as a
 * "B" stroke at 16px, and stays legible when Android crops it to a circle.
 */
const mark = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <rect width="512" height="512" rx="112" fill="${background}"/>
  <path d="M300 64 L168 288 H244 L212 448 L344 224 H268 Z" fill="${accent}" stroke="${accent}" stroke-width="18" stroke-linejoin="round"/>
  <circle cx="256" cy="256" r="196" fill="none" stroke="${accent}" stroke-width="14" opacity="0.22"/>
</svg>
`;
writeFileSync(join(WEB, "public/mark.svg"), mark);
// Favicon: SVG is fine here, every browser that matters supports it.
writeFileSync(join(WEB, "app/icon.svg"), mark);

const svg = Buffer.from(mark);

async function render(size, out) {
  const png = await sharp(svg, { density: 384 }).resize(size, size).png().toBuffer();
  writeFileSync(out, png);
  console.log(`wrote ${out.replace(WEB + "/", "")} (${size}x${size})`);
}

/** Maskable icons get cropped to a circle by Android, so inset the mark by 20%. */
async function renderMaskable(size, out) {
  const inner = Math.round(size * 0.62);
  const pad = Math.round((size - inner) / 2);
  const inset = await sharp(svg, { density: 384 }).resize(inner, inner).png().toBuffer();
  const png = await sharp({
    create: { width: size, height: size, channels: 4, background: rgb(background) },
  })
    .composite([{ input: inset, top: pad, left: pad }])
    .png()
    .toBuffer();
  writeFileSync(out, png);
  console.log(`wrote ${out.replace(WEB + "/", "")} (${size}x${size}, maskable)`);
}

await render(192, join(WEB, "public/icon-192.png"));
await render(512, join(WEB, "public/icon-512.png"));
await render(180, join(WEB, "app/apple-icon.png"));
await render(1024, join(WEB, "public/icon-1024.png"));
await renderMaskable(512, join(WEB, "public/icon-maskable-512.png"));

console.log(`mark drawn with accent ${accent} on ${background}, ink ${accentInk}`);
