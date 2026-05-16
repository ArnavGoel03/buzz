#!/usr/bin/env node
// Single-source-of-truth version stamper. Reads `VERSION` at the repo root and writes
// the value into every per-platform config that ships a version string. Run this any
// time you bump the version; commit the resulting diff.
//
//   echo "1.2.0" > VERSION
//   node scripts/sync-version.mjs
//   git add -A && git commit -m "v1.2.0"
//
// Surfaces touched:
//   - project.yml                MARKETING_VERSION (iOS / iPadOS / macOS / AppClip)
//   - android/app/build.gradle.kts                    versionName
//   - win/src-tauri/tauri.conf.json                    version
//   - web/lib/version.ts          (generated)         VERSION constant
//   - SESSION_STATE.md / README footer                (informational only)
//
// iOS build numbers + Android versionCode are independent from this — they bump per
// build, not per release. The `MARKETING_VERSION` / `versionName` is the semver users see.

import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const VERSION = readFileSync(join(ROOT, "VERSION"), "utf8").trim();

if (!/^\d+\.\d+\.\d+$/.test(VERSION)) {
  console.error(`✖ VERSION must be semver (X.Y.Z); got "${VERSION}"`);
  process.exit(1);
}

const log = (path) => console.log(`  ✓ ${path}`);

// 1. project.yml — iOS / iPadOS / macOS / AppClip via xcodegen.
{
  const p = join(ROOT, "project.yml");
  const before = readFileSync(p, "utf8");
  const after = before.replace(
    /(MARKETING_VERSION:\s*")[^"]+(")/,
    `$1${VERSION}$2`
  );
  if (after !== before) { writeFileSync(p, after); log("project.yml"); }
  else                  console.log("  – project.yml (no change)");
}

// 2. android/app/build.gradle.kts — versionName.
{
  const p = join(ROOT, "android/app/build.gradle.kts");
  const before = readFileSync(p, "utf8");
  const after = before.replace(
    /(versionName\s*=\s*")[^"]+(")/,
    `$1${VERSION}$2`
  );
  if (after !== before) { writeFileSync(p, after); log("android/app/build.gradle.kts"); }
  else                  console.log("  – android/app/build.gradle.kts (no change)");
}

// 3. win/src-tauri/tauri.conf.json — version (JSON).
{
  const p = join(ROOT, "win/src-tauri/tauri.conf.json");
  const cfg = JSON.parse(readFileSync(p, "utf8"));
  if (cfg.version !== VERSION) {
    cfg.version = VERSION;
    writeFileSync(p, JSON.stringify(cfg, null, 2) + "\n");
    log("win/src-tauri/tauri.conf.json");
  } else {
    console.log("  – win/src-tauri/tauri.conf.json (no change)");
  }
}

// 4. win/src-tauri/Cargo.toml — package.version. Keeps cargo + tauri-conf aligned.
{
  const p = join(ROOT, "win/src-tauri/Cargo.toml");
  const before = readFileSync(p, "utf8");
  const after = before.replace(
    /^(version\s*=\s*")[^"]+(")/m,
    `$1${VERSION}$2`
  );
  if (after !== before) { writeFileSync(p, after); log("win/src-tauri/Cargo.toml"); }
  else                  console.log("  – win/src-tauri/Cargo.toml (no change)");
}

// 5. web/lib/version.ts — single-import constant for every web surface.
{
  const p = join(ROOT, "web/lib/version.ts");
  mkdirSync(dirname(p), { recursive: true });
  const body = `// GENERATED from /VERSION — do not edit by hand.
// Run \`node scripts/sync-version.mjs\` after editing /VERSION.
export const VERSION = "${VERSION}";
export const BUILD_ID =
  process.env.NEXT_PUBLIC_BUILD_ID ??
  process.env.VERCEL_GIT_COMMIT_SHA?.slice(0, 7) ??
  "dev";
`;
  writeFileSync(p, body);
  log("web/lib/version.ts");
}

console.log(`\n▶ Synced everything to v${VERSION}.`);
console.log("  Next: regenerate the Xcode project (xcodegen generate) before any local Mac build.");
