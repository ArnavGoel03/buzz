import type { MetadataRoute } from "next";
import { createClient } from "@/lib/supabase-server";

/**
 * SEO sitemap. Pulls real published events + orgs from Supabase; falls back to an
 * empty list when Supabase isn't configured (local dev without env). Priority weights
 * are tuned so Google treats Buzz as an event-discovery site:
 *   1.0   = landing (/)
 *   0.92  = feed (most-RSVP'd user-facing index)
 *   0.85  = per-campus / clubs index
 *   0.78  = per-event pages
 *   0.70  = per-org, per-user profiles
 *   0.50  = support
 *   0.30  = legal
 */
export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const base = "https://buzz.app";
  const now = new Date();

  const supabase = await createClient();

  type EventRow = { id: string; starts_at: string };
  type OrgRow   = { handle: string };
  type ProfileRow = { handle: string };

  const [events, orgs, profiles] = await Promise.all([
    supabase
      .from("events")
      .select("id, starts_at")
      .eq("status", "published")
      .gt("ends_at", now.toISOString())
      .order("starts_at", { ascending: true })
      .limit(5000)
      .then((r) => (r.data ?? []) as EventRow[])
      .catch(() => [] as EventRow[]),
    supabase
      .from("organizations")
      .select("handle")
      .limit(5000)
      .then((r) => (r.data ?? []) as OrgRow[])
      .catch(() => [] as OrgRow[]),
    supabase
      .from("profiles")
      .select("handle")
      .eq("verified", true)
      .not("handle", "is", null)
      .limit(5000)
      .then((r) => (r.data ?? []) as ProfileRow[])
      .catch(() => [] as ProfileRow[]),
  ]);

  const campuses = [
    "ucsd","ucla","ucb","stanford","mit","harvard","yale","princeton","columbia","nyu",
    "umich","utaustin","uw","uiuc","gatech","cmu","uchicago","duke","howard","spelman",
    "iit-bombay","iit-delhi","oxford","cambridge","utoronto","ubc","nus",
  ];

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
    ...events.map((e) => ({
      url: `${base}/e/${e.id}`,
      lastModified: new Date(e.starts_at),
      changeFrequency: "hourly" as const,
      priority: 0.78,
    })),
    ...orgs.map((o) => ({
      url: `${base}/o/${o.handle}`,
      lastModified: now,
      changeFrequency: "weekly" as const,
      priority: 0.7,
    })),
    ...profiles.map((p) => ({
      url: `${base}/u/${p.handle}`,
      lastModified: now,
      changeFrequency: "weekly" as const,
      priority: 0.6,
    })),
  ];
}
