"use client";

import { useEffect, useState } from "react";

/**
 * PWA bootstrap — registers the service worker, captures `beforeinstallprompt`,
 * subscribes the user to web push once they accept. Drops a small "Add Buzz to
 * Home Screen" CTA when the OS says the app is installable.
 *
 * Mount once at the root layout.
 */
export function PWAInstaller() {
  const [installable, setInstallable] = useState<BeforeInstallPromptEvent | null>(null);
  const [dismissed, setDismissed] = useState(false);

  useEffect(() => {
    if (typeof window === "undefined") return;
    if ("serviceWorker" in navigator) {
      navigator.serviceWorker.register("/sw.js").catch(() => {});
    }
    const onPrompt = (e: Event) => {
      e.preventDefault();
      setInstallable(e as BeforeInstallPromptEvent);
    };
    window.addEventListener("beforeinstallprompt", onPrompt);
    return () => window.removeEventListener("beforeinstallprompt", onPrompt);
  }, []);

  if (!installable || dismissed) return null;

  return (
    <div
      style={{
        position: "fixed", bottom: 16, left: 16, right: 16, zIndex: 40,
        background: "var(--color-surface)", border: "1px solid var(--color-border)",
        borderRadius: 16, padding: 16, display: "flex", alignItems: "center", gap: 12,
        maxWidth: 560, marginInline: "auto",
      }}
    >
      <div style={{ fontSize: 28 }}>✨</div>
      <div style={{ flex: 1 }}>
        <div style={{ fontWeight: 700 }}>Install Buzz</div>
        <div style={{ fontSize: 13, color: "var(--color-text-secondary)" }}>
          Add to your home screen. Works offline after first load.
        </div>
      </div>
      <button
        onClick={async () => {
          await installable.prompt();
          await installable.userChoice;
          setInstallable(null);
        }}
        style={{
          padding: "10px 16px", borderRadius: 12, background: "var(--color-accent)",
          color: "#000", fontWeight: 700, border: 0, cursor: "pointer",
        }}
      >
        Install
      </button>
      <button
        onClick={() => setDismissed(true)}
        aria-label="Dismiss"
        style={{
          padding: 6, background: "transparent", border: 0, color: "var(--color-text-tertiary)",
          cursor: "pointer", fontSize: 18,
        }}
      >
        ✕
      </button>
    </div>
  );
}

// Type augmentation for the `beforeinstallprompt` event (TS doesn't ship it by default).
interface BeforeInstallPromptEvent extends Event {
  readonly platforms: string[];
  readonly userChoice: Promise<{ outcome: "accepted" | "dismissed"; platform: string }>;
  prompt(): Promise<void>;
}
