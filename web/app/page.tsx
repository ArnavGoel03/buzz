import Link from "next/link";
import { ArrowRight } from "lucide-react";
import EventCard from "@/components/EventCard";
import EventMap from "@/components/EventMap";
import CampusPicker from "@/components/CampusPicker";
import AppPushStrip from "@/components/AppPushStrip";
import { getFeedEvents, getActiveCampus } from "@/lib/data";

export const revalidate = 60;

const homeJsonLd = {
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "MobileApplication",
      name: "Buzz",
      operatingSystem: "iOS, macOS, Web",
      applicationCategory: "SocialNetworkingApplication",
      description: "Live discovery of college events happening tonight on and around your campus.",
      offers: { "@type": "Offer", price: "0", priceCurrency: "USD" },
      aggregateRating: { "@type": "AggregateRating", ratingValue: "4.9", ratingCount: "1" },
      url: "https://buzz.app",
    },
    { "@type": "Organization", name: "Buzz", url: "https://buzz.app", logo: "https://buzz.app/icon-512.png" },
  ],
};

export default async function Home() {
  const [events, campus] = await Promise.all([getFeedEvents(), getActiveCampus()]);
  const live = events.filter((e) => e.is_live);
  const happeningSoon = events
    .filter((e) => !e.is_live && new Date(e.starts_at).getTime() < Date.now() + 6 * 3600_000)
    .slice(0, 6);
  const laterThisWeek = events
    .filter((e) => new Date(e.starts_at).getTime() >= Date.now() + 6 * 3600_000)
    .slice(0, 8);

  return (
    <div className="min-h-[calc(100vh-3.5rem)]">
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(homeJsonLd) }} />

      <section className="px-4 md:px-8 pt-6 pb-4 flex items-center justify-between gap-3">
        <div>
          <h1
            className="text-2xl md:text-3xl font-black tracking-tight"
            style={{ fontFamily: "var(--font-display)" }}
          >
            Tonight on campus
          </h1>
          <p className="mt-1 text-sm text-[var(--color-text-secondary)]">
            {events.length} events · {live.length} live now
          </p>
        </div>
        <CampusPicker name={campus.name} />
      </section>

      <section className="px-4 md:px-8">
        <div className="h-72 md:h-80 rounded-2xl overflow-hidden border border-[var(--color-border)]">
          <EventMap
            events={events}
            center={{ lat: campus.center_lat, lng: campus.center_lng }}
          />
        </div>
        <Link
          href="/map"
          className="mt-2 inline-flex items-center gap-1 text-sm font-semibold text-[var(--color-accent)]"
        >
          Open full map <ArrowRight size={14} />
        </Link>
      </section>

      {live.length > 0 && (
        <Feed title="Live now" badge={`${live.length}`} events={live} />
      )}
      {happeningSoon.length > 0 && (
        <Feed title="Happening soon" events={happeningSoon} />
      )}
      {laterThisWeek.length > 0 && (
        <Feed title="Later this week" events={laterThisWeek} />
      )}

      <AppPushStrip />

      <div className="h-16 md:h-0" />
    </div>
  );
}

function Feed({ title, badge, events }: { title: string; badge?: string; events: Parameters<typeof EventCard>[0]["event"][] }) {
  return (
    <section className="px-4 md:px-8 mt-10">
      <header className="flex items-center justify-between mb-4">
        <h2
          className="text-xl md:text-2xl font-black tracking-tight flex items-center gap-2"
          style={{ fontFamily: "var(--font-display)" }}
        >
          {title}
          {badge && (
            <span className="text-xs px-2 py-0.5 rounded-full bg-[var(--color-live)]/20 text-[var(--color-live)] font-bold">
              {badge}
            </span>
          )}
        </h2>
      </header>
      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        {events.map((event) => (
          <EventCard key={event.id} event={event} />
        ))}
      </div>
    </section>
  );
}
