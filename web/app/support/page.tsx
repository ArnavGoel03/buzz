import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Support · Buzz",
  description: "Get help with Buzz.",
};

export default function Support() {
  return (
    <main className="max-w-3xl mx-auto px-6 py-16 text-[var(--color-text-primary)]">
      <h1 className="text-4xl font-black" style={{ fontFamily: "var(--font-display)" }}>
        Need a hand?
      </h1>

      <section className="mt-10 grid grid-cols-1 md:grid-cols-2 gap-4">
        <Card title="Email us" body="We reply within 24 hours, usually same-day."
          href="mailto:help@buzz.app" cta="help@buzz.app" />
        <Card title="Bug or feature idea" body="Tell us what's off — we actually read this."
          href="mailto:feedback@buzz.app" cta="feedback@buzz.app" />
        <Card title="Trust + safety" body="Report a user, a post, or a safety concern."
          href="mailto:trust@buzz.app" cta="trust@buzz.app" />
        <Card title="Press + partnerships" body="Campus admin wanting to onboard officially."
          href="mailto:hi@buzz.app" cta="hi@buzz.app" />
      </section>

      <section className="mt-16">
        <h2 className="text-2xl font-bold" style={{ fontFamily: "var(--font-display)" }}>FAQ</h2>
        <div className="mt-4 space-y-6">
          <FAQ q="How do I delete my account?" a="In the app, Profile tab → Settings (gear icon) → Delete account. It's permanent and removes all your data within 30 days." />
          <FAQ q="I can't find my campus" a="Use the waitlist in onboarding. We launch at a new campus once we have ~20 students and one ambassador signed up." />
          <FAQ q="A friend posted something inappropriate" a="Tap the ••• on the post → Report. Our moderation team reviews within 24 hours." />
          <FAQ q="How does verification work?" a="We verify you're actually at the school you claim via `.edu` email OTP, institutional email, student ID scan, or peer vouching — depending on your campus." />
          <FAQ q="Is Buzz free?" a="Yes for students. Clubs can optionally charge for paid tickets through Stripe; we take a 5% platform fee." />
        </div>
      </section>
    </main>
  );
}

function Card({ title, body, href, cta }: { title: string; body: string; href: string; cta: string }) {
  return (
    <a href={href} className="block p-5 rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)] hover:border-[var(--color-accent)]">
      <div className="font-bold" style={{ fontFamily: "var(--font-display)" }}>{title}</div>
      <p className="text-sm text-[var(--color-text-secondary)] mt-1">{body}</p>
      <div className="text-sm text-[var(--color-accent)] mt-3">{cta} →</div>
    </a>
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
