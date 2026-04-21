import HeroBanner from "@/components/HeroBanner";
import LiveTicker from "@/components/LiveTicker";
import BentoFeed from "@/components/BentoFeed";
import StatBand from "@/components/StatBand";
import EventMap from "@/components/EventMap";
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
  const soon = events.filter((e) => !e.is_live);

  return (
    <div>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(homeJsonLd) }} />

      <HeroBanner campusName={campus.name} eventCount={events.length} liveCount={live.length} />

      <LiveTicker events={events} />

      <section className="px-4 md:px-8 py-10">
        <header className="flex items-baseline justify-between mb-4 md:mb-6">
          <h2
            className="font-display text-2xl md:text-3xl tracking-[-0.02em]"
            style={{ fontFamily: "var(--font-display)" }}
          >
            Happening now
          </h2>
          <span className="font-mono text-[10px] uppercase tracking-[0.18em] text-[var(--color-text-tertiary)]">
            {events.length} total · {live.length} live
          </span>
        </header>
        <BentoFeed events={[...live, ...soon]} />
      </section>

      <section className="px-4 md:px-8 py-6">
        <div className="h-[360px] rim rounded-2xl overflow-hidden border border-[var(--color-border)]">
          <EventMap
            events={events}
            center={{ lat: campus.center_lat, lng: campus.center_lng }}
          />
        </div>
      </section>

      <section className="px-4 md:px-8 py-10">
        <StatBand
          items={[
            { label: "Events this week", value: events.length, accent: true },
            { label: "Live right now", value: live.length },
            { label: "Verified students", value: "1.2k" },
            { label: "Campuses live", value: 1 },
          ]}
        />
      </section>

      <AppPushStrip />

      <div className="h-16 md:h-8" />
    </div>
  );
}
