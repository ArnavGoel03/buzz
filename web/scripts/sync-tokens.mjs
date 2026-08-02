#!/usr/bin/env node
/**
 * design/tokens.json is the only place a design value is written down. This script
 * fans it out to the two consumers that need it in different shapes:
 *
 *   app/_tokens.css  CSS custom properties, read by globals.css and every component
 *   lib/tokens.ts    typed constants, read by the manifest, viewport theme colour,
 *                    OG image renderers, and the icon rasterizer
 *
 * Both are generated. Editing either by hand puts the values back out of sync, which
 * is exactly the drift this file exists to prevent.
 *
 * Run from web/: `node scripts/sync-tokens.mjs`
 */

import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const WEB = join(dirname(fileURLToPath(import.meta.url)), "..");
const tokens = JSON.parse(readFileSync(join(WEB, "design/tokens.json"), "utf8"));

/**
 * camelCase to kebab-case, so `accentBright` becomes `--color-accent-bright`.
 * Trailing digits split too, so `surface2` becomes `--color-surface-2`.
 */
const kebab = (s) =>
  s
    .replace(/([a-z0-9])([A-Z])/g, "$1-$2")
    .replace(/([a-zA-Z])(\d)/g, "$1-$2")
    .toLowerCase();

const GENERATED = (cmd) =>
  `/* GENERATED from design/tokens.json. Do not edit by hand.\n   Run \`${cmd}\` after editing tokens. */`;

// ---------------------------------------------------------------- CSS output

const cssLines = [GENERATED("node scripts/sync-tokens.mjs"), "", ":root {"];
for (const [group, entries] of Object.entries(tokens.color)) {
  cssLines.push(`  /* ${group[0].toUpperCase()}${group.slice(1)} */`);
  for (const [name, value] of Object.entries(entries)) {
    cssLines.push(`  --color-${kebab(name)}: ${value};`);
  }
}
for (const scale of ["radius", "spacing"]) {
  cssLines.push(`  /* ${scale[0].toUpperCase()}${scale.slice(1)} */`);
  for (const [name, value] of Object.entries(tokens[scale])) {
    cssLines.push(`  --${scale}-${name}: ${value};`);
  }
}
cssLines.push("}", "");
writeFileSync(join(WEB, "app/_tokens.css"), cssLines.join("\n"));

// ----------------------------------------------------------------- TS output

const flatColors = Object.values(tokens.color).reduce((all, group) => ({ ...all, ...group }), {});
const entriesToTs = (obj, indent = "  ") =>
  Object.entries(obj)
    .map(([k, v]) => `${indent}${/^[a-z][a-zA-Z0-9]*$/.test(k) ? k : JSON.stringify(k)}: ${JSON.stringify(v)},`)
    .join("\n");

const ts = `${GENERATED("pnpm tokens")}

/** Every colour in the design system, keyed the same way as the CSS variables. */
export const COLOR = {
${entriesToTs(flatColors)}
} as const;

export const RADIUS = {
${entriesToTs(tokens.radius)}
} as const;

export const SPACING = {
${entriesToTs(tokens.spacing)}
} as const;

/**
 * The values that have to leave CSS: browser chrome, manifest, OG images, and the
 * rasterized app icons all need a literal string, not a custom property.
 */
export const BRAND_COLORS = {
  /** Browser chrome and the PWA splash background. */
  theme: COLOR.background,
  background: COLOR.background,
  accent: COLOR.accent,
  /** Text drawn on top of accent. */
  accentInk: COLOR.accentInk,
  text: COLOR.textPrimary,
  textMuted: COLOR.textSecondary,
  border: COLOR.borderStrong,
} as const;
`;
writeFileSync(join(WEB, "lib/tokens.ts"), ts);

console.log("wrote app/_tokens.css and lib/tokens.ts from design/tokens.json");
