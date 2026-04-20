import Link from "next/link";

// SEO + AEO: MobileApplication + FAQPage + Organization schema on the home page. Puts
// Buzz in Google App Pack results + AI Overviews when users ask "best college events app"
// type queries.
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
    {
      "@type": "Organization",
      name: "Buzz",
      url: "https://buzz.app",
      logo: "https://buzz.app/icon-512.png",
      sameAs: [],
    },
    {
      "@type": "FAQPage",
      mainEntity: [
        {
          "@type": "Question",
          name: "What is Buzz?",
          acceptedAnswer: { "@type": "Answer", text: "Buzz is a live map of every college event happening tonight on your campus — parties, clubs, sports, free food, study sessions, and academic talks. Free for students, available on iOS, macOS, and web." },
        },
        {
          "@type": "Question",
          name: "Is Buzz free?",
          acceptedAnswer: { "@type": "Answer", text: "Yes, free for students with no ads and no data sales. Clubs can optionally sell paid tickets through Stripe." },
        },
        {
          "@type": "Question",
          name: "What colleges does Buzz work at?",
          acceptedAnswer: { "@type": "Answer", text: "50+ campuses across 12 countries at launch — including UCSD, UCLA, Stanford, Harvard, MIT, IIT Bombay, Oxford, Toronto, and more. New campuses launch via a waitlist once they hit ~20 sign-ups + one ambassador." },
        },
      ],
    },
  ],
};

export default function Home() {
  return (
    <main className="min-h-screen flex flex-col">
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(homeJsonLd) }} />
      <Hero />
      <Features />
      <DownloadStrip />
      <Footer />
    </main>
  );
}

function Hero() {
  return (
    <section className="px-6 pt-24 pb-32 text-center max-w-3xl mx-auto">
      <span className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/8 border border-[var(--color-border)] text-xs font-semibold tracking-wide">
        <span className="w-1.5 h-1.5 rounded-full bg-[var(--color-accent)]" />
        IN DEVELOPMENT
      </span>
      <h1
        className="mt-6 text-5xl md:text-6xl font-black tracking-tight"
        style={{ fontFamily: "var(--font-display)" }}
      >
        Every college event,{" "}
        <span className="text-[var(--color-accent)]">on one map.</span>
      </h1>
      <p className="mt-6 text-lg text-[var(--color-text-secondary)]">
        Live discovery for parties, clubs, sports, free food, and academic events
        happening tonight on and around your campus. iOS, Mac, and the web.
      </p>
      <div className="mt-10 flex items-center justify-center gap-3">
        <Link
          href="#download"
          className="px-6 py-3 rounded-2xl bg-[var(--color-accent)] text-black font-bold"
        >
          Get Buzz
        </Link>
        <Link
          href="#features"
          className="px-6 py-3 rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)] font-semibold"
        >
          See what's inside
        </Link>
      </div>
    </section>
  );
}

function Features() {
  const items = [
    { title: "Live map", body: "Pins for every event happening now or soon — color-coded by category, pulsing when live." },
    { title: "Tap-to-RSVP", body: "Going to that boba night? One tap. We add it to your calendar so you don't forget." },
    { title: "Club badges", body: "Member, Officer, President — earn badges as you join. Show them off or hide them." },
    { title: "All clubs, one place", body: "Greek life, honor societies, cultural orgs, intramurals, free food. Search the whole roster." },
    { title: "Tabling Mode", body: "Club officers run a QR-poster display from any iPad, Mac, or iPhone — no more printing flyers." },
    { title: "Works at every college", body: "USA, India, UK, Canada, Australia, and more. One profile follows you across transfers." },
  ];
  return (
    <section id="features" className="px-6 py-24 bg-[var(--color-surface)]">
      <div className="max-w-5xl mx-auto">
        <h2
          className="text-3xl md:text-4xl font-black"
          style={{ fontFamily: "var(--font-display)" }}
        >
          What's inside
        </h2>
        <div className="mt-10 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {items.map((item) => (
            <div
              key={item.title}
              className="p-6 rounded-2xl bg-black/30 border border-[var(--color-border)]"
            >
              <h3 className="font-bold text-lg" style={{ fontFamily: "var(--font-display)" }}>
                {item.title}
              </h3>
              <p className="mt-2 text-[var(--color-text-secondary)] text-sm">{item.body}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function DownloadStrip() {
  return (
    <section id="download" className="px-6 py-24 text-center">
      <h2
        className="text-3xl md:text-4xl font-black"
        style={{ fontFamily: "var(--font-display)" }}
      >
        Get Buzz on every device.
      </h2>
      <p className="mt-3 text-[var(--color-text-secondary)]">
        TestFlight is open. Mac and Web are next.
      </p>
      <div className="mt-8 flex flex-wrap justify-center gap-3">
        <a className="px-5 py-3 rounded-xl bg-white text-black font-semibold" href="#">
          App Store (soon)
        </a>
        <a className="px-5 py-3 rounded-xl bg-white text-black font-semibold" href="#">
          Mac App Store (soon)
        </a>
        <a className="px-5 py-3 rounded-xl bg-[var(--color-surface)] border border-[var(--color-border)] font-semibold" href="#">
          Use on the web
        </a>
      </div>
    </section>
  );
}

function Footer() {
  return (
    <footer className="px-6 py-12 text-center text-[var(--color-text-tertiary)] text-sm">
      © {new Date().getFullYear()} Buzz · Built for college life.
    </footer>
  );
}
