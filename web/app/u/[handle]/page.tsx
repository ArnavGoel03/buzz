import type { Metadata } from "next";
import { Flame, CalendarCheck, Award, Clock } from "lucide-react";
import ProfileHero from "@/components/ProfileHero";
import CountUp from "@/components/landing/CountUp";

type Params = Promise<{ handle: string }>;

export async function generateMetadata({ params }: { params: Params }): Promise<Metadata> {
  const { handle } = await params;
  return {
    title: `@${handle}`,
    description: `@${handle} on Buzz — college events, RSVPs, and clubs.`,
    openGraph: {
      title: `@${handle}`,
      description: "On Buzz",
      type: "profile",
      url: `https://buzz.app/u/${handle}`,
    },
  };
}

export default async function UserProfile({ params }: { params: Params }) {
  const { handle } = await params;
  // Phase 2: hydrate from supabase.from("profiles").select("*").eq("handle", handle)
  const profile = {
    handle,
    display_name: handle.replace(/^./, (c) => c.toUpperCase()),
    bio: "Building things at UCSD. On Buzz.",
    campus: "UCSD",
    streak: 7,
    events_attended: 34,
    badges: 5,
  };

  return (
    <article>
      <ProfileHero
        displayName={profile.display_name}
        handle={profile.handle}
        campus={profile.campus}
        bio={profile.bio}
      />

      <div className="max-w-3xl mx-auto px-4 md:px-8 -mt-4 relative z-10">
        <div className="grid grid-cols-3 gap-px rounded-2xl overflow-hidden border border-[var(--color-border)] bg-[var(--color-border)]">
          <Stat icon={<Flame size={14} />} label="Streak" value={<><CountUp value={profile.streak} /> <span className="text-base font-normal text-[var(--color-text-tertiary)]">days</span></>} />
          <Stat icon={<CalendarCheck size={14} />} label="Attended" value={<CountUp value={profile.events_attended} />} />
          <Stat icon={<Award size={14} />} label="Badges" value={<CountUp value={profile.badges} />} accent />
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
              <p className="font-semibold text-sm">Activity feed rendering in Phase 2</p>
              <p className="text-xs text-[var(--color-text-tertiary)] mt-0.5">
                Streaks, check-ins and RSVPs hydrate from Supabase once env vars are wired.
              </p>
            </div>
          </div>
        </section>

        <div className="h-16 md:h-8" />
      </div>
    </article>
  );
}

function Stat({
  icon, label, value, accent,
}: {
  icon: React.ReactNode;
  label: string;
  value: React.ReactNode;
  accent?: boolean;
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
