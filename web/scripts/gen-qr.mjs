#!/usr/bin/env node
/**
 * Renders the desktop-to-phone handoff QR into a static SVG.
 *
 * Buzz installs to a phone home screen, so a student on a laptop needs a way to move
 * the page to their phone without typing a URL. Generating this at build time keeps
 * it a plain cached asset instead of a runtime dependency on a QR service.
 *
 * Host comes from site.config.json, the same file lib/site.ts reads.
 *
 * Run from web/: `pnpm qr`
 */

import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import QRCode from "qrcode";

const WEB = join(dirname(fileURLToPath(import.meta.url)), "..");
const { productionHost } = JSON.parse(readFileSync(join(WEB, "site.config.json"), "utf8"));
const tokens = JSON.parse(readFileSync(join(WEB, "design/tokens.json"), "utf8"));

const target = `https://${productionHost}/download?src=qr`;

const svg = await QRCode.toString(target, {
  type: "svg",
  errorCorrectionLevel: "M",
  margin: 1,
  color: {
    dark: tokens.color.text.textPrimary,
    light: "#00000000", // transparent, so the code sits on whatever surface renders it
  },
});

writeFileSync(join(WEB, "public/qr-download.svg"), svg);
console.log(`wrote public/qr-download.svg for ${target}`);
