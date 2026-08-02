"use client";

import Link from "next/link";
import { ArrowRight } from "lucide-react";
import GetApp from "./GetApp";
import { useInstall } from "@/lib/use-install";
import { INSTALL_PATH } from "@/lib/app-links";

/**
 * The closing band on the feed-shaped pages. Once Buzz is installed there is nothing
 * left to sell, so the whole strip disappears rather than nagging someone who already
 * said yes.
 */
export default function AppPushStrip() {
  const { mode, ready } = useInstall();
  if (ready && mode === "installed") return null;

  return (
    <section className="px-4 md:px-8 py-10">
      <div className="rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface)] p-6 md:p-8 flex flex-col md:flex-row md:items-center gap-6">
        <div className="flex-1">
          <h2
            className="font-display font-medium tracking-[-0.02em] text-2xl md:text-3xl leading-[1.05]"
            style={{ fontFamily: "var(--font-display)" }}
          >
            Keep Buzz on your home screen.
          </h2>
          <p className="mt-2 text-sm text-[var(--color-text-secondary)] max-w-md">
            Two taps, no app store, works offline. The free food goes fast and the feed is
            faster when you are not hunting for a tab.
          </p>
        </div>
        <div className="flex flex-wrap items-center gap-3 shrink-0">
          <GetApp />
          <Link
            href={INSTALL_PATH}
            className="inline-flex items-center gap-1.5 font-mono text-xs text-[var(--color-text-tertiary)] hover:text-[var(--color-text)]"
          >
            Details <ArrowRight size={12} />
          </Link>
        </div>
      </div>
    </section>
  );
}
