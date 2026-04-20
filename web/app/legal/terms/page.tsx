import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Terms of Service · Buzz",
  description: "The rules of using Buzz. Short and in English.",
};

export default function Terms() {
  return (
    <main className="max-w-3xl mx-auto px-6 py-16 text-[var(--color-text-primary)]">
      <h1 className="text-4xl font-black" style={{ fontFamily: "var(--font-display)" }}>
        Terms of Service
      </h1>
      <p className="text-sm text-[var(--color-text-tertiary)] mt-1">Last updated: {new Date().toISOString().slice(0, 10)}</p>

      <Section title="The deal">
        <p>Use Buzz to discover and attend college events. Don't use it to hurt people. If you break the rules, we can suspend you. If we break our promises, you can delete your account.</p>
      </Section>

      <Section title="You must">
        <Bullet>Be at least 13 years old. (Some features require 18+ or 21+; those are gated.)</Bullet>
        <Bullet>Be an actual student, alum, or staff member at the campus you claim. We verify.</Bullet>
        <Bullet>Post only content you have the right to post.</Bullet>
        <Bullet>Respect attendees' privacy. Don't take non-consensual photos at events.</Bullet>
      </Section>

      <Section title="You must not">
        <Bullet>Harass, threaten, dox, or impersonate anyone.</Bullet>
        <Bullet>Post spam, scams, or illegal content.</Bullet>
        <Bullet>Scrape, reverse-engineer, or automate the app in ways that load the servers.</Bullet>
        <Bullet>Use Buzz to coordinate events that violate federal, state, or university policy.</Bullet>
      </Section>

      <Section title="User-generated content">
        <p>You retain ownership of everything you post. You grant Buzz a limited license to display it to other users according to the visibility you chose. You are responsible for your content. We remove content that violates these terms.</p>
      </Section>

      <Section title="Tickets and payments">
        <p>Paid event tickets are processed by Stripe. Refunds are at the discretion of the hosting organization. If an event is cancelled, the host is responsible for issuing refunds within 30 days.</p>
      </Section>

      <Section title="Suspension & termination">
        <p>We can suspend or close accounts that violate these terms. You can delete your account anytime in Settings → Delete account.</p>
      </Section>

      <Section title="Disclaimers">
        <p>Buzz is provided "as is." We don't guarantee an event will happen, be fun, or be safe. We're not responsible for things that happen at events — attend at your own discretion and good judgment.</p>
      </Section>

      <Section title="Contact">
        <p>Questions: <a className="underline" href="mailto:hi@buzz.app">hi@buzz.app</a>. Legal: <a className="underline" href="mailto:legal@buzz.app">legal@buzz.app</a>.</p>
      </Section>
    </main>
  );
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section className="mt-10">
      <h2 className="text-2xl font-bold" style={{ fontFamily: "var(--font-display)" }}>{title}</h2>
      <div className="mt-3 space-y-2 text-[var(--color-text-secondary)]">{children}</div>
    </section>
  );
}

function Bullet({ children }: { children: React.ReactNode }) {
  return <p className="pl-4 relative before:absolute before:left-0 before:content-['•']">{children}</p>;
}
