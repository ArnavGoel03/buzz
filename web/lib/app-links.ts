// Central source of truth for deep links + store URLs. When Apple assigns real App
// Store IDs post-submission, only this file needs updating.

export const APP_STORE_ID = "TBD"; // iOS App Store numeric ID — replace post-submit
export const APP_STORE_URL = "https://apps.apple.com/app/id0000000000"; // placeholder
export const MAC_APP_STORE_URL = "https://apps.apple.com/app/id0000000000"; // placeholder
export const PLAY_STORE_URL = "https://play.google.com/store/apps/details?id=app.buzz"; // Phase 3

export const UNIVERSAL_LINK_HOST = "https://buzz.app";
export const CUSTOM_SCHEME = "buzz://";

/** Deep-link an event/org/user page into the native app, falling back to the store. */
export function deepLink(kind: "e" | "o" | "u", id: string): string {
  return `${CUSTOM_SCHEME}${kind}/${id}`;
}

export function universalLink(kind: "e" | "o" | "u", id: string): string {
  return `${UNIVERSAL_LINK_HOST}/${kind}/${id}`;
}
