#!/usr/bin/env node
// Regenerates iOS / Android / web palette files from design/tokens.json.
// Run after editing tokens.json: `node scripts/sync-tokens.mjs`. Zero npm deps.

import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const T = JSON.parse(readFileSync(join(ROOT, "design/tokens.json"), "utf8"));

const HEADER_SWIFT  = "// GENERATED from design/tokens.json — do not edit by hand.\n// Run `node scripts/sync-tokens.mjs` after editing tokens.\n";
const HEADER_KOTLIN = "// GENERATED from design/tokens.json — do not edit by hand.\n// Run `node scripts/sync-tokens.mjs` after editing tokens.\n";
const HEADER_CSS    = "/* GENERATED from design/tokens.json — do not edit by hand.\n   Run `node scripts/sync-tokens.mjs` after editing tokens. */\n";

// ─── helpers ───
const hexToSwiftRGB = (hex) => {
  const h = hex.replace("#", "");
  // 8-char ARGB → strip leading alpha; we model alpha separately via .opacity in iOS code.
  const rgb = h.length === 8 ? h.slice(2) : h;
  const r = parseInt(rgb.slice(0, 2), 16) / 255;
  const g = parseInt(rgb.slice(2, 4), 16) / 255;
  const b = parseInt(rgb.slice(4, 6), 16) / 255;
  return `Color(red: ${r.toFixed(3)}, green: ${g.toFixed(3)}, blue: ${b.toFixed(3)})`;
};
const hexToKotlin = (hex) => {
  const h = hex.replace("#", "");
  const argb = h.length === 8 ? h : `FF${h}`;
  return `Color(0x${argb.toUpperCase()})`;
};
const swiftName  = (k) => k.split("_").map((p,i)=> i===0 ? p : p[0].toUpperCase()+p.slice(1)).join("");
const kotlinName = (k) => "Buzz" + k.split("_").map((p)=> p[0].toUpperCase()+p.slice(1)).join("");

// ─── iOS: Buzz/Core/DesignSystem/Tokens.swift ───
const swiftLines = [
  HEADER_SWIFT,
  "import SwiftUI\n",
  "enum BuzzTokens {",
  "    // Brand",
  ...Object.entries(T.brand).map(([k, v]) => `    static let ${swiftName(k)} = ${hexToSwiftRGB(v)}`),
  "    // Surface",
  ...Object.entries(T.surface).map(([k, v]) => `    static let ${swiftName(k)} = ${hexToSwiftRGB(v)}`),
  "    // Border",
  ...Object.entries(T.border).map(([k, v]) => `    static let ${swiftName(k)} = ${hexToSwiftRGB(v)}`),
  "    // Text",
  ...Object.entries(T.text).map(([k, v]) => `    static let text${k[0].toUpperCase()+k.slice(1)} = ${hexToSwiftRGB(v)}`),
  "    // Status",
  ...Object.entries(T.status).map(([k, v]) => `    static let ${swiftName(k)} = ${hexToSwiftRGB(v)}`),
  "    // Category",
  ...Object.entries(T.category).map(([k, v]) => `    static let category${k[0].toUpperCase()+k.slice(1)} = ${hexToSwiftRGB(v)}`),
  "    // Radius",
  ...Object.entries(T.radius).map(([k, v]) => `    static let radius${k.toUpperCase()}: CGFloat = ${v}`),
  "    // Spacing",
  ...Object.entries(T.spacing).map(([k, v]) => `    static let spacing${k.toUpperCase()}: CGFloat = ${v}`),
  "}",
  ""
].join("\n");

// ─── Android: ui/theme/Tokens.kt ───
const ktLines = [
  HEADER_KOTLIN,
  "package com.arnavgoel.buzz.ui.theme\n",
  "import androidx.compose.ui.graphics.Color",
  "import androidx.compose.ui.unit.dp",
  "import androidx.compose.ui.unit.Dp\n",
  "object BuzzTokens {",
  "    // Brand",
  ...Object.entries(T.brand).map(([k, v]) => `    val ${kotlinName(k)} = ${hexToKotlin(v)}`),
  "    // Surface",
  ...Object.entries(T.surface).map(([k, v]) => `    val ${kotlinName(k)} = ${hexToKotlin(v)}`),
  "    // Border",
  ...Object.entries(T.border).map(([k, v]) => `    val ${kotlinName(k)} = ${hexToKotlin(v)}`),
  "    // Text",
  ...Object.entries(T.text).map(([k, v]) => `    val BuzzText${k[0].toUpperCase()+k.slice(1)} = ${hexToKotlin(v)}`),
  "    // Status",
  ...Object.entries(T.status).map(([k, v]) => `    val ${kotlinName(k)} = ${hexToKotlin(v)}`),
  "    // Category",
  ...Object.entries(T.category).map(([k, v]) => `    val Category${k[0].toUpperCase()+k.slice(1)} = ${hexToKotlin(v)}`),
  "    // Radius",
  ...Object.entries(T.radius).map(([k, v]) => `    val Radius${k.toUpperCase()}: Dp = ${v}.dp`),
  "    // Spacing",
  ...Object.entries(T.spacing).map(([k, v]) => `    val Spacing${k.toUpperCase()}: Dp = ${v}.dp`),
  "}",
  ""
].join("\n");

// ─── Web: web/app/_tokens.css ───
const cssVars = (group, prefix = "") =>
  Object.entries(group).map(([k, v]) => `  --color-${prefix}${k.replace(/_/g, "-")}: ${v};`).join("\n");
const cssLines = [
  HEADER_CSS,
  ":root {",
  "  /* Brand */",
  cssVars(T.brand),
  "  /* Surface */",
  cssVars(T.surface),
  "  /* Border */",
  cssVars(T.border),
  "  /* Text */",
  Object.entries(T.text).map(([k, v]) => `  --color-text-${k}: ${v};`).join("\n"),
  "  /* Status */",
  cssVars(T.status),
  "  /* Category */",
  Object.entries(T.category).map(([k, v]) => `  --color-category-${k}: ${v};`).join("\n"),
  "  /* Radius */",
  ...Object.entries(T.radius).map(([k, v]) => `  --radius-${k}: ${v}px;`),
  "  /* Spacing */",
  ...Object.entries(T.spacing).map(([k, v]) => `  --spacing-${k}: ${v}px;`),
  "}",
  ""
].join("\n");

// ─── write ───
const writes = [
  ["Buzz/Core/DesignSystem/Tokens.swift", swiftLines],
  ["android/app/src/main/kotlin/com/arnavgoel/buzz/ui/theme/Tokens.kt", ktLines],
  ["web/app/_tokens.css", cssLines],
];
for (const [rel, body] of writes) {
  const out = join(ROOT, rel);
  mkdirSync(dirname(out), { recursive: true });
  writeFileSync(out, body);
  console.log(`wrote ${rel}`);
}
