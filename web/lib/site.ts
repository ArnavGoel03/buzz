/**
 * Single source of truth for the public web surface: canonical origin, brand copy,
 * and what a student can actually install today. Metadata, route handlers, sitemap,
 * OG images, and every install CTA read from here. No file hardcodes a URL twice.
 */

import config from "../site.config.json";
import { BRAND_COLORS } from "./tokens";

/** site.config.json is shared with the build scripts, which cannot import TypeScript. */
const PRODUCTION_HOST = config.productionHost;

function normalize(url: string): string {
  return url.replace(/\/+$/, "");
}

/**
 * Canonical origin, in priority order:
 *   1. NEXT_PUBLIC_SITE_URL, set the day a custom domain lands
 *   2. Vercel's injected production URL, correct on every deployment
 *   3. the known production host, used for local dev
 */
export const SITE_URL = normalize(
  process.env.NEXT_PUBLIC_SITE_URL ||
    (process.env.NEXT_PUBLIC_VERCEL_PROJECT_PRODUCTION_URL
      ? `https://${process.env.NEXT_PUBLIC_VERCEL_PROJECT_PRODUCTION_URL}`
      : `https://${PRODUCTION_HOST}`)
);

export function absoluteUrl(path = "/"): string {
  return `${SITE_URL}${path.startsWith("/") ? path : `/${path}`}`;
}

export const SITE = {
  name: "Buzz",
  tagline: "every college event, one feed",
  description:
    "Live discovery for college students. Parties, clubs, sports, free food, and academic events happening tonight on and around campus. Free, no app store required.",
  shortDescription: "Every college event on your campus, in one live feed.",
  /** Colours come from design/tokens.json, never a second hex literal. */
  themeColor: BRAND_COLORS.theme,
  accent: BRAND_COLORS.accent,
} as const;

/** GitHub repo that hosts the source and the desktop release artifacts. */
export const REPO = {
  owner: config.repo.owner,
  name: config.repo.name,
  get url() {
    return `https://github.com/${this.owner}/${this.name}`;
  },
  get releasesUrl() {
    return `${this.url}/releases/latest`;
  },
  get apiLatestRelease() {
    return `https://api.github.com/repos/${this.owner}/${this.name}/releases/latest`;
  },
} as const;

/**
 * How a human reaches a human. `email` stays null until an inbox actually exists,
 * because a printed address that bounces is worse than no address: every contact
 * link degrades to the repo's issue tracker, which is real and is read.
 */
const CONTACT_EMAIL = config.contact.email as string | null;

export const CONTACT = {
  email: CONTACT_EMAIL,
  /** Where a "get in touch" link should point today. */
  get href() {
    return CONTACT_EMAIL ? `mailto:${CONTACT_EMAIL}` : `${REPO.url}/issues/new`;
  },
  /** What that link should say. */
  get label() {
    return CONTACT_EMAIL ?? "Open an issue on GitHub";
  },
} as const;

/**
 * Domain that accepts forwarded event emails (`<handle>@<domain>`). Null until the
 * MX records are live, and every surface that would advertise it stays hidden.
 */
export const INBOUND_EMAIL_DOMAIN = config.contact.inboundEmailDomain as string | null;

/**
 * What ships today. The web app installs to a home screen on every platform via the
 * PWA manifest; the native store listings do not exist yet, so anything gated on
 * these flags renders a notify-me capture instead of a dead store link.
 *
 * Flip a flag the day the listing goes live. Nothing else needs to change.
 */
export const STORE_LISTINGS = {
  ios: null as string | null,
  android: null as string | null,
  macAppStore: null as string | null,
} as const;
