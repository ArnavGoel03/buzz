"use client";

import { useState } from "react";
import { Check, Link2, Share } from "lucide-react";
import { absoluteUrl } from "@/lib/site";

/**
 * Sharing is how a campus app spreads: one person sends a party to a group chat and
 * six people arrive who had never opened Buzz. So the share affordance sits on every
 * event and org page rather than behind a menu.
 *
 * Uses the native share sheet where it exists (every phone), falls back to copying the
 * link (every desktop).
 */
export default function ShareButton({
  kind,
  id,
  title,
  label = "Share",
}: {
  kind: "e" | "o" | "u";
  id: string;
  title: string;
  label?: string;
}) {
  const [copied, setCopied] = useState(false);
  const url = absoluteUrl(`/${kind}/${id}?src=share`);

  async function share() {
    if (typeof navigator !== "undefined" && navigator.share) {
      try {
        await navigator.share({ title, url });
        return;
      } catch {
        // Cancelling the sheet lands here too, so fall through to copying quietly.
      }
    }
    try {
      await navigator.clipboard.writeText(url);
      setCopied(true);
      window.setTimeout(() => setCopied(false), 2000);
    } catch {
      // Clipboard blocked (insecure context, or permission denied). The link is
      // already in the address bar, so there is nothing useful left to do.
    }
  }

  return (
    <button
      type="button"
      onClick={share}
      className="inline-flex items-center gap-2 h-12 px-5 rounded-xl bg-[var(--color-accent)] text-[var(--color-accent-ink)] font-bold text-base hover:brightness-110"
    >
      {copied ? <Check size={18} strokeWidth={2.6} /> : <Share size={18} strokeWidth={2.6} />}
      {copied ? "Link copied" : label}
    </button>
  );
}

/** Quieter variant for dense rows, where a full-height button would dominate. */
export function ShareLink({ kind, id, title }: { kind: "e" | "o" | "u"; id: string; title: string }) {
  const [copied, setCopied] = useState(false);
  const url = absoluteUrl(`/${kind}/${id}?src=share`);

  async function share() {
    if (typeof navigator !== "undefined" && navigator.share) {
      try {
        await navigator.share({ title, url });
        return;
      } catch { /* cancelled, fall through */ }
    }
    try {
      await navigator.clipboard.writeText(url);
      setCopied(true);
      window.setTimeout(() => setCopied(false), 2000);
    } catch { /* nothing useful to do */ }
  }

  return (
    <button
      type="button"
      onClick={share}
      className="inline-flex items-center gap-1.5 font-mono text-xs text-[var(--color-text-tertiary)] hover:text-[var(--color-text)]"
    >
      {copied ? <Check size={12} /> : <Link2 size={12} />}
      {copied ? "Copied" : "Share"}
    </button>
  );
}
