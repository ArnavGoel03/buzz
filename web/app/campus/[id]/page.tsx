import type { Metadata } from "next";
import Link from "next/link";
import { safeJsonLd } from "@/lib/security";
import { SITE, SITE_URL, absoluteUrl } from "@/lib/site";

type Params = Promise<{ id: string }>;

// Per-campus SEO landing page. Huge opportunity for organic traffic on queries like
// "ucsd events tonight", "stanford clubs", "harvard rush week." Each page gets a proper
// title, description, H1, FAQ schema, and deep links into the app.
export async function generateMetadata({ params }: { params: Params }): Promise<Metadata> {
  const { id } = await params;
  const display = CAMPUS_LABELS[id] ?? id.toUpperCase();
  return {
    title: `${display}: events, clubs, and rush on ${SITE.name}`,
    description: `Live map of what's happening at ${display} tonight. Parties, clubs, rush, free food, sports, and study sessions, all in one feed.`,
    alternates: { canonical: absoluteUrl(`/campus/${id}`) },
    openGraph: {
      title: `${display} on ${SITE.name}`,
      description: `Live college events happening at ${display} tonight.`,
      type: "website",
      url: absoluteUrl(`/campus/${id}`),
    },
    twitter: { card: "summary_large_image" },
  };
}

export default async function CampusLanding({ params }: { params: Params }) {
  const { id } = await params;
  const display = CAMPUS_LABELS[id] ?? id.toUpperCase();

  // Written once, rendered twice: the FAQ below feeds both the visible list and the
  // FAQPage schema. Google penalises structured data that disagrees with the page, and
  // two hand-maintained copies of the same answer always drift apart eventually.
  const faq = [
    {
      q: `What events are happening at ${display} tonight?`,
      a: `Open ${SITE.name} in any browser for a live map of what is on at ${display} right now: parties, club meetings, sports, free food, and study sessions. It updates as RSVPs come in, and it installs to your home screen in two taps.`,
    },
    {
      q: `How do I find clubs at ${display}?`,
      a: `Open Clubs, find the org, and follow it. Everything that org posts from then on shows up in your feed. Officers can invite you as a full member, which puts a badge on your profile.`,
    },
    {
      q: `Is ${SITE.name} free for ${display} students?`,
      a: `Yes. No ads, no fee, and nothing sold to anyone. Some events charge at the door, but that money goes to the club running them, not to us.`,
    },
    {
      q: `Is Greek life rush at ${display} on ${SITE.name}?`,
      a: `Only what chapters post themselves. There is no official feed from Panhellenic or IFC, so during rush you see the chapters whose officers are actually using ${SITE.name}, not a complete roster.`,
    },
  ];

  // JSON-LD structured data: Organization, BreadcrumbList, FAQ. These land in Google's
  // Rich Results and get cited by AI Overviews and Perplexity.
  const jsonLd = {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "Organization",
        name: display,
        url: absoluteUrl(`/campus/${id}`),
      },
      {
        "@type": "BreadcrumbList",
        itemListElement: [
          { "@type": "ListItem", position: 1, name: SITE.name, item: SITE_URL },
          { "@type": "ListItem", position: 2, name: "Campuses", item: absoluteUrl("/campus") },
          { "@type": "ListItem", position: 3, name: display, item: absoluteUrl(`/campus/${id}`) },
        ],
      },
      {
        "@type": "FAQPage",
        mainEntity: faq.map((f) => ({
          "@type": "Question",
          name: f.q,
          acceptedAnswer: { "@type": "Answer", text: f.a },
        })),
      },
    ],
  };

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: safeJsonLd(jsonLd) }}
      />
      <main className="max-w-3xl mx-auto px-6 py-16">
        <nav className="text-sm text-[var(--color-text-tertiary)]">
          <Link href="/" className="hover:underline">{SITE.name}</Link>
          <span className="mx-2">›</span>
          <span>{display}</span>
        </nav>

        <h1 className="mt-4 text-4xl md:text-5xl font-black tracking-tight" style={{ fontFamily: "var(--font-display)" }}>
          {display} events, tonight.
        </h1>
        <p className="mt-4 text-lg text-[var(--color-text-secondary)]">
          Every party, club meeting, intramural game, study session, and free-food event
          happening at {display}, on one live map. Free for students.
        </p>

        <div className="mt-8 flex flex-wrap gap-3">
          <Link href="/" className="px-6 py-3 rounded-xl bg-[var(--color-accent)] text-[var(--color-accent-ink)] font-bold">Get {SITE.name}</Link>
          <Link href="/support" className="px-6 py-3 rounded-xl bg-[var(--color-surface)] border border-[var(--color-border)] font-semibold">How it works</Link>
        </div>

        <section className="mt-14">
          <h2 className="text-2xl font-bold" style={{ fontFamily: "var(--font-display)" }}>What students ask us</h2>
          <div className="mt-6 space-y-6">
            {faq.map((f) => (
              <QA key={f.q} q={f.q} a={f.a} />
            ))}
          </div>
        </section>

        <section className="mt-14 p-6 rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)]">
          <h3 className="font-bold" style={{ fontFamily: "var(--font-display)" }}>Club officer at {display}?</h3>
          <p className="text-sm text-[var(--color-text-secondary)] mt-2">
            Post an event in about ten seconds, then hand out one printable QR poster
            instead of a stack of flyers nobody keeps. Free, and it stays free.
          </p>
          <Link href="/support" className="inline-block mt-4 text-[var(--color-accent)] text-sm font-semibold">Learn more →</Link>
        </section>
      </main>
    </>
  );
}

function QA({ q, a }: { q: string; a: string }) {
  return (
    <div>
      <div className="font-semibold text-[var(--color-text-primary)]">{q}</div>
      <p className="text-[var(--color-text-secondary)] mt-1">{a}</p>
    </div>
  );
}

const CAMPUS_LABELS: Record<string, string> = {
  ucsd: "UC San Diego", ucla: "UCLA", ucb: "UC Berkeley",
  stanford: "Stanford", mit: "MIT", harvard: "Harvard",
  yale: "Yale", princeton: "Princeton", columbia: "Columbia",
  nyu: "NYU", umich: "Michigan", utaustin: "UT Austin",
  uw: "Washington", uiuc: "UIUC", gatech: "Georgia Tech",
  cmu: "CMU", uchicago: "UChicago", duke: "Duke",
  howard: "Howard", spelman: "Spelman",
  "iit-bombay": "IIT Bombay", "iit-delhi": "IIT Delhi",
  oxford: "Oxford", cambridge: "Cambridge",
  utoronto: "U of Toronto", ubc: "UBC", nus: "NUS",
};
