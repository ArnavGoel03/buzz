import type { MetadataRoute } from "next";
import { SITE } from "@/lib/site";

/**
 * PWA manifest. This is what makes Buzz installable to a home screen on iOS,
 * Android, and desktop with no store, no signing fee, and no review queue.
 *
 * `start_url` carries a source tag so installs are separable from web visits in
 * analytics, and `id` stays "/" so a start_url change never orphans an install.
 */
export default function manifest(): MetadataRoute.Manifest {
  return {
    id: "/",
    name: `${SITE.name}: ${SITE.tagline}`,
    short_name: SITE.name,
    description: SITE.shortDescription,
    start_url: "/feed?src=pwa",
    scope: "/",
    display: "standalone",
    orientation: "portrait",
    background_color: SITE.themeColor,
    theme_color: SITE.themeColor,
    categories: ["social", "education", "events"],
    icons: [
      { src: "/icon-192.png", sizes: "192x192", type: "image/png", purpose: "any" },
      { src: "/icon-512.png", sizes: "512x512", type: "image/png", purpose: "any" },
      { src: "/icon-maskable-512.png", sizes: "512x512", type: "image/png", purpose: "maskable" },
    ],
    shortcuts: [
      { name: "Tonight's feed", url: "/feed?src=pwa-shortcut", description: "Everything happening today" },
      { name: "Live map", url: "/map?src=pwa-shortcut", description: "What is on around you right now" },
      { name: "Clubs", url: "/clubs?src=pwa-shortcut", description: "Follow the orgs you care about" },
    ],
  };
}
