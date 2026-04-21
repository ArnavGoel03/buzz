import type { MetadataRoute } from "next";

/**
 * SEO: explicit robots.txt. Allows normal crawlers; grants ChatGPT / Perplexity /
 * Google-Extended / Claude-Bot explicit opt-in (we WANT our content in AI
 * Overviews — that's AEO). Blocks non-indexable routes.
 *
 * Exceptions:
 *   - /api/poster/* is ALLOWED — it's the dynamic OG poster endpoint that social
 *     crawlers (Facebook, iMessage, Slack, Discord) need to fetch to render
 *     rich link previews.
 */
export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: "*",
        allow: ["/", "/api/poster/"],
        disallow: [
          "/api/",
          "/admin/",
          "/embed/",
          "/auth/callback",   // short-lived magic-link redirects
          "/profile",         // private route
          "/settings",        // private route
        ],
      },
      { userAgent: "GPTBot",          allow: "/" },   // OpenAI training + citation
      { userAgent: "ChatGPT-User",    allow: "/" },   // OpenAI retrieval during chat
      { userAgent: "PerplexityBot",   allow: "/" },
      { userAgent: "ClaudeBot",       allow: "/" },   // Anthropic
      { userAgent: "Google-Extended", allow: "/" },   // Google AI Overviews
      { userAgent: "CCBot",           allow: "/" },   // Common Crawl
    ],
    sitemap: "https://buzz.app/sitemap.xml",
    host: "https://buzz.app",
  };
}
