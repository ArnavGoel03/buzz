import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { CheckCircle2, Users, Globe2 } from "lucide-react";
import { getOrg, getEventsByOrg } from "@/lib/data";
import EventCard from "@/components/EventCard";
import FollowButton from "@/components/FollowButton";
import OpenInApp from "@/components/OpenInApp";

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
      url: `https://buzz.app/o/${handle}`,
    },
  };
}

export default async function OrgDetail({ params }: { params: Params }) {
  const { handle } = await params;
  const [org, events] = await Promise.all([getOrg(handle), getEventsByOrg(handle)]);
  if (!org) notFound();

  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "Organization",
    name: org.name,
    description: org.tagline,
    url: `https://buzz.app/o/${handle}`,
  };

  return (
    <article>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />

      <div
        className="h-48 md:h-64"
        style={{
          background: `linear-gradient(135deg, ${org.accent_hex}66 0%, transparent 60%), radial-gradient(circle at 75% 25%, ${org.accent_hex}44, transparent 50%)`,
        }}
      />

      <div className="max-w-3xl mx-auto px-4 md:px-8 -mt-16">
        <div
          className="w-24 h-24 rounded-2xl flex items-center justify-center text-4xl font-black border-4 border-[var(--color-bg)] shadow-xl"
          style={{ background: org.accent_hex, color: "#000", fontFamily: "var(--font-display)" }}
        >
          {org.name[0]}
        </div>

        <div className="mt-4 flex items-center gap-2">
          <h1
            className="text-3xl md:text-4xl font-black tracking-tight"
            style={{ fontFamily: "var(--font-display)" }}
          >
            {org.name}
          </h1>
          {org.verified && <CheckCircle2 size={20} className="text-[var(--color-accent)]" />}
        </div>
        <p className="mt-1 text-base text-[var(--color-text-secondary)]">{org.tagline}</p>

        <div className="mt-4 flex flex-wrap items-center gap-3 text-xs text-[var(--color-text-tertiary)]">
          <span className="flex items-center gap-1"><Users size={12} /> {org.member_count.toLocaleString()} members</span>
          {org.category && <span>· {org.category}</span>}
          {org.campus && <span className="flex items-center gap-1">· <Globe2 size={12} /> {org.campus.toUpperCase()}</span>}
        </div>

        <div className="mt-5 flex flex-wrap items-center gap-3">
          <FollowButton handle={org.handle} />
          <OpenInApp kind="o" id={org.handle} label="Open in app" />
        </div>

        {org.description && (
          <section className="mt-8">
            <h2 className="text-sm font-bold uppercase tracking-wider text-[var(--color-text-tertiary)] mb-2">About</h2>
            <p className="text-[var(--color-text-secondary)] leading-relaxed">{org.description}</p>
          </section>
        )}

        <section className="mt-10">
          <h2 className="text-sm font-bold uppercase tracking-wider text-[var(--color-text-tertiary)] mb-3">
            Upcoming events
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
        </section>

        <div className="h-16 md:h-0" />
      </div>
    </article>
  );
}
