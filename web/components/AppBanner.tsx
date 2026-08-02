"use client";

import { useEffect, useState } from "react";
import { X, Zap } from "lucide-react";
import GetApp from "./GetApp";
import { useInstall } from "@/lib/use-install";

/**
 * Sticky install strip. It only appears when the browser can actually install Buzz,
 * so nobody is nagged toward something they already did or cannot do, and a dismissal
 * is remembered.
 */
export default function AppBanner() {
  const { mode, ready } = useInstall();
  const [dismissed, setDismissed] = useState(true);

  useEffect(() => {
    // Safari Private Mode and cookie-blocked browsers throw on localStorage access,
    // so treat a failure as "not dismissed" and show the strip.
    try {
      setDismissed(localStorage.getItem("buzz:banner-dismissed") === "1");
    } catch {
      setDismissed(false);
    }
  }, []);

  function dismiss() {
    try {
      localStorage.setItem("buzz:banner-dismissed", "1");
    } catch { /* see above */ }
    setDismissed(true);
  }

  if (dismissed || !ready) return null;
  if (mode === "installed" || mode === "manual") return null;

  return (
    <div className="sticky top-0 z-50 bg-[var(--color-accent)] text-[var(--color-accent-ink)]">
      <div className="flex items-center gap-3 px-4 py-2.5 max-w-7xl mx-auto">
        <button onClick={dismiss} aria-label="Dismiss" className="p-0.5 -ml-1">
          <X size={16} />
        </button>
        <div className="w-8 h-8 rounded-lg bg-black/10 flex items-center justify-center">
          <Zap size={16} strokeWidth={2.6} />
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-xs font-bold leading-tight">Put Buzz on your home screen</p>
          <p className="text-[11px] opacity-80 truncate">Two taps, works offline, no app store</p>
        </div>
        <GetApp
          variant="compact"
          label="Install"
          className="shrink-0 bg-black text-white hover:brightness-125"
        />
      </div>
    </div>
  );
}
