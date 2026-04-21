"use client";

import { useEffect } from "react";
import Link from "next/link";
import { RotateCcw, Sparkles } from "lucide-react";
import Wordmark from "@/components/Wordmark";

// Bespoke error page — shown when a Server Component throws. Same visual language
// as the 404 so error states don't break the product's aesthetic.
export default function Error({ error, reset }: { error: Error & { digest?: string }; reset: () => void }) {
  useEffect(() => {
    // Production: hook this into Sentry or your chosen reporter.
    console.error("[buzz] unhandled error", error);
  }, [error]);

  return (
    <main className="relative min-h-screen flex flex-col items-center justify-center px-6 text-center overflow-hidden">
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          background:
            "radial-gradient(circle at 50% 30%, oklch(0.70 0.24 25 / 0.14), transparent 55%)",
          filter: "blur(40px)",
        }}
      />
      <div className="relative max-w-lg">
        <p className="font-mono text-[11px] uppercase tracking-[0.24em] text-[var(--color-live)]">
          Something broke · on our side
        </p>
        <h1
          className="mt-5 font-display font-medium tracking-[-0.02em] text-4xl md:text-5xl leading-tight"
          style={{ fontFamily: "var(--font-display)" }}
        >
          We hit an error loading this page.
        </h1>
        <p className="mt-4 text-[var(--color-text-secondary)]">
          Not your fault. Our servers logged this — we&apos;ll fix it. Try again
          or head back to the feed.
        </p>
        {error.digest && (
          <p className="mt-3 font-mono text-[10px] text-[var(--color-text-quaternary)]">
            incident · {error.digest}
          </p>
        )}
        <div className="mt-8 flex flex-wrap justify-center gap-3">
          <button
            onClick={reset}
            className="inline-flex items-center gap-2 h-11 px-5 rounded-xl bg-[var(--color-accent)] text-black font-semibold text-sm"
          >
            <RotateCcw size={14} /> Try again
          </button>
          <Link
            href="/"
            className="inline-flex items-center gap-2 h-11 px-5 rounded-xl bg-[var(--color-surface)] border border-[var(--color-border-strong)] font-semibold text-sm"
          >
            <Sparkles size={14} /> Back home
          </Link>
        </div>
      </div>
      <div className="absolute bottom-8">
        <Wordmark />
      </div>
    </main>
  );
}
