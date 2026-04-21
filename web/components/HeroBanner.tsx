import Link from "next/link";
import { ArrowRight, Sparkles } from "lucide-react";
import CampusPicker from "./CampusPicker";

type Props = {
  campusName: string;
  eventCount: number;
  liveCount: number;
};

export default function HeroBanner({ campusName, eventCount, liveCount }: Props) {
  const now = new Date();
  const dow = now.toLocaleDateString("en-US", { weekday: "long" });
  return (
    <section className="relative px-4 md:px-8 pt-8 md:pt-14 pb-10">
      <div className="flex items-center gap-2 mb-6">
        <span className="flex items-center gap-1.5 font-mono text-[11px] uppercase tracking-[0.18em] text-[var(--color-text-tertiary)]">
          <span className="w-1.5 h-1.5 rounded-full bg-[var(--color-accent)] pulse-live" />
          {dow} · {campusName}
        </span>
        <CampusPicker name={campusName} />
      </div>

      <h1
        className="reveal font-display text-[clamp(2.5rem,7vw,5.5rem)] leading-[0.96] tracking-[-0.03em] font-medium"
        style={{ fontFamily: "var(--font-display)" }}
      >
        Every event.{" "}
        <em className="italic font-light text-[var(--color-accent)]" style={{ fontVariationSettings: "'SOFT' 80, 'WONK' 1" }}>
          One feed.
        </em>
      </h1>

      <div className="reveal mt-6 grid grid-cols-[auto_1fr] gap-6 md:gap-10 max-w-3xl" style={{ animationDelay: "0.1s" }}>
        <StatPill label="Events tonight" value={eventCount} />
        <p className="text-base md:text-lg text-[var(--color-text-secondary)] leading-relaxed max-w-xl">
          {liveCount > 0 ? (
            <><span className="tabular font-mono text-[var(--color-live)] font-bold">{liveCount} live now</span> — parties, free food, clubs, sports, seminars, career fairs. Filtered to your campus, sorted by what&apos;s about to start.</>
          ) : (
            <>Parties, free food, clubs, sports, seminars, career fairs — filtered to your campus, sorted by what&apos;s about to start.</>
          )}
        </p>
      </div>

      <div className="reveal mt-8 flex flex-wrap items-center gap-3" style={{ animationDelay: "0.2s" }}>
        <Link
          href="/map"
          className="group inline-flex items-center gap-2 h-11 px-5 rounded-xl bg-[var(--color-accent)] text-black font-semibold text-sm"
        >
          Open live map
          <ArrowRight size={14} className="transition-transform group-hover:translate-x-0.5" />
        </Link>
        <Link
          href="/clubs"
          className="inline-flex items-center gap-2 h-11 px-5 rounded-xl bg-[var(--color-surface)] border border-[var(--color-border-strong)] font-semibold text-sm hover:border-[var(--color-border-bright)]"
        >
          Browse clubs
        </Link>
        <button
          data-cmdk
          className="hidden md:inline-flex items-center gap-2 h-11 px-3 rounded-xl bg-[var(--color-surface)] border border-[var(--color-border)] font-mono text-xs text-[var(--color-text-tertiary)]"
        >
          <Sparkles size={12} /> <span>⌘K</span>
        </button>
      </div>
    </section>
  );
}

function StatPill({ label, value }: { label: string; value: number }) {
  return (
    <div className="shrink-0">
      <div className="font-display tabular text-[clamp(2rem,5vw,3.25rem)] leading-none font-medium">
        {value}
      </div>
      <div className="mt-1 font-mono text-[10px] uppercase tracking-[0.18em] text-[var(--color-text-tertiary)]">
        {label}
      </div>
    </div>
  );
}
