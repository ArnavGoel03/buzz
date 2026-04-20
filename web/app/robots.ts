import type { MetadataRoute } from "next";

/**
 * SEO: explicit robots.txt. Allows normal crawlers; gives ChatGPT / Perplexity / Google-Extended
 * / Claude-Bot explicit allow (we WANT our content in AI Overviews — that's AEO).
 * Blocks admin + API endpoints from indexing.
 */
export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      { userAgent: "*", allow: "/", disallow: ["/api/", "/admin/", "/embed/"] },
      { userAgent: "GPTBot",         allow: "/" },          // OpenAI training + citation
      { userAgent: "ChatGPT-User",   allow: "/" },          // OpenAI retrieval during chat
      { userAgent: "PerplexityBot",  allow: "/" },
      { userAgent: "ClaudeBot",      allow: "/" },          // Anthropic
      { userAgent: "Google-Extended",allow: "/" },          // Google AI Overviews
      { userAgent: "CCBot",          allow: "/" },          // Common Crawl
    ],
    sitemap: "https://buzz.app/sitemap.xml",
    host: "https://buzz.app",
  };
}
