/* Buzz service worker.
 *
 * Two jobs:
 *   1. Make the app installable (Chrome and Edge require a fetch handler before
 *      they will fire beforeinstallprompt).
 *   2. Make repeat visits paint from cache instead of the network.
 *
 * Strategy by request type:
 *   - navigations: network first, fall back to the cached shell when offline
 *   - hashed build assets (/_next/static): cache first, they are immutable
 *   - everything else: stale-while-revalidate
 *
 * API routes and auth callbacks are never cached.
 */

const VERSION = "v1";
const SHELL_CACHE = `buzz-shell-${VERSION}`;
const ASSET_CACHE = `buzz-assets-${VERSION}`;
const OFFLINE_URL = "/offline";

const SHELL = ["/", "/feed", "/download", OFFLINE_URL];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches
      .open(SHELL_CACHE)
      // Individually, so one 404 cannot fail the whole install.
      .then((cache) => Promise.allSettled(SHELL.map((url) => cache.add(url))))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(
          keys
            .filter((k) => k !== SHELL_CACHE && k !== ASSET_CACHE)
            .map((k) => caches.delete(k))
        )
      )
      .then(() => self.clients.claim())
  );
});

function isCacheable(url) {
  if (url.origin !== self.location.origin) return false;
  if (url.pathname.startsWith("/api/")) return false;
  if (url.pathname.startsWith("/auth/")) return false;
  return true;
}

self.addEventListener("fetch", (event) => {
  const { request } = event;
  if (request.method !== "GET") return;

  const url = new URL(request.url);
  if (!isCacheable(url)) return;

  if (request.mode === "navigate") {
    event.respondWith(
      fetch(request)
        .then((res) => {
          const copy = res.clone();
          caches.open(SHELL_CACHE).then((c) => c.put(request, copy));
          return res;
        })
        .catch(() =>
          caches
            .match(request)
            .then((hit) => hit || caches.match(OFFLINE_URL) || caches.match("/"))
        )
    );
    return;
  }

  const immutable = url.pathname.startsWith("/_next/static");

  event.respondWith(
    caches.match(request).then((hit) => {
      if (hit && immutable) return hit;

      const network = fetch(request)
        .then((res) => {
          if (res && res.status === 200 && res.type === "basic") {
            const copy = res.clone();
            caches.open(ASSET_CACHE).then((c) => c.put(request, copy));
          }
          return res;
        })
        .catch(() => hit);

      return hit || network;
    })
  );
});
