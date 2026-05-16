#!/usr/bin/env bash
# build-win.sh — produce a Buzz.exe + Buzz.msi for ad-hoc distribution on Windows.
#
# Runs from a Mac or Linux dev box via cross-compile (limited) OR on Windows directly.
# The recommended path is to run this on a Windows GitHub Actions runner from the
# CI workflow; cross-compiling to Windows from macOS is brittle.
#
# Usage:
#   BUILD_VERSION=1.0.0 scripts/build-win.sh
#
# Outputs (when run on Windows):
#   win/src-tauri/target/release/buzz.exe
#   win/src-tauri/target/release/bundle/msi/Buzz_<version>_x64_en-US.msi
#   win/src-tauri/target/release/bundle/nsis/Buzz_<version>_x64-setup.exe

set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="${BUILD_VERSION:-1.0.0}"

# Sanity: tauri CLI installed?
if ! command -v cargo >/dev/null 2>&1; then
  echo "✖ Rust toolchain not found. Install via rustup (https://rustup.rs)."
  exit 1
fi
if ! cargo tauri --version >/dev/null 2>&1; then
  echo "▶ Installing tauri-cli (one-time)…"
  cargo install tauri-cli --version "^2.0.0"
fi

# Stamp the version into tauri.conf.json so the installer + Add/Remove Programs entry match.
python3 - <<EOF
import json, pathlib
p = pathlib.Path("win/src-tauri/tauri.conf.json")
cfg = json.loads(p.read_text())
cfg["version"] = "${VERSION}"
p.write_text(json.dumps(cfg, indent=2) + "\n")
EOF

# Build the Next.js production bundle as a static export so Tauri can embed it.
# (The Next.js app uses dynamic features today; for a static-exportable build, run with
# `output: 'export'` in next.config.ts. Until then, Tauri can also point at a live URL
# via devUrl + a frontendDist that contains a redirect shim.)
( cd web && npm run build )

# Build for the current host platform. On Windows: .msi + .exe. On macOS: .dmg + .app.
( cd win && cargo tauri build )

echo
echo "▶ Done. Artifacts under win/src-tauri/target/release/bundle/"
echo "    Windows users: distribute the .msi from GitHub Releases."
echo "    Right-click the .exe → Properties → Unblock if Windows flagged it on download."
