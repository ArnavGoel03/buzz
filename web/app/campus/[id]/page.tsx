import type { Metadata } from "next";
import Link from "next/link";

type Params = Promise<{ id: string }>;

// Per-campus SEO landing page. Huge opportunity for organic traffic on queries like
// "ucsd events tonight", "stanford clubs", "harvard rush week." Each page gets a proper
// title, description, H1, FAQ schema, and deep links into the app.
export async function generateMetadata({ params }: { params: Params }): Promise<Metadata> {
  const { id } = await params;
  const display = CAMPUS_LABELS[id] ?? id.toUpperCase();
  return {
    title: `${display} — events, clubs, rush on Buzz`,
    description: `Live map of what's happening at ${display} tonight. Parties, clubs, rush, free food, sports, study sessions — all in one app.`,
    alternates: { canonical: `https://buzz.app/campus/${id}` },
    openGraph: {
      title: `${display} on Buzz`,
      description: `Live college events happening at ${display} tonight.`,
      type: "website",
      url: `https://buzz.app/campus/${id}`,
    },
    twitter: { card: "summary_large_image" },
  };
}

export default async function CampusLanding({ params }: { params: Params }) {
  const { id } = await params;
  const display = CAMPUS_LABELS[id] ?? id.toUpperCase();

  // JSON-LD structured data — Organization + BreadcrumbList + FAQ. These land in
  // Google's Rich Results and get cited by AI Overviews / Perplexity.
  const jsonLd = {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "Organization",
        name: display,
        url: `https://buzz.app/campus/${id}`,
      },
      {
        "@type": "BreadcrumbList",
        itemListElement: [
          { "@type": "ListItem", position: 1, name: "Buzz", item: "https://buzz.app" },
          { "@type": "ListItem", position: 2, name: "Campuses", item: "https://buzz.app/campus" },
          { "@type": "ListItem", position: 3, name: display, item: `https://buzz.app/campus/${id}` },
        ],
      },
      {
        "@type": "FAQPage",
        mainEntity: [
          {
            "@type": "Question",
            name: `What events are happening at ${display} tonight?`,
            acceptedAnswer: {
              "@type": "Answer",
              text: `Open Buzz on iOS or macOS to see a live map of every event happening at ${display} right now — parties, club meetings, sports, free food, study sessions, and more. It updates every few minutes as new RSVPs come in.`,
            },
          },
          {
            "@type": "Question",
            name: `How do I join clubs at ${display} on Buzz?`,
            acceptedAnswer: {
              "@type": "Answer",
              text: `Open the Clubs tab in Buzz, search for the org you want to join, and tap Follow. An officer can invite you as a full Member — you'll get a badge on your profile once you accept.`,
            },
          },
          {
            "@type": "Question",
            name: `Is Buzz free for ${display} students?`,
            acceptedAnswer: {
              "@type": "Answer",
              text: `Yes. Buzz is free for students. Paid event tickets (like sports games or formals) may cost money, but the app itself has no ads and doesn't sell data.`,
            },
          },
          {
            "@type": "Question",
            name: `Does Buzz work for Greek life rush at ${display}?`,
            acceptedAnswer: {
              "@type": "Answer",
              text: `Yes. During an active rush cycle at ${display}, Buzz shows every chapter running recruitment — Panhellenic, IFC, Multicultural, NPHC, and professional. Tap chapters you're interested in; officers can mark mutual interest for Bid Day.`,
            },
          },
        ],
      },
    ],
  };

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <main className="max-w-3xl mx-auto px-6 py-16">
        <nav className="text-sm text-[var(--color-text-tertiary)]">
          <Link href="/" className="hover:underline">Buzz</Link>
          <span className="mx-2">›</span>
          <span>{display}</span>
        </nav>

        <h1 className="mt-4 text-4xl md:text-5xl font-black tracking-tight" style={{ fontFamily: "var(--font-display)" }}>
          {display} events, tonight.
        </h1>
        <p className="mt-4 text-lg text-[var(--color-text-secondary)]">
          Every party, club meeting, intramural game, study session, and free-food event
          happening at {display} — on one live map. Free for students.
        </p>

        <div className="mt-8 flex flex-wrap gap-3">
          <Link href="/" className="px-6 py-3 rounded-xl bg-[var(--color-accent)] text-black font-bold">Get Buzz</Link>
          <Link href="/support" className="px-6 py-3 rounded-xl bg-[var(--color-surface)] border border-[var(--color-border)] font-semibold">How it works</Link>
        </div>

        <section className="mt-14">
          <h2 className="text-2xl font-bold" style={{ fontFamily: "var(--font-display)" }}>What students ask us</h2>
          <div className="mt-6 space-y-6">
            <QA q={`What events are happening at ${display} tonight?`} a={`Open Buzz on iOS or macOS to see a live map of every event happening at ${display} right now — parties, club meetings, sports, free food, study sessions. Updates as RSVPs come in.`} />
            <QA q={`How do I join a club at ${display}?`} a={`In the Clubs tab, tap Follow. Once an officer invites you as a full member, you'll get a badge on your profile. Member badges are clean; officer and president badges have visible prestige styling.`} />
            <QA q={`Is ${display} Greek life on Buzz?`} a={`Yes — during rush week, Buzz shows every chapter running recruitment. Tap chapters you're interested in, see the round schedule, get notified on Bid Day.`} />
            <QA q={`Does Buzz work for international students at ${display}?`} a={`Yes. Buzz supports 50+ campuses across 12 countries and handles international transfers. Your profile + badges follow you across schools.`} />
          </div>
        </section>

        <section className="mt-14 p-6 rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)]">
          <h3 className="font-bold" style={{ fontFamily: "var(--font-display)" }}>Club officer at {display}?</h3>
          <p className="text-sm text-[var(--color-text-secondary)] mt-2">
            Post events in 10 seconds. Forward event emails to <code>@events.buzz.app</code>. Replace stacks of printed flyers with one printable QR poster. Broadcast to members. It's free.
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
