import type { Metadata } from "next";
import { CONTACT, SITE, absoluteUrl } from "@/lib/site";

export const metadata: Metadata = {
  title: "Support",
  description: `Get help with ${SITE.name}.`,
  alternates: { canonical: absoluteUrl("/support") },
};

/**
 * Every channel on this page is real. There is no support inbox and no moderation
 * team yet, so it says so and points at the one place that is actually read. The FAQ
 * describes the product that exists today, not the one on the roadmap.
 */
export default function Support() {
  const reasons = [
    { title: "Something is broken", body: "Wrong time, missing event, a page that will not load." },
    { title: "Trust and safety", body: "Report a post or a person. This one gets looked at first." },
    { title: "You run a club", body: "You want your events on here and want them to look right." },
    { title: "Your campus is not on here", body: "Say which school. That is how the next one gets picked." },
  ];

  return (
    <main className="max-w-3xl mx-auto px-6 py-16 text-[var(--color-text-primary)]">
      <h1 className="text-4xl font-black" style={{ fontFamily: "var(--font-display)" }}>
        Need a hand?
      </h1>
      <p className="mt-4 text-[var(--color-text-secondary)] max-w-xl">
        {SITE.name} is small enough that one person reads everything. No support queue,
        no ticket number. Write once and you get a real answer, though not always a
        fast one.
      </p>

      <a
        href={CONTACT.href}
        className="mt-6 inline-flex h-11 px-5 rounded-xl bg-[var(--color-accent)] text-[var(--color-accent-ink)] items-center font-semibold text-sm"
        {...(CONTACT.email ? {} : { target: "_blank", rel: "noopener noreferrer" })}
      >
        {CONTACT.label}
      </a>

      <section className="mt-12">
        <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-[var(--color-text-tertiary)] mb-3">
          § Worth writing about
        </p>
        <ul className="rim rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)] overflow-hidden divide-y divide-[var(--color-border)]">
          {reasons.map((r) => (
            <li key={r.title} className="p-4">
              <p className="text-sm font-bold">{r.title}</p>
              <p className="text-xs text-[var(--color-text-tertiary)] mt-0.5">{r.body}</p>
            </li>
          ))}
        </ul>
      </section>

      <section className="mt-16">
        <h2 className="text-2xl font-bold" style={{ fontFamily: "var(--font-display)" }}>FAQ</h2>
        <div className="mt-4 space-y-6">
          <FAQ
            q={`Is ${SITE.name} free?`}
            a="Yes. Nothing to pay for, nothing to unlock. If that ever changes it will be clubs paying for something, not students."
          />
          <FAQ
            q="Do I need to download anything?"
            a={`No. ${SITE.name} runs in your browser. Tap Install and it sits on your home screen like an app, offline included.`}
          />
          <FAQ
            q="How do I delete my account?"
            a="Write in and it gets deleted, RSVPs and all. A self-serve button is coming; until it exists, saying so beats pointing you at a setting that is not there."
          />
          <FAQ
            q="My campus is not on here"
            a="One campus is live right now. Leave your school email and you get one message when yours opens, which happens once enough students and at least one club officer from that school have signed up."
          />
          <FAQ
            q="Someone posted something they should not have"
            a="Send the link. There is no moderation team, so it lands with the person who can pull the post, usually the same day."
          />
          <FAQ
            q="How do you know I actually go here?"
            a="Your school email. Nothing more clever than that yet."
          />
        </div>
      </section>
    </main>
  );
}

function FAQ({ q, a }: { q: string; a: string }) {
  return (
    <div>
      <div className="font-semibold">{q}</div>
      <p className="text-[var(--color-text-secondary)] mt-1">{a}</p>
    </div>
  );
}
