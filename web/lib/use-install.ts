"use client";

import { useCallback, useEffect, useState } from "react";
import { detectPlatform, isIOSSafari, isStandalone, type Platform } from "./platform";

type InstallPromptEvent = Event & {
  prompt: () => Promise<void>;
  userChoice: Promise<{ outcome: "accepted" | "dismissed" }>;
};

/**
 * How this browser can install Buzz right now:
 *   installed  already running from a home screen or dock, nothing to offer
 *   prompt     Chrome, Edge, and Android can install in one tap
 *   ios        Safari on iOS installs through the share sheet, so show the steps
 *   manual     everything else, send them to /download for the full picture
 */
export type InstallMode = "installed" | "prompt" | "ios" | "manual";

export function useInstall() {
  const [deferred, setDeferred] = useState<InstallPromptEvent | null>(null);
  const [installed, setInstalled] = useState(false);
  const [platform, setPlatform] = useState<Platform>("other");
  const [ios, setIos] = useState(false);
  const [ready, setReady] = useState(false);

  useEffect(() => {
    setPlatform(detectPlatform());
    setIos(isIOSSafari());
    setInstalled(isStandalone());
    setReady(true);

    const onPrompt = (e: Event) => {
      // Keep the event so the install can be triggered from our own button rather
      // than Chrome's mini-infobar, which students routinely ignore.
      e.preventDefault();
      setDeferred(e as InstallPromptEvent);
    };
    const onInstalled = () => {
      setInstalled(true);
      setDeferred(null);
    };

    window.addEventListener("beforeinstallprompt", onPrompt);
    window.addEventListener("appinstalled", onInstalled);
    return () => {
      window.removeEventListener("beforeinstallprompt", onPrompt);
      window.removeEventListener("appinstalled", onInstalled);
    };
  }, []);

  const install = useCallback(async () => {
    if (!deferred) return "unavailable" as const;
    await deferred.prompt();
    const { outcome } = await deferred.userChoice;
    setDeferred(null);
    return outcome;
  }, [deferred]);

  const mode: InstallMode = installed
    ? "installed"
    : deferred
      ? "prompt"
      : ios
        ? "ios"
        : "manual";

  return { mode, platform, install, ready };
}
