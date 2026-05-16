# Buzz 1.0.0

The first public Buzz desktop build. Native Mac app + Windows installer, both free,
both shipped outside the App Store / Microsoft Store. No fees, no signing certs,
no telemetry.

## Downloads

| Platform | File | Notes |
|---|---|---|
| **macOS 14+** | `Buzz-1.0.0.dmg` | Ad-hoc signed. Open the DMG → drag Buzz into Applications. On first launch, **right-click Buzz → Open → Open**. After that it's trusted. |
| **macOS (zip)** | `Buzz-1.0.0.zip` | Same .app, zipped for Sparkle-style auto-update once that lands. |
| **Windows 10 / 11 x64** | `Buzz_1.0.0_x64_en-US.msi` | Unsigned installer. Windows SmartScreen may flag the download — click **More info → Run anyway** once. |
| **Windows (.exe)** | `Buzz_1.0.0_x64-setup.exe` | NSIS installer alternative. Same trust model. |

## What's in this build

- Full landing, event preview, organization preview, profile preview, and campus
  landing pages, all rendered server-side and shareable as universal links.
- Admin dashboard for org officers, server-gated.
- Backend hardened against ~70 security findings from a 12-round red-team pass.

## Why no App Store?

Apple charges $99/year for the Developer Program; Microsoft $19 + $300–500/yr for a
code-signing cert. Buzz is free and built solo — none of those fees buy anything
the user cares about. The trade-off: a one-time **right-click → Open** on Mac and
a one-time **More info → Run anyway** on Windows. After that, both apps update
through the GitHub Releases pipeline.

## Source

[github.com/ArnavGoel03/buzz](https://github.com/ArnavGoel03/buzz)
