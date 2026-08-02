"use client";

export type Platform = "ios" | "android" | "mac" | "windows" | "other";

export function detectPlatform(): Platform {
  if (typeof navigator === "undefined") return "other";
  const ua = navigator.userAgent;
  // iPadOS 13+ reports a Macintosh UA, so touch points are the only reliable tell.
  const iPadOS = /Macintosh/.test(ua) && navigator.maxTouchPoints > 1;
  if (/iPad|iPhone|iPod/.test(ua) || iPadOS) return "ios";
  if (/Android/.test(ua)) return "android";
  if (/Macintosh/.test(ua)) return "mac";
  if (/Windows/.test(ua)) return "windows";
  return "other";
}

export function isMobile(): boolean {
  const p = detectPlatform();
  return p === "ios" || p === "android";
}

/** True once the site is running from a home-screen or desktop install. */
export function isStandalone(): boolean {
  if (typeof window === "undefined") return false;
  return (
    window.matchMedia("(display-mode: standalone)").matches ||
    // iOS Safari predates the display-mode media query.
    (window.navigator as Navigator & { standalone?: boolean }).standalone === true
  );
}

/**
 * Add to Home Screen exists only in Safari on iOS. Chrome, Firefox, and in-app
 * browsers on iOS cannot install, so they get routed somewhere useful instead of
 * being shown steps that do not apply.
 */
export function isIOSSafari(): boolean {
  if (typeof navigator === "undefined") return false;
  const ua = navigator.userAgent;
  if (detectPlatform() !== "ios") return false;
  return /Safari/.test(ua) && !/CriOS|FxiOS|EdgiOS|OPiOS|Instagram|FBAN|FBAV|Snapchat/.test(ua);
}
