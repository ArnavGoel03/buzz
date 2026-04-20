import type { MetadataRoute } from "next";

/**
 * SEO sitemap. Static pages + per-campus landing pages (big for "college events at X"
 * queries) + recently-created events/orgs in production.
 */
export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const base = "https://buzz.app";
  const now = new Date();

  // Campus landing pages — huge SEO opportunity ("college events at UCSD" etc.).
  const campuses = [
    "ucsd","ucla","ucb","stanford","mit","harvard","yale","princeton","columbia","nyu",
    "umich","utaustin","uw","uiuc","gatech","cmu","uchicago","duke","howard","spelman",
    "iit-bombay","iit-delhi","oxford","cambridge","utoronto","ubc","nus",
  ];

  return [
    { url: `${base}/`, lastModified: now, changeFrequency: "daily", priority: 1.0 },
    { url: `${base}/support`, lastModified: now, changeFrequency: "monthly", priority: 0.5 },
    { url: `${base}/legal/privacy`, lastModified: now, changeFrequency: "yearly", priority: 0.3 },
    { url: `${base}/legal/terms`, lastModified: now, changeFrequency: "yearly", priority: 0.3 },
    ...campuses.map((c) => ({
      url: `${base}/campus/${c}`,
      lastModified: now,
      changeFrequency: "weekly" as const,
      priority: 0.8,
    })),
  ];
}
