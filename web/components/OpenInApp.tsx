"use client";

import { useEffect, useState } from "react";
import { Sparkles } from "lucide-react";
import { detectPlatform, isMobile } from "@/lib/platform";
import { APP_STORE_URL, PLAY_STORE_URL, CUSTOM_SCHEME } from "@/lib/app-links";

// Bold "Open in Buzz" CTA used on event / org pages. Tries the custom URL scheme
// first (opens the native app if installed) and falls back to the store after 1.2s.
// On desktop it's a plain store-download CTA.
export default function OpenInApp({
  kind,
  id,
  label = "Open in Buzz",
}: {
  kind: "e" | "o" | "u";
  id: string;
  label?: string;
}) {
  const [mobile, setMobile] = useState(false);
  const [storeUrl, setStoreUrl] = useState(APP_STORE_URL);

  useEffect(() => {
    setMobile(isMobile());
    const p = detectPlatform();
    if (p === "android") setStoreUrl(PLAY_STORE_URL);
    else setStoreUrl(APP_STORE_URL);
  }, []);

  function handleOpen(e: React.MouseEvent<HTMLAnchorElement>) {
    if (!mobile) return; // let desktop just hit store URL directly
    e.preventDefault();
    const scheme = `${CUSTOM_SCHEME}${kind}/${id}`;
    const fallbackTimer = window.setTimeout(() => {
      window.location.href = storeUrl;
    }, 1200);
    // If the scheme launches the app, the page loses focus and we cancel the fallback.
    const onVisibilityChange = () => {
      if (document.visibilityState === "hidden") clearTimeout(fallbackTimer);
    };
    document.addEventListener("visibilitychange", onVisibilityChange, { once: true });
    window.location.href = scheme;
  }

  const targetHref = mobile ? `${CUSTOM_SCHEME}${kind}/${id}` : storeUrl;

  return (
    <a
      href={targetHref}
      onClick={handleOpen}
      className="inline-flex items-center gap-2 h-12 px-5 rounded-xl bg-[var(--color-accent)] text-black font-bold text-base hover:brightness-110"
    >
      <Sparkles size={18} strokeWidth={2.6} />
      {label}
    </a>
  );
}
