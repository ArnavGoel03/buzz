import type { Metadata } from "next";
import { Flame, CalendarCheck, Award } from "lucide-react";

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
    <div className="max-w-3xl mx-auto px-4 md:px-8 py-6">
      <div className="flex items-start gap-5">
        <div
          className="w-24 h-24 rounded-full flex items-center justify-center text-4xl font-black border-2 border-[var(--color-border-strong)]"
          style={{ background: "linear-gradient(135deg, var(--color-accent), #ff9500)", color: "#000", fontFamily: "var(--font-display)" }}
        >
          {profile.display_name[0]}
        </div>
        <div className="min-w-0 flex-1">
          <h1
            className="text-2xl md:text-3xl font-black tracking-tight"
            style={{ fontFamily: "var(--font-display)" }}
          >
            {profile.display_name}
          </h1>
          <p className="text-sm text-[var(--color-text-tertiary)]">@{profile.handle} · {profile.campus}</p>
          <p className="mt-2 text-sm">{profile.bio}</p>
        </div>
      </div>

      <div className="mt-8 grid grid-cols-3 gap-3">
        <Stat icon={<Flame size={18} />} label="Streak" value={`${profile.streak} days`} />
        <Stat icon={<CalendarCheck size={18} />} label="Attended" value={`${profile.events_attended}`} />
        <Stat icon={<Award size={18} />} label="Badges" value={`${profile.badges}`} />
      </div>

      <section className="mt-10">
        <h2 className="text-sm font-bold uppercase tracking-wider text-[var(--color-text-tertiary)] mb-3">
          Recent activity
        </h2>
        <p className="text-sm text-[var(--color-text-tertiary)] p-4 rounded-xl bg-[var(--color-surface)] border border-[var(--color-border)]">
          Activity feed hydrates from your RSVPs and check-ins in Phase 2.
        </p>
      </section>
      <div className="h-16 md:h-0" />
    </div>
  );
}

function Stat({ icon, label, value }: { icon: React.ReactNode; label: string; value: string }) {
  return (
    <div className="rounded-xl bg-[var(--color-surface)] border border-[var(--color-border)] p-4">
      <div className="text-[var(--color-accent)]">{icon}</div>
      <p className="mt-2 text-lg font-black">{value}</p>
      <p className="text-xs text-[var(--color-text-tertiary)]">{label}</p>
    </div>
  );
}
