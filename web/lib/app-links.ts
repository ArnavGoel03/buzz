// Deep links and install destinations. Store URLs live in lib/site.ts as nullable
// listings so a placeholder App Store ID can never ship as a real-looking button.

import { SITE_URL, STORE_LISTINGS } from "./site";

export const UNIVERSAL_LINK_HOST = SITE_URL;
export const CUSTOM_SCHEME = "buzz://";

/** Where every "get the app" CTA points. One canonical anchor for the whole site. */
export const INSTALL_PATH = "/download";

export const APP_STORE_URL = STORE_LISTINGS.ios;
export const PLAY_STORE_URL = STORE_LISTINGS.android;
export const MAC_APP_STORE_URL = STORE_LISTINGS.macAppStore;

/** Deep-link an event/org/user page into the native app when it is installed. */
export function deepLink(kind: "e" | "o" | "u", id: string): string {
  return `${CUSTOM_SCHEME}${kind}/${id}`;
}

export function universalLink(kind: "e" | "o" | "u", id: string): string {
  return `${UNIVERSAL_LINK_HOST}/${kind}/${id}`;
}
