"use client";

export type Platform = "ios" | "android" | "mac" | "other";

export function detectPlatform(): Platform {
  if (typeof navigator === "undefined") return "other";
  const ua = navigator.userAgent;
  if (/iPad|iPhone|iPod/.test(ua)) return "ios";
  if (/Android/.test(ua)) return "android";
  if (/Macintosh/.test(ua)) return "mac";
  return "other";
}

export function isMobile(): boolean {
  const p = detectPlatform();
  return p === "ios" || p === "android";
}
