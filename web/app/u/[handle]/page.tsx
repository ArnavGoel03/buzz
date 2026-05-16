import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { Flame, CalendarCheck, Award, Clock } from "lucide-react";
import ProfileHero from "@/components/ProfileHero";
import CountUp from "@/components/landing/CountUp";
import { createClient } from "@/lib/supabase-server";
import { safeJsonLd } from "@/lib/security";

type Params = Promise<{ handle: string }>;

// Public handles are lowercase ASCII; reject anything else early so we never
// SSR a phantom profile for `/u/<garbage>`.
const HANDLE_RE = /^[a-z0-9_]{2,30}$/;

type ProfileRow = {
  handle: string;
  display_name: string;
  bio: string | null;
  campus: string | null;
  streak: number | null;
  events_attended: number | null;
  badges: number | null;
};

async function loadProfile(handle: string): Promise<ProfileRow | null> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("profiles")
    .select("handle, display_name, bio, campus, streak, events_attended, badges")
    .eq("handle", handle)
    .maybeSingle<ProfileRow>();
  return data ?? null;
}

export async function generateMetadata({ params }: { params: Params }): Promise<Metadata> {
  const { handle } = await params;
  if (!HANDLE_RE.test(handle)) return { title: "Profile", robots: { index: false } };
  const profile = await loadProfile(handle);
  if (!profile) return { title: "Profile", robots: { index: false } };

  const title = `@${profile.handle}`;
  const description = profile.bio?.trim()
    ? profile.bio
    : `${profile.display_name} on Buzz — college events, RSVPs, and clubs${profile.campus ? ` at ${profile.campus}` : ""}.`;
  return {
    title, description,
    alternates: { canonical: `https://buzz.app/u/${profile.handle}` },
    openGraph: {
      title, description, type: "profile",
      url: `https://buzz.app/u/${profile.handle}`,
      images: [{ url: `https://buzz.app/api/poster/${profile.handle}`, width: 1200, height: 630, alt: title }],
    },
    twitter: { card: "summary_large_image", title, description },
  };
}

export default async function UserProfile({ params }: { params: Params }) {
  const { handle } = await params;
  if (!HANDLE_RE.test(handle)) notFound();
  const profile = await loadProfile(handle);
  if (!profile) notFound();

  const personJsonLd = {
    "@context": "https://schema.org",
    "@type": "Person",
    name: profile.display_name,
    alternateName: `@${profile.handle}`,
    url: `https://buzz.app/u/${profile.handle}`,
    description: profile.bio ?? undefined,
    affiliation: profile.campus
      ? { "@type": "CollegeOrUniversity", name: profile.campus }
      : undefined,
  };

  return (
    <article>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: safeJsonLd(personJsonLd) }}
      />

      <ProfileHero
        displayName={profile.display_name}
        handle={profile.handle}
        campus={profile.campus ?? ""}
        bio={profile.bio ?? ""}
      />

      <div className="max-w-3xl mx-auto px-4 md:px-8 -mt-4 relative z-10">
        <div className="grid grid-cols-3 gap-px rounded-2xl overflow-hidden border border-[var(--color-border)] bg-[var(--color-border)]">
          <Stat icon={<Flame size={14} />} label="Streak" value={
            <><CountUp value={profile.streak ?? 0} /> <span className="text-base font-normal text-[var(--color-text-tertiary)]">days</span></>
          } />
          <Stat icon={<CalendarCheck size={14} />} label="Attended" value={<CountUp value={profile.events_attended ?? 0} />} />
          <Stat icon={<Award size={14} />} label="Badges" value={<CountUp value={profile.badges ?? 0} />} accent />
        </div>

        <section className="mt-10">
          <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-[var(--color-text-tertiary)] mb-3">
            § Recent activity
          </p>
          <div className="rim rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)] p-6 flex items-center gap-4">
            <div className="w-10 h-10 rounded-xl bg-[var(--color-accent-dim)] text-[var(--color-accent)] flex items-center justify-center">
              <Clock size={18} />
            </div>
            <div>
              <p className="font-semibold text-sm">Recent activity is private by default</p>
              <p className="text-xs text-[var(--color-text-tertiary)] mt-0.5">
                Open in the app to see check-ins, RSVPs, and badges {profile.handle} has shared with you.
              </p>
            </div>
          </div>
        </section>

        <div className="h-16 md:h-8" />
      </div>
    </article>
  );
}

function Stat({ icon, label, value, accent }: {
  icon: React.ReactNode; label: string; value: React.ReactNode; accent?: boolean;
}) {
  return (
    <div className="bg-[var(--color-surface)] p-5">
      <div className="flex items-center gap-1.5 font-mono text-[10px] uppercase tracking-[0.18em] text-[var(--color-text-tertiary)]">
        {icon} {label}
      </div>
      <div
        className={`mt-2 font-display tabular text-3xl md:text-4xl font-medium leading-none ${accent ? "text-[var(--color-accent)]" : ""}`}
        style={{ fontFamily: "var(--font-display)" }}
      >
        {value}
      </div>
    </div>
  );
}
