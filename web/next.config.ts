import type { NextConfig } from "next";

// Build identifier baked into the client bundle. Used by Cache-Control busting on
// versioned assets. (The PWA service worker was removed; this is now informational.)
const BUILD_ID =
  process.env.VERCEL_GIT_COMMIT_SHA ??
  process.env.NEXT_PUBLIC_BUILD_ID ??
  `dev-${Date.now().toString(36)}`;

// Defense-in-depth: SSRF guard + JSON-LD escaping + admin auth handle most attack surfaces,
// but app-wide headers prevent clickjacking, content-sniffing, and aggressive cross-origin
// embedding. `/embed/o/*` overrides X-Frame-Options to allow third-party club sites to embed.
const securityHeaders = [
  { key: "Strict-Transport-Security", value: "max-age=63072000; includeSubDomains; preload" },
  { key: "X-Content-Type-Options",    value: "nosniff" },
  { key: "Referrer-Policy",           value: "strict-origin-when-cross-origin" },
  { key: "X-Frame-Options",           value: "DENY" },
  { key: "Permissions-Policy",        value: "geolocation=(self), camera=(), microphone=()" },
];

const nextConfig: NextConfig = {
  reactStrictMode: true,
  env: { NEXT_PUBLIC_BUILD_ID: BUILD_ID },
  images: {
    remotePatterns: [
      { protocol: "https", hostname: "*.supabase.co" },
      { protocol: "https", hostname: "*.supabase.in" },
      { protocol: "https", hostname: "cartocdn.com" },
      { protocol: "https", hostname: "*.cartocdn.com" },
    ],
  },
  async headers() {
    return [
      {
        source: "/.well-known/apple-app-site-association",
        headers: [{ key: "Content-Type", value: "application/json" }],
      },
      {
        // Embeds must be iframable from third-party club sites. CSP frame-ancestors `*`
        // intentionally relaxes the default to allow this; the embed page reads only
        // public org data so the relaxation is safe.
        source: "/embed/:path*",
        headers: [
          { key: "Content-Security-Policy", value: "frame-ancestors *;" },
          { key: "X-Frame-Options", value: "" },
        ],
      },
      {
        source: "/:path*",
        headers: securityHeaders,
      },
    ];
  },
};

export default nextConfig;
