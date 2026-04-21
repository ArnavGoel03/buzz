import Link from "next/link";
import { Sparkles, ArrowRight } from "lucide-react";
import Wordmark from "@/components/Wordmark";

// Bespoke 404 — uses the same editorial typography + ambient glow as the landing.
// Default Next.js "Page not found" is a dead giveaway that no one sweated the edges.
export const metadata = { title: "Not found", robots: { index: false } };

export default function NotFound() {
  return (
    <main className="relative min-h-screen flex flex-col items-center justify-center px-6 text-center overflow-hidden">
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          background:
            "radial-gradient(circle at 50% 30%, oklch(0.65 0.17 85 / 0.14), transparent 55%)",
          filter: "blur(40px)",
        }}
      />
      <div className="relative">
        <div
          className="font-display tabular font-medium leading-none text-[clamp(6rem,18vw,14rem)]"
          style={{ fontFamily: "var(--font-display)" }}
        >
          4
          <span className="italic text-[var(--color-accent)]" style={{ fontVariationSettings: "'WONK' 1" }}>0</span>
          4
        </div>
        <p className="mt-3 font-mono text-[11px] uppercase tracking-[0.2em] text-[var(--color-text-tertiary)]">
          Nothing at this address
        </p>
        <h1
          className="mt-6 font-display font-medium tracking-[-0.02em] text-3xl md:text-4xl max-w-lg mx-auto leading-tight"
          style={{ fontFamily: "var(--font-display)" }}
        >
          That event ended, moved, or never existed.
        </h1>
        <p className="mt-4 max-w-md mx-auto text-[var(--color-text-secondary)]">
          If you got here from a shared link, the host probably deleted the event
          or it was invite-only and you&apos;re not on the list.
        </p>
        <div className="mt-8 flex flex-wrap justify-center gap-3">
          <Link
            href="/"
            className="inline-flex items-center gap-2 h-11 px-5 rounded-xl bg-[var(--color-accent)] text-black font-semibold text-sm"
          >
            <Sparkles size={14} strokeWidth={2.6} /> Back to Buzz
            <ArrowRight size={14} />
          </Link>
          <Link
            href="/feed"
            className="inline-flex items-center gap-2 h-11 px-5 rounded-xl bg-[var(--color-surface)] border border-[var(--color-border-strong)] font-semibold text-sm"
          >
            Browse the feed
          </Link>
        </div>
      </div>
      <div className="absolute bottom-8">
        <Wordmark />
      </div>
    </main>
  );
}
