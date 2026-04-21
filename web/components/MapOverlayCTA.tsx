"use client";

import { useEffect, useState } from "react";
import { isMobile } from "@/lib/platform";
import { APP_STORE_URL } from "@/lib/app-links";
import { X, Sparkles } from "lucide-react";

// Floating "Better in the app" card on the full-map page. Only renders on mobile
// web (desktop web map is already a great experience). Dismissable per-session.
export default function MapOverlayCTA() {
  const [show, setShow] = useState(false);

  useEffect(() => {
    if (!isMobile()) return;
    if (sessionStorage.getItem("buzz:map-cta-dismissed")) return;
    setShow(true);
  }, []);

  if (!show) return null;

  function dismiss() {
    sessionStorage.setItem("buzz:map-cta-dismissed", "1");
    setShow(false);
  }

  return (
    <div className="absolute bottom-4 left-4 right-4 z-30 p-4 rounded-2xl bg-[var(--color-bg)]/95 backdrop-blur border border-[var(--color-border-strong)] shadow-2xl flex items-center gap-3">
      <button onClick={dismiss} aria-label="Dismiss" className="shrink-0 text-[var(--color-text-tertiary)]">
        <X size={16} />
      </button>
      <div className="w-10 h-10 rounded-xl bg-[var(--color-accent)] flex items-center justify-center shrink-0">
        <Sparkles size={18} className="text-black" strokeWidth={2.6} />
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-sm font-bold leading-tight">The map is smoother in the app</p>
        <p className="text-xs text-[var(--color-text-tertiary)]">Native MapKit · 60fps · live pins</p>
      </div>
      <a
        href={APP_STORE_URL}
        className="shrink-0 h-9 px-3.5 bg-[var(--color-accent)] text-black rounded-lg text-xs font-black flex items-center"
      >
        Get app
      </a>
    </div>
  );
}
