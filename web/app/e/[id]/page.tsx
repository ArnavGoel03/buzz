import Link from "next/link";
import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { MapPin, Clock, Users, Calendar, Share2, Building2 } from "lucide-react";
import { getEvent } from "@/lib/data";
import { categoryColor, categoryLabel } from "@/lib/categories";
import { formatFullDate } from "@/lib/format";
import RSVPButton from "@/components/RSVPButton";
import EventMap from "@/components/EventMap";
import OpenInApp from "@/components/OpenInApp";
import EventHero from "@/components/EventHero";

type Params = Promise<{ id: string }>;

export async function generateMetadata({ params }: { params: Params }): Promise<Metadata> {
  const { id } = await params;
  const event = await getEvent(id);
  if (!event) return { title: "Event" };
  const title = `${event.title} · Buzz`;
  const description = `${event.summary} — ${event.location_name}`;
  // Dynamic OG card rendered at /api/poster/[id]. iMessage, Discord, Slack, etc
  // all pull this when the link is shared — it's how the event visualizes before
  // the click.
  const ogImage = `https://buzz.app/api/poster/${id}`;
  return {
    title, description,
    openGraph: {
      title, description,
      type: "article",
      siteName: "Buzz",
      url: `https://buzz.app/e/${id}`,
      images: [{ url: ogImage, width: 1200, height: 630, alt: event.title }],
    },
    twitter: { card: "summary_large_image", title, description, images: [ogImage] },
  };
}

export default async function EventDetail({ params }: { params: Params }) {
  const { id } = await params;
  const event = await getEvent(id);
  if (!event) notFound();

  const { color, soft } = categoryColor(event.category);
  void color; void soft; // used by legacy code paths; kept for future referrals

  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "Event",
    name: event.title,
    description: event.summary,
    startDate: event.starts_at,
    endDate: event.ends_at ?? undefined,
    eventStatus: "https://schema.org/EventScheduled",
    eventAttendanceMode: "https://schema.org/OfflineEventAttendanceMode",
    location: { "@type": "Place", name: event.location_name },
    organizer: { "@type": "Organization", name: event.host_name },
    url: `https://buzz.app/e/${id}`,
  };

  return (
    <article>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />

      <EventHero event={event} />

      <div className="max-w-3xl mx-auto px-4 md:px-8 -mt-2">
        <p className="text-base md:text-lg text-[var(--color-text-secondary)]">
          {event.summary}
        </p>

      <div className="mt-6 grid gap-2">
        <InfoRow icon={<Calendar size={16} />} label={formatFullDate(event.starts_at)} />
        <InfoRow icon={<MapPin size={16} />} label={event.location_name} />
        {event.host_handle ? (
          <Link href={`/o/${event.host_handle}`} className="group">
            <InfoRow
              icon={<Building2 size={16} />}
              label={`Hosted by ${event.host_name}`}
              chevron
            />
          </Link>
        ) : (
          <InfoRow icon={<Building2 size={16} />} label={`Hosted by ${event.host_name}`} />
        )}
        {typeof event.attendee_count === "number" && (
          <InfoRow icon={<Users size={16} />} label={`${event.attendee_count} going`} />
        )}
      </div>

      <div className="mt-6 grid grid-cols-[1fr_auto] gap-2">
        <RSVPButton eventId={event.id} />
        <ShareButton title={event.title} url={`https://buzz.app/e/${event.id}`} />
      </div>

      <div className="mt-3 p-4 rounded-xl bg-[var(--color-accent-dim)] border border-[var(--color-accent)]/30 flex items-center justify-between gap-3">
        <div className="min-w-0">
          <p className="text-sm font-bold">Get notified when it starts</p>
          <p className="text-xs text-[var(--color-text-secondary)]">
            Push alerts, chat with attendees, check-in — all in the app.
          </p>
        </div>
        <OpenInApp kind="e" id={event.id} label="Open" />
      </div>

      {event.latitude != null && event.longitude != null && (
        <section className="mt-8">
          <h2 className="text-sm font-bold uppercase tracking-wider text-[var(--color-text-tertiary)] mb-3">
            Where
          </h2>
          <div className="h-56 rounded-2xl overflow-hidden border border-[var(--color-border)]">
            <EventMap
              events={[event]}
              center={{ lat: event.latitude, lng: event.longitude }}
              zoom={16}
            />
          </div>
        </section>
      )}

      {event.tags && event.tags.length > 0 && (
        <section className="mt-8">
          <h2 className="text-sm font-bold uppercase tracking-wider text-[var(--color-text-tertiary)] mb-3">
            Tags
          </h2>
          <div className="flex flex-wrap gap-2">
            {event.tags.map((tag) => (
              <span key={tag} className="px-3 py-1 rounded-full bg-[var(--color-surface)] border border-[var(--color-border)] text-xs">
                #{tag}
              </span>
            ))}
          </div>
        </section>
      )}

      <p className="mt-10 text-xs text-[var(--color-text-tertiary)] text-center">
        Event ID: {event.id}
      </p>
      </div>
    </article>
  );
}

function InfoRow({
  icon, label, chevron,
}: { icon: React.ReactNode; label: string; chevron?: boolean }) {
  return (
    <div className="flex items-center justify-between gap-3 p-4 rounded-xl bg-[var(--color-surface)] border border-[var(--color-border)]">
      <div className="flex items-center gap-3">
        <span className="text-[var(--color-text-tertiary)]">{icon}</span>
        <span className="text-sm font-semibold">{label}</span>
      </div>
      {chevron && <span className="text-[var(--color-text-tertiary)]">›</span>}
    </div>
  );
}

function ShareButton({ title, url }: { title: string; url: string }) {
  return (
    <a
      href={`mailto:?subject=${encodeURIComponent(title)}&body=${encodeURIComponent(url)}`}
      className="h-12 w-12 flex items-center justify-center rounded-xl bg-[var(--color-surface)] border border-[var(--color-border)]"
      aria-label="Share"
    >
      <Share2 size={18} />
    </a>
  );
}
