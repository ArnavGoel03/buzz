import Link from "next/link";
import SignOutButton from "@/components/SignOutButton";
import { createClient } from "@/lib/supabase-server";

export const metadata = { title: "Settings" };

export default async function Settings() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  return (
    <div className="max-w-2xl mx-auto px-4 md:px-8 py-10">
      <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-[var(--color-text-tertiary)]">
        § Settings
      </p>
      <h1
        className="mt-3 font-display font-medium tracking-[-0.02em] leading-[1] text-4xl md:text-5xl"
        style={{ fontFamily: "var(--font-display)" }}
      >
        Your account,{" "}
        <span className="italic text-[var(--color-accent)]" style={{ fontVariationSettings: "'SOFT' 80, 'WONK' 1" }}>your rules.</span>
      </h1>

      <Section title="Account">
        {user ? (
          <Row label="Signed in as" value={user.email ?? ""} />
        ) : (
          <div className="p-4 rounded-xl bg-[var(--color-surface)] border border-[var(--color-border)] flex items-center justify-between">
            <span className="text-sm">You&apos;re signed out.</span>
            <Link href="/sign-in" className="text-sm font-bold text-[var(--color-accent)]">
              Sign in →
            </Link>
          </div>
        )}
      </Section>

      <Section title="Notifications">
        <Toggle label="Free food alerts" defaultOn />
        <Toggle label="Friends RSVP to events" defaultOn />
        <Toggle label="Morning digest" defaultOn />
      </Section>

      <Section title="Privacy">
        <LinkRow href="/settings/blocked">Blocked users</LinkRow>
        <LinkRow href="/settings/export">Download my data</LinkRow>
      </Section>

      <Section title="Legal">
        <LinkRow href="/legal/privacy">Privacy Policy</LinkRow>
        <LinkRow href="/legal/terms">Terms of Service</LinkRow>
        <LinkRow href="/support">Support</LinkRow>
      </Section>

      {user && (
        <Section title="">
          <SignOutButton />
        </Section>
      )}

      <p className="mt-10 text-xs text-[var(--color-text-tertiary)] text-center">
        Buzz · Built at a US college for US colleges.
      </p>
      <div className="h-16 md:h-0" />
    </div>
  );
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section className="mt-8">
      {title && (
        <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-[var(--color-text-tertiary)] mb-2 px-1">
          § {title}
        </p>
      )}
      <div className="rim rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)] divide-y divide-[var(--color-border)] overflow-hidden">
        {children}
      </div>
    </section>
  );
}

function Row({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center justify-between p-4">
      <span className="text-sm text-[var(--color-text-secondary)]">{label}</span>
      <span className="text-sm font-semibold truncate ml-4">{value}</span>
    </div>
  );
}

function Toggle({ label, defaultOn }: { label: string; defaultOn?: boolean }) {
  return (
    <label className="flex items-center justify-between p-4 cursor-pointer">
      <span className="text-sm">{label}</span>
      <input type="checkbox" defaultChecked={defaultOn} className="accent-[var(--color-accent)] w-5 h-5" />
    </label>
  );
}

function LinkRow({ href, children }: { href: string; children: React.ReactNode }) {
  return (
    <Link href={href} className="flex items-center justify-between p-4 hover:bg-white/[0.02]">
      <span className="text-sm">{children}</span>
      <span className="text-[var(--color-text-tertiary)]">›</span>
    </Link>
  );
}
