"use client";

import { useEffect, useState } from "react";
import { X, Zap } from "lucide-react";
import { isMobile } from "@/lib/platform";
import { useInstall } from "@/lib/use-install";
import GetApp from "./GetApp";

/**
 * Floating install card on the full-map page, mobile only. The map is the moment the
 * offer makes sense: someone is standing on campus deciding where to walk, which is
 * exactly when having Buzz one tap away is worth something.
 *
 * Hidden once installed, and dismissable for the rest of the session.
 */
export default function MapOverlayCTA() {
  const { mode, ready } = useInstall();
  const [show, setShow] = useState(false);

  useEffect(() => {
    if (!isMobile()) return;
    try {
      if (sessionStorage.getItem("buzz:map-cta-dismissed")) return;
    } catch {
      // Storage blocked. Showing the card once is the better failure.
    }
    setShow(true);
  }, []);

  function dismiss() {
    try {
      sessionStorage.setItem("buzz:map-cta-dismissed", "1");
    } catch { /* see above */ }
    setShow(false);
  }

  if (!show || !ready || mode === "installed" || mode === "manual") return null;

  return (
    <div className="absolute bottom-4 left-4 right-4 z-30 p-4 rounded-2xl bg-[var(--color-bg)]/95 backdrop-blur border border-[var(--color-border-strong)] shadow-2xl flex items-center gap-3">
      <button onClick={dismiss} aria-label="Dismiss" className="shrink-0 text-[var(--color-text-tertiary)]">
        <X size={16} />
      </button>
      <div className="w-10 h-10 rounded-xl bg-[var(--color-accent)] flex items-center justify-center shrink-0">
        <Zap size={18} className="text-[var(--color-accent-ink)]" strokeWidth={2.6} />
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-sm font-bold leading-tight">Keep the map in your pocket</p>
        <p className="text-xs text-[var(--color-text-tertiary)]">Home screen · opens offline</p>
      </div>
      <GetApp variant="compact" label="Install" className="shrink-0" />
    </div>
  );
}
