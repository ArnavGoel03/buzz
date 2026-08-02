"use client";

import { useEffect } from "react";

/**
 * Registers the service worker. Two payoffs: Chrome and Edge only offer the install
 * prompt to sites that have one, and repeat visits paint from cache instead of the
 * network. Registration is deferred to load so it never competes with first paint.
 */
export default function PWA() {
  useEffect(() => {
    if (!("serviceWorker" in navigator)) return;
    if (process.env.NODE_ENV !== "production") return;

    const register = () => {
      navigator.serviceWorker.register("/sw.js").catch(() => {
        // A failed registration costs nothing at runtime, so stay quiet.
      });
    };

    if (document.readyState === "complete") register();
    else window.addEventListener("load", register, { once: true });
  }, []);

  return null;
}
