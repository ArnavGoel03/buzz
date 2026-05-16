# Buzz for Windows

Native-feel desktop wrapper around the Buzz web app, packaged with **Tauri 2**.

Why Tauri over Electron: ~10 MB installer (vs. ~150 MB), uses the system WebView2
(already on Windows 10/11), boots in milliseconds, and produces a real Windows
installer (`.msi` or NSIS `.exe`).

**No Microsoft Store fee. No code-signing cert required.** Ship the `.exe` / `.msi`
straight from GitHub Releases. Windows SmartScreen will show a warning on the first
download from an unknown publisher; users click "More info" → "Run anyway" once. Same
trade-off as the ad-hoc-signed Mac `.app`.

## One-time setup

You need Rust + the Tauri CLI. The Tauri docs cover the platform-specific bits, but
on a fresh Windows 11 machine:

```powershell
# 1. Microsoft C++ Build Tools (one-time).
winget install Microsoft.VisualStudio.2022.BuildTools

# 2. WebView2 Runtime (preinstalled on Win 11; install on Win 10 if missing).
winget install Microsoft.EdgeWebView2Runtime

# 3. Rust (stable toolchain).
winget install Rustlang.Rustup
rustup default stable

# 4. Tauri CLI.
cargo install tauri-cli --version "^2.0.0"
```

On macOS or Linux for cross-platform iteration, the same `cargo install tauri-cli` plus
Xcode CLT (macOS) or `libgtk-3-dev libwebkit2gtk-4.1-dev` (Linux) covers it.

## Run in dev

The dev shell points at the live Next.js dev server. From `win/`:

```bash
cargo tauri dev
```

Spins up a desktop window pointing at `http://localhost:3000` — start the Next.js
dev server first (`cd ../web && npm run dev`).

## Build a release installer

```bash
cargo tauri build
```

Outputs:
- `win/src-tauri/target/release/bundle/msi/Buzz_<version>_x64_en-US.msi` — recommended.
- `win/src-tauri/target/release/bundle/nsis/Buzz_<version>_x64-setup.exe` — alternative.
- `win/src-tauri/target/release/buzz.exe` — the raw binary (no installer).

On macOS the same command produces `.app` + `.dmg` in `target/release/bundle/{macos,dmg}`,
but the canonical Mac build path is `scripts/build-mac.sh` (uses the native SwiftUI app —
not this Tauri shell).

## Ship

1. Bump `version` in `src-tauri/tauri.conf.json`.
2. Run `cargo tauri build`.
3. Upload the `.msi` to GitHub Releases on a `vX.Y.Z` tag.
4. Update the in-app updater URL (when wired) to point at the latest release tag.

## When to add code signing

Code signing eliminates the SmartScreen warning. For free-tier paths:
- **SignPath.io** — free for OSS projects (apply at signpath.io/foundation).
- **Microsoft Trusted Signing** — pay-per-month service (~$10/mo); cheaper than buying a cert.
- **Self-signed cert** — no Trust improvement; not worth doing.

Until signing is wired, SmartScreen is the cost of the free-tier path. Document the
"Run anyway" workflow in the release notes so users aren't confused.
