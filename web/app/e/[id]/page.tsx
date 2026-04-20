import type { Metadata } from "next";
import { mockEvent } from "@/lib/supabase";

type Params = Promise<{ id: string }>;

// Open Graph metadata so shared event links render as rich preview cards in iMessage,
// Discord, Slack, etc. — even before users have the app installed.
export async function generateMetadata({ params }: { params: Params }): Promise<Metadata> {
  const { id } = await params;
  const event = mockEvent(id);
  const title = `${event.title} · Buzz`;
  const description = `${event.summary} — ${event.location_name}`;
  return {
    title,
    description,
    openGraph: {
      title,
      description,
      type: "article",
      siteName: "Buzz",
      url: `https://buzz.app/e/${id}`,
    },
    twitter: { card: "summary_large_image", title, description },
  };
}

export default async function EventPreview({ params }: { params: Params }) {
  const { id } = await params;
  const event = mockEvent(id);
  const startTime = new Date(event.starts_at).toLocaleString(undefined, {
    weekday: "short",
    month: "short",
    day: "numeric",
    hour: "numeric",
    minute: "2-digit",
  });
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "Event",
    name: event.title,
    description: event.summary,
    startDate: event.starts_at,
    eventStatus: "https://schema.org/EventScheduled",
    eventAttendanceMode: "https://schema.org/OfflineEventAttendanceMode",
    location: { "@type": "Place", name: event.location_name },
    organizer: { "@type": "Organization", name: event.host_name },
    url: `https://buzz.app/e/${id}`,
  };

  return (
    <main className="min-h-screen px-6 py-16 max-w-2xl mx-auto">
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />
      <span className="inline-block px-3 py-1 rounded-full bg-pink-500/20 text-pink-300 text-xs font-bold uppercase tracking-wider">
        {event.category}
      </span>
      <h1
        className="mt-4 text-4xl font-black tracking-tight"
        style={{ fontFamily: "var(--font-display)" }}
      >
        {event.title}
      </h1>
      <p className="mt-3 text-[var(--color-text-secondary)] text-lg">{event.summary}</p>
      <div className="mt-8 space-y-3">
        <Row icon="🕒" primary={startTime} />
        <Row icon="📍" primary={event.location_name} />
        <Row icon="👥" primary={`Hosted by ${event.host_name}`} />
      </div>
      <a
        href={`buzz://e/${id}`}
        className="mt-10 block text-center px-6 py-4 rounded-2xl bg-[var(--color-accent)] text-black font-bold text-lg"
      >
        Open in Buzz
      </a>
      <p className="mt-3 text-center text-sm text-[var(--color-text-tertiary)]">
        Don't have Buzz?{" "}
        <a href="/" className="underline">
          Get the app
        </a>
      </p>
    </main>
  );
}

function Row({ icon, primary }: { icon: string; primary: string }) {
  return (
    <div className="flex items-center gap-3 p-4 rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)]">
      <span className="text-xl">{icon}</span>
      <span className="font-semibold">{primary}</span>
    </div>
  );
}
