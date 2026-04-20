import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Privacy Policy · Buzz",
  description: "How Buzz handles your data. Plain-English, no dark patterns.",
};

export default function Privacy() {
  return (
    <main className="max-w-3xl mx-auto px-6 py-16 text-[var(--color-text-primary)]">
      <h1 className="text-4xl font-black" style={{ fontFamily: "var(--font-display)" }}>
        Privacy Policy
      </h1>
      <p className="text-sm text-[var(--color-text-tertiary)] mt-1">Last updated: {new Date().toISOString().slice(0, 10)}</p>

      <Section title="TL;DR">
        <p>We collect the minimum data to make Buzz work, never sell it, and let you delete your account in one tap. This page explains the details.</p>
      </Section>

      <Section title="What we collect">
        <Bullet><b>Identity you give us</b>: display name, handle, pronouns (optional), bio (optional), avatar.</Bullet>
        <Bullet><b>Campus affiliation</b>: the college(s) you verify at via `.edu` OTP, institutional email, or student ID. We store when each affiliation was verified and by which method.</Bullet>
        <Bullet><b>Sign-in identity</b>: Apple user ID, Google sub, email, or phone — whichever provider(s) you chose.</Bullet>
        <Bullet><b>Events you RSVP to</b> and <b>check in to</b>, so we can show them in your calendar + feed.</Bullet>
        <Bullet><b>Location</b> when in-use, only to center the map on you. Never stored on our servers.</Bullet>
        <Bullet><b>Device push tokens</b> (APNs / FCM / Web Push) so we can deliver notifications you opt into.</Bullet>
        <Bullet><b>Usage telemetry</b>: anonymous counts of what features are tapped, for improving the app. No personally identifying data attached.</Bullet>
      </Section>

      <Section title="What we don't collect">
        <Bullet>We do not upload your contact list.</Bullet>
        <Bullet>We do not sell data to advertisers or data brokers.</Bullet>
        <Bullet>We do not track you across other apps.</Bullet>
        <Bullet>We do not read your private DMs — they're end-to-end-visible-server-side-only for moderation if reported.</Bullet>
      </Section>

      <Section title="Who sees what">
        <Bullet>Other users at your campus see: your display name, handle, badges you chose to show, RSVPs to public events, photos you upload to events you attended.</Bullet>
        <Bullet>Your friends see: your streak, plus anything above.</Bullet>
        <Bullet>Nobody except you sees: transfer history, mental-health check-ins, private notifications, draft events, your full RSVP log.</Bullet>
      </Section>

      <Section title="Your rights">
        <Bullet><b>Download your data</b>: Settings → "Download my data." Returns a JSON export within 7 days.</Bullet>
        <Bullet><b>Delete your account</b>: Settings → "Delete account." Your profile and linked rows are removed within 30 days. Audit-log entries are anonymized but retained for legal compliance.</Bullet>
        <Bullet><b>Restrict use</b>: opt out of any notification category in Settings; disable location in iOS Settings → Buzz.</Bullet>
        <Bullet><b>Contact us</b> with concerns at <a className="underline" href="mailto:privacy@buzz.app">privacy@buzz.app</a>.</Bullet>
      </Section>

      <Section title="Security">
        <p>Auth tokens are stored in the iOS Keychain with <code>kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly</code> and never synced to iCloud. Offline data cache uses iOS file protection. Every server table is row-level-security-locked: you cannot read another user's data. See the <a className="underline" href="https://github.com/buzz/buzz/blob/main/SECURITY.md">SECURITY.md</a> for details.</p>
      </Section>

      <Section title="Under-13">
        <p>Buzz is not directed to children under 13. We do not knowingly collect data from users under 13. If you believe a child has provided us data, contact <a className="underline" href="mailto:privacy@buzz.app">privacy@buzz.app</a> and we'll delete it.</p>
      </Section>

      <Section title="Changes">
        <p>If we change this policy in any material way, we'll notify you in-app before the change takes effect.</p>
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
