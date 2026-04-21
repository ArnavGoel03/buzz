"use client";

import { useEffect, useState } from "react";
import { X, Sparkles } from "lucide-react";
import { detectPlatform } from "@/lib/platform";
import { APP_STORE_URL, PLAY_STORE_URL, MAC_APP_STORE_URL } from "@/lib/app-links";

// Sticky "open in app" strip. Platform-aware: directs iOS to App Store, Android to
// Play, Mac to Mac App Store. Dismissal persisted in localStorage so we don't nag.
export default function AppBanner() {
  const [visible, setVisible] = useState(false);
  const [url, setUrl] = useState(APP_STORE_URL);
  const [label, setLabel] = useState("Get the iPhone app");

  useEffect(() => {
    if (localStorage.getItem("buzz:banner-dismissed") === "1") return;
    const p = detectPlatform();
    if (p === "android") {
      setUrl(PLAY_STORE_URL);
      setLabel("Get the Android app");
    } else if (p === "mac") {
      setUrl(MAC_APP_STORE_URL);
      setLabel("Get the Mac app");
    } else if (p === "ios") {
      setUrl(APP_STORE_URL);
      setLabel("Get the iPhone app");
    } else {
      setLabel("Download Buzz");
    }
    setVisible(true);
  }, []);

  function dismiss() {
    localStorage.setItem("buzz:banner-dismissed", "1");
    setVisible(false);
  }

  if (!visible) return null;

  return (
    <div className="sticky top-0 z-50 bg-[var(--color-accent)] text-black">
      <div className="flex items-center gap-3 px-4 py-2.5 max-w-7xl mx-auto">
        <button onClick={dismiss} aria-label="Dismiss" className="p-0.5 -ml-1">
          <X size={16} />
        </button>
        <div className="w-8 h-8 rounded-lg bg-black/10 flex items-center justify-center">
          <Sparkles size={16} strokeWidth={2.6} />
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-xs font-bold leading-tight">Buzz is better in the app</p>
          <p className="text-[11px] opacity-80 truncate">Real-time, push, chat, check-in</p>
        </div>
        <a
          href={url}
          className="shrink-0 h-8 px-3 bg-black text-white rounded-lg text-xs font-bold flex items-center"
        >
          {label}
        </a>
      </div>
    </div>
  );
}
