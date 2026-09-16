import Link from "next/link";
import { parseEventCursor } from "@/lib/org-events";
import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { CheckCircle2, Users, Globe2 } from "lucide-react";
import { getOrg, getEventsByOrg } from "@/lib/data";
import EventCard from "@/components/EventCard";
import FollowButton from "@/components/FollowButton";
import ShareButton from "@/components/ShareButton";
import OrgHero from "@/components/OrgHero";
import OrgExternalLinks from "@/components/OrgExternalLinks";
import { safeJsonLd } from "@/lib/security";
import { absoluteUrl } from "@/lib/site";

type Params = Promise<{ handle: string }>;

export async function generateMetadata({ params }: { params: Params }): Promise<Metadata> {
  const { handle } = await params;
  const org = await getOrg(handle);
  if (!org) return { title: "Club" };
  return {
    title: `${org.name} · Buzz`,
    description: org.tagline,
    openGraph: {
      title: org.name,
      description: org.tagline,
      type: "profile",
      siteName: "Buzz",
      url: absoluteUrl(`/o/${handle}`),
    },
  };
}

export default async function OrgDetail({ params, searchParams }: { params: Params; searchParams: Promise<{ after?: string; page?: string }> }) {
  const { handle } = await params;
  const search = await searchParams;
  const after = typeof search.after === "string" && parseEventCursor(search.after) ? search.after : undefined;
  const requestedPage = Number(search.page);
  const page = after && Number.isSafeInteger(requestedPage) && requestedPage > 1 && requestedPage < 1_000_000 ? requestedPage : 1;
  const [org, result] = await Promise.all([getOrg(handle), getEventsByOrg(handle, after)]);
  const { events, next } = result;
  if (!org) notFound();

  const sameAs: string[] = [];
  if (org.instagram_handle) {
    const raw = org.instagram_handle.replace(/^@/, "");
    if (/^[A-Za-z0-9._]+$/.test(raw)) sameAs.push(`https://instagram.com/${raw}`);
  }
  if (org.website_url) {
    try {
      const u = new URL(org.website_url);
      if (u.protocol === "https:" || u.protocol === "http:") sameAs.push(u.toString());
    } catch {}
  }

  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "Organization",
    name: org.name,
    description: org.tagline,
    url: absoluteUrl(`/o/${handle}`),
    ...(sameAs.length ? { sameAs } : {}),
  };

  return (
    <article>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: safeJsonLd(jsonLd) }} />

      <OrgHero org={org} />

      <div className="max-w-3xl mx-auto px-4 md:px-8 -mt-12 relative z-10">
        <div
          className="w-20 h-20 rounded-2xl flex items-center justify-center text-3xl font-black border-4 border-[var(--color-bg)] shadow-2xl"
          style={{ background: org.accent_hex, color: "#000", fontFamily: "var(--font-display)" }}
        >
          {org.name[0]}
        </div>

        <div className="mt-4 flex items-center gap-2">
          {org.verified && <CheckCircle2 size={18} className="text-[var(--color-accent)]" />}
          <span className="text-sm font-semibold text-[var(--color-text-secondary)]">@{org.handle}</span>
        </div>
        <p className="mt-1 text-base text-[var(--color-text-secondary)]">{org.tagline}</p>

        <div className="mt-4 flex flex-wrap items-center gap-3 text-xs text-[var(--color-text-tertiary)]">
          <span className="flex items-center gap-1"><Users size={12} /> {org.member_count.toLocaleString()} members</span>
          {org.category && <span>· {org.category}</span>}
          {org.campus && <span className="flex items-center gap-1">· <Globe2 size={12} /> {org.campus.toUpperCase()}</span>}
        </div>

        <div className="mt-5 flex flex-wrap items-center gap-3">
          <FollowButton handle={org.handle} />
          <ShareButton kind="o" id={org.handle} title={org.name} label="Share" />
        </div>

        <OrgExternalLinks org={org} />

        {org.description && (
          <section className="mt-8">
            <h2 className="text-sm font-bold uppercase tracking-wider text-[var(--color-text-tertiary)] mb-2">About</h2>
            <p className="text-[var(--color-text-secondary)] leading-relaxed">{org.description}</p>
          </section>
        )}

        <section className="mt-10">
          <h2 className="text-sm font-bold uppercase tracking-wider text-[var(--color-text-tertiary)] mb-3">
            Events
          </h2>
          {events.length === 0 ? (
            <p className="text-sm text-[var(--color-text-tertiary)] p-4 rounded-xl bg-[var(--color-surface)] border border-[var(--color-border)]">
              No events scheduled yet.
            </p>
          ) : (
            <div className="grid gap-3 md:grid-cols-2">
              {events.map((e) => (
                <EventCard key={e.id} event={e} />
              ))}
            </div>
          )}
          {(after || next) && (
            <nav aria-label="Events" className="mt-4 flex items-center gap-3">
              {after && <Link href={`/o/${handle}`} prefetch={false} className="p-3 underline">1</Link>}
              <span aria-current="page" className="p-3">{page}</span>
              {next && <Link href={{ pathname: `/o/${handle}`, query: { after: next, page: page + 1 } }} prefetch={false} rel="next" className="p-3 underline">{page + 1}</Link>}
            </nav>
          )}
        </section>

        <div className="h-16 md:h-0" />
      </div>
    </article>
  );
}
