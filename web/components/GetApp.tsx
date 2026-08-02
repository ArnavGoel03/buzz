"use client";

import Link from "next/link";
import { useState } from "react";
import { ArrowDownToLine, Check, Share, Plus, X } from "lucide-react";
import { useInstall } from "@/lib/use-install";
import { INSTALL_PATH } from "@/lib/app-links";

/**
 * The install CTA. Every "get the app" surface on the site renders this, so the
 * offer is always correct for the browser looking at it:
 *
 *   Chrome / Edge / Android  one tap, native install prompt
 *   Safari on iOS            share sheet steps, which is the only way iOS installs
 *   anything else            straight to /download, the canonical anchor
 *   already installed        nothing, or a quiet confirmation
 */
export default function GetApp({
  variant = "primary",
  label = "Install Buzz",
  className = "",
  showWhenInstalled = false,
}: {
  variant?: "primary" | "secondary" | "compact";
  label?: string;
  className?: string;
  showWhenInstalled?: boolean;
}) {
  const { mode, install, ready } = useInstall();
  const [sheet, setSheet] = useState(false);

  const base =
    "inline-flex items-center justify-center gap-2 font-semibold transition-colors";
  const sizing = {
    primary: "h-11 px-5 rounded-xl bg-[var(--color-accent)] text-[var(--color-accent-ink)] text-sm hover:brightness-110",
    secondary:
      "h-11 px-5 rounded-xl bg-[var(--color-surface)] border border-[var(--color-border-strong)] text-sm hover:border-[var(--color-border-bright)]",
    compact: "h-9 px-3.5 rounded-lg bg-[var(--color-accent)] text-[var(--color-accent-ink)] text-xs",
  }[variant];
  const cls = `${base} ${sizing} ${className}`;

  // Render the neutral link until the browser has been sniffed, so the button never
  // flashes the wrong offer on hydration.
  if (!ready) {
    return (
      <Link href={INSTALL_PATH} className={cls}>
        <ArrowDownToLine size={15} strokeWidth={2.4} />
        {label}
      </Link>
    );
  }

  if (mode === "installed") {
    if (!showWhenInstalled) return null;
    return (
      <span className={`${base} ${sizing} opacity-60 pointer-events-none ${className}`}>
        <Check size={15} strokeWidth={2.6} />
        Installed
      </span>
    );
  }

  if (mode === "prompt") {
    return (
      <button type="button" onClick={() => void install()} className={cls}>
        <ArrowDownToLine size={15} strokeWidth={2.4} />
        {label}
      </button>
    );
  }

  if (mode === "ios") {
    return (
      <>
        <button type="button" onClick={() => setSheet(true)} className={cls}>
          <Plus size={15} strokeWidth={2.6} />
          {label}
        </button>
        {sheet && <IOSSheet onClose={() => setSheet(false)} />}
      </>
    );
  }

  return (
    <Link href={INSTALL_PATH} className={cls}>
      <ArrowDownToLine size={15} strokeWidth={2.4} />
      {label}
    </Link>
  );
}

function IOSSheet({ onClose }: { onClose: () => void }) {
  return (
    <div
      className="fixed inset-0 z-[100] flex items-end justify-center bg-black/70 backdrop-blur-sm"
      onClick={onClose}
      role="dialog"
      aria-modal="true"
      aria-label="Add Buzz to your home screen"
    >
      <div
        className="w-full max-w-md m-3 p-5 rounded-2xl bg-[var(--color-bg-elevated)] border border-[var(--color-border-strong)]"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-start justify-between gap-4">
          <div>
            <h2 className="text-lg font-bold" style={{ fontFamily: "var(--font-display)" }}>
              Add Buzz to your home screen
            </h2>
            <p className="mt-1 text-sm text-[var(--color-text-secondary)]">
              Two taps. It opens full screen like any other app, and it works offline.
            </p>
          </div>
          <button onClick={onClose} aria-label="Close" className="p-1 -mr-1 -mt-1">
            <X size={18} />
          </button>
        </div>

        <ol className="mt-5 grid gap-3 text-sm">
          <Step n={1} icon={<Share size={16} />}>
            Tap the Share button in the Safari toolbar
          </Step>
          <Step n={2} icon={<Plus size={16} />}>
            Scroll down and pick <b>Add to Home Screen</b>
          </Step>
          <Step n={3} icon={<Check size={16} />}>
            Tap <b>Add</b>. Buzz lands on your home screen
          </Step>
        </ol>

        <button
          onClick={onClose}
          className="mt-5 w-full h-11 rounded-xl bg-[var(--color-accent)] text-[var(--color-accent-ink)] font-semibold text-sm"
        >
          Got it
        </button>
      </div>
    </div>
  );
}

function Step({ n, icon, children }: { n: number; icon: React.ReactNode; children: React.ReactNode }) {
  return (
    <li className="flex items-center gap-3">
      <span className="w-7 h-7 shrink-0 rounded-lg bg-[var(--color-surface)] border border-[var(--color-border)] flex items-center justify-center text-[var(--color-accent)]">
        {icon}
      </span>
      <span className="text-[var(--color-text-secondary)]">
        <span className="font-mono text-[10px] text-[var(--color-text-tertiary)] mr-2">{n}</span>
        {children}
      </span>
    </li>
  );
}
