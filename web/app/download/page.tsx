import type { Metadata } from "next";
import Link from "next/link";
import { Apple, MonitorDown, ArrowDownToLine } from "lucide-react";

export const metadata: Metadata = {
  title: "Download Buzz",
  description: "Buzz for Mac and Windows. Free. No App Store, no Microsoft Store — install in one click.",
  alternates: { canonical: "https://buzz.app/download" },
  openGraph: {
    title: "Download Buzz",
    description: "Buzz for Mac and Windows. Free. Direct download.",
    url: "https://buzz.app/download",
    images: ["/og.png"],
  },
};

const RELEASES_BASE = "https://github.com/ArnavGoel03/buzz/releases/latest/download";
const VERSION = "1.0.0";

/**
 * Direct-download landing for the desktop builds.
 *
 * - **Mac**: ad-hoc-signed `.dmg` produced by `scripts/build-mac.sh`. First launch:
 *   right-click → Open, click "Open" on the Gatekeeper dialog. After that it's
 *   trusted and behaves like any other app.
 * - **Windows**: Tauri 2 `.msi` produced by `scripts/build-win.sh`. SmartScreen
 *   may flag the file on first run; click "More info" → "Run anyway".
 *
 * No App Store, no Microsoft Store, no signing fees. Builds are mirrored on the
 * GitHub Releases page; this page links to the `latest/` redirect so the URL
 * stays stable across versions.
 */
export default function DownloadPage() {
  return (
    <main id="main" className="min-h-screen px-6 py-20 max-w-3xl mx-auto">
      <header className="text-center">
        <p className="text-xs font-bold uppercase tracking-[0.24em] text-[var(--color-text-tertiary)]">
          Free · No store required
        </p>
        <h1
          className="mt-3 text-5xl md:text-6xl font-black tracking-tight"
          style={{ fontFamily: "var(--font-display)" }}
        >
          Download Buzz
        </h1>
        <p className="mt-4 text-base text-[var(--color-text-secondary)] max-w-xl mx-auto">
          The full desktop experience. Native on Mac, lightweight Tauri shell on Windows.
          Direct downloads from GitHub Releases — no store gate.
        </p>
      </header>

      <section className="mt-12 grid gap-4 sm:grid-cols-2">
        <DownloadCard
          icon={<Apple size={28} strokeWidth={1.6} />}
          platform="macOS"
          tagline="Universal · 14+"
          primary={{
            href: `${RELEASES_BASE}/Buzz-${VERSION}.dmg`,
            label: "Download .dmg",
            sub: `Buzz-${VERSION}.dmg · ~30 MB`,
          }}
          secondary={{
            href: `${RELEASES_BASE}/Buzz-${VERSION}.zip`,
            label: "or .zip",
          }}
          firstLaunch="Right-click the app → Open → Open again. Required once because Buzz is ad-hoc-signed (no $99 Apple Developer fee). After that, it's trusted permanently."
        />

        <DownloadCard
          icon={<MonitorDown size={28} strokeWidth={1.6} />}
          platform="Windows"
          tagline="10 / 11 · x64"
          primary={{
            href: `${RELEASES_BASE}/Buzz_${VERSION}_x64_en-US.msi`,
            label: "Download .msi",
            sub: `Buzz_${VERSION}_x64.msi · ~10 MB`,
          }}
          secondary={{
            href: `${RELEASES_BASE}/Buzz_${VERSION}_x64-setup.exe`,
            label: "or NSIS .exe",
          }}
          firstLaunch="If Windows SmartScreen flags the installer, click 'More info' → 'Run anyway'. Required once because Buzz isn't signed with a $300/yr commercial cert. After install, it runs without warnings."
        />
      </section>

      <section className="mt-16 grid gap-3 text-sm text-[var(--color-text-secondary)]">
        <h2 className="text-xs font-bold uppercase tracking-[0.2em] text-[var(--color-text-tertiary)]">
          Looking for the phone app?
        </h2>
        <div className="flex flex-wrap gap-2">
          <Link
            href="/sign-in"
            className="px-4 py-2 rounded-full bg-[var(--color-surface)] border border-[var(--color-border)] text-sm font-semibold hover:border-[var(--color-accent)]"
          >
            iOS · TestFlight (coming soon)
          </Link>
          <Link
            href="/sign-in"
            className="px-4 py-2 rounded-full bg-[var(--color-surface)] border border-[var(--color-border)] text-sm font-semibold hover:border-[var(--color-accent)]"
          >
            Android · APK (coming soon)
          </Link>
        </div>
      </section>

      <section className="mt-12">
        <h2
          className="text-xl font-bold mb-3"
          style={{ fontFamily: "var(--font-display)" }}
        >
          Why no App Store?
        </h2>
        <p className="text-sm text-[var(--color-text-secondary)] leading-relaxed">
          Apple charges $99/year for the Developer Program; Microsoft charges $19 + signing
          certs run $300–500/year. Buzz is free and built solo — none of those fees buy
          anything users care about. Ad-hoc signing and SmartScreen warnings are the
          one-time cost of the free-tier path. The build pipeline is documented in the{" "}
          <a
            href="https://github.com/ArnavGoel03/buzz"
            className="text-[var(--color-accent)] underline underline-offset-4 hover:no-underline"
          >
            repository
          </a>{" "}
          for anyone who wants to audit the binary.
        </p>
      </section>
    </main>
  );
}

function DownloadCard({
  icon,
  platform,
  tagline,
  primary,
  secondary,
  firstLaunch,
}: {
  icon: React.ReactNode;
  platform: string;
  tagline: string;
  primary: { href: string; label: string; sub: string };
  secondary?: { href: string; label: string };
  firstLaunch: string;
}) {
  return (
    <div className="rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface)] p-6 flex flex-col">
      <div className="flex items-center gap-3">
        <div className="w-12 h-12 rounded-xl bg-[var(--color-accent-dim)] text-[var(--color-accent)] flex items-center justify-center">
          {icon}
        </div>
        <div>
          <p className="text-lg font-bold" style={{ fontFamily: "var(--font-display)" }}>
            {platform}
          </p>
          <p className="text-xs text-[var(--color-text-tertiary)] font-mono uppercase tracking-wider">
            {tagline}
          </p>
        </div>
      </div>

      <a
        href={primary.href}
        className="mt-6 inline-flex items-center justify-center gap-2 h-12 rounded-xl bg-[var(--color-accent)] text-black font-bold hover:brightness-110 transition"
      >
        <ArrowDownToLine size={18} strokeWidth={2.4} />
        {primary.label}
      </a>
      <p className="mt-1.5 text-[11px] text-center text-[var(--color-text-tertiary)] font-mono">
        {primary.sub}
      </p>

      {secondary && (
        <a
          href={secondary.href}
          className="mt-2 text-center text-xs text-[var(--color-text-secondary)] hover:text-[var(--color-text)] underline underline-offset-4"
        >
          {secondary.label}
        </a>
      )}

      <div className="mt-5 pt-5 border-t border-[var(--color-border)]">
        <p className="text-xs font-bold uppercase tracking-wider text-[var(--color-text-tertiary)] mb-2">
          First launch
        </p>
        <p className="text-xs text-[var(--color-text-secondary)] leading-relaxed">
          {firstLaunch}
        </p>
      </div>
    </div>
  );
}
