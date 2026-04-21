import type { MetadataRoute } from "next";
import { mockEvents, mockOrgs } from "@/lib/mock-data";

/**
 * SEO sitemap. Priority weights tuned so Google treats Buzz as an event-discovery
 * site, not a "random Next.js app":
 *   1.0   = landing (/)
 *   0.92  = feed (most-RSVP'd user-facing index)
 *   0.85  = per-campus landing pages + clubs index
 *   0.78  = per-event pages (high churn, huge volume in prod)
 *   0.70  = per-org, per-user profiles
 *   0.50  = support
 *   0.30  = legal
 */
export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const base = "https://buzz.app";
  const now = new Date();

  const campuses = [
    "ucsd","ucla","ucb","stanford","mit","harvard","yale","princeton","columbia","nyu",
    "umich","utaustin","uw","uiuc","gatech","cmu","uchicago","duke","howard","spelman",
    "iit-bombay","iit-delhi","oxford","cambridge","utoronto","ubc","nus",
  ];

  const eventEntries: MetadataRoute.Sitemap = mockEvents.map((e) => ({
    url: `${base}/e/${e.id}`,
    lastModified: new Date(e.starts_at),
    changeFrequency: "hourly",
    priority: 0.78,
  }));

  const orgEntries: MetadataRoute.Sitemap = mockOrgs.map((o) => ({
    url: `${base}/o/${o.handle}`,
    lastModified: now,
    changeFrequency: "weekly",
    priority: 0.7,
  }));

  return [
    { url: `${base}/`,       lastModified: now, changeFrequency: "daily",  priority: 1.0 },
    { url: `${base}/feed`,   lastModified: now, changeFrequency: "hourly", priority: 0.92 },
    { url: `${base}/map`,    lastModified: now, changeFrequency: "hourly", priority: 0.88 },
    { url: `${base}/clubs`,  lastModified: now, changeFrequency: "daily",  priority: 0.85 },
    { url: `${base}/search`, lastModified: now, changeFrequency: "weekly", priority: 0.6  },
    { url: `${base}/sign-in`,lastModified: now, changeFrequency: "monthly",priority: 0.4  },
    { url: `${base}/support`,        lastModified: now, changeFrequency: "monthly", priority: 0.5 },
    { url: `${base}/legal/privacy`,  lastModified: now, changeFrequency: "yearly",  priority: 0.3 },
    { url: `${base}/legal/terms`,    lastModified: now, changeFrequency: "yearly",  priority: 0.3 },
    ...campuses.map((c) => ({
      url: `${base}/campus/${c}`,
      lastModified: now,
      changeFrequency: "weekly" as const,
      priority: 0.85,
    })),
    ...eventEntries,
    ...orgEntries,
  ];
}
