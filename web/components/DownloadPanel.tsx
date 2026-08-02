"use client";

import Image from "next/image";
import { Bell, WifiOff, Zap, Smartphone } from "lucide-react";
import GetApp from "./GetApp";
import NotifyForm from "./NotifyForm";
import { useInstall } from "@/lib/use-install";
import type { DesktopBuild } from "@/lib/releases";

/**
 * The install anchor. Everything that says "get the app" anywhere on the site lands
 * here, so this page has to answer one question correctly for whoever opened it:
 * what do I tap, right now, on this device.
 */
export default function DownloadPanel({ builds }: { builds: DesktopBuild[] }) {
  const { mode, platform, ready } = useInstall();

  const onPhone = platform === "ios" || platform === "android";
  const installed = ready && mode === "installed";

  return (
    <div className="max-w-2xl mx-auto px-4 md:px-8 py-10">
      <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-[var(--color-text-tertiary)]">
        § Get Buzz
      </p>
      <h1
        className="mt-3 font-display font-medium tracking-[-0.02em] leading-[1] text-4xl md:text-5xl"
        style={{ fontFamily: "var(--font-display)" }}
      >
        {installed ? "You already have it." : "Two taps. No app store."}
      </h1>
      <p className="mt-4 text-[var(--color-text-secondary)] max-w-xl">
        {installed
          ? "Buzz is on your home screen. Open it any time, even with no signal."
          : "Buzz installs straight from this page. It lands on your home screen, opens full screen, and keeps working when campus wifi does not."}
      </p>

      <div className="mt-7 flex flex-wrap items-center gap-3">
        <GetApp label={onPhone ? "Add Buzz to home screen" : "Install Buzz"} showWhenInstalled />
        {!installed && (
          <a
            href="/feed?src=download"
            className="h-11 px-5 rounded-xl border border-[var(--color-border-strong)] inline-flex items-center text-sm font-semibold hover:border-[var(--color-border-bright)]"
          >
            Just browse first
          </a>
        )}
      </div>

      <ul className="mt-8 grid sm:grid-cols-2 gap-3">
        <Perk icon={<Zap size={16} />} title="Nothing to download">
          It is the same site you are on. Installing takes a second and about a megabyte.
        </Perk>
        <Perk icon={<WifiOff size={16} />} title="Works offline">
          Tonight&apos;s feed is cached, so it opens in a basement party with one bar.
        </Perk>
        <Perk icon={<Bell size={16} />} title="Free-food alerts">
          Turn on notifications and Buzz pings you when food drops near you.
        </Perk>
        <Perk icon={<Smartphone size={16} />} title="Every device">
          iPhone, Android, laptop. Same account, same feed, no separate build to chase.
        </Perk>
      </ul>

      {ready && !onPhone && !installed && (
        <section className="mt-10 p-5 rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)] flex flex-col sm:flex-row items-center gap-5">
          <Image
            src="/qr-download.svg"
            alt="QR code linking to the Buzz install page"
            width={132}
            height={132}
            className="shrink-0 rounded-lg bg-[var(--color-bg-elevated)] p-2"
            unoptimized
          />
          <div>
            <p className="text-sm font-bold">Put it on your phone</p>
            <p className="mt-1 text-sm text-[var(--color-text-secondary)]">
              Buzz is most useful in your pocket, walking past a quad. Scan this and install
              there, then come back to this tab.
            </p>
          </div>
        </section>
      )}

      {builds.length > 0 && (
        <section className="mt-10">
          <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-[var(--color-text-tertiary)] mb-3">
            § Desktop builds
          </p>
          <ul className="rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)] overflow-hidden divide-y divide-[var(--color-border)]">
            {builds.map((b) => (
              <li key={b.url} className="p-4 flex items-center justify-between gap-3">
                <div>
                  <p className="text-sm font-bold">{b.label}</p>
                  <p className="font-mono text-[11px] text-[var(--color-text-tertiary)] mt-0.5">
                    {b.version} · {b.size}
                  </p>
                </div>
                <a
                  href={b.url}
                  className="h-9 px-3.5 shrink-0 rounded-lg border border-[var(--color-border-strong)] text-xs font-semibold inline-flex items-center hover:border-[var(--color-border-bright)]"
                >
                  Download
                </a>
              </li>
            ))}
          </ul>
        </section>
      )}

      <section className="mt-10">
        <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-[var(--color-text-tertiary)] mb-3">
          § Not your campus yet
        </p>
        <div className="p-5 rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)]">
          <p className="text-sm text-[var(--color-text-secondary)]">
            Buzz only works if the events on your campus are actually in it, so we open one
            school at a time. Leave your school email and we will tell you when yours is next.
          </p>
          <div className="mt-4">
            <NotifyForm />
          </div>
        </div>
      </section>

      <p className="mt-10 text-xs text-[var(--color-text-tertiary)] max-w-xl">
        No App Store or Play Store listing yet. When there is one, it will be linked here
        first. Installing from this page gets you the same thing today, and it updates
        itself.
      </p>

      <div className="h-16 md:h-8" />
    </div>
  );
}

function Perk({ icon, title, children }: { icon: React.ReactNode; title: string; children: React.ReactNode }) {
  return (
    <li className="p-4 rounded-xl bg-[var(--color-surface)] border border-[var(--color-border)]">
      <div className="flex items-center gap-2">
        <span className="text-[var(--color-accent)]">{icon}</span>
        <p className="text-sm font-bold">{title}</p>
      </div>
      <p className="mt-1.5 text-xs text-[var(--color-text-tertiary)] leading-relaxed">{children}</p>
    </li>
  );
}
