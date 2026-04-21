import Link from "next/link";
import { MapPin, Users, ArrowUpRight } from "lucide-react";
import type { Event } from "@/lib/types";
import { categoryColor, categoryLabel } from "@/lib/categories";
import { formatRelativeTime } from "@/lib/format";

// Bento-box feed: first card spans 2×, live events get rim glow, mono timestamps,
// category color bar on the left. Varied visual rhythm beats a uniform grid for
// "I spent real time on this" energy.
export default function BentoFeed({ events }: { events: Event[] }) {
  if (events.length === 0) return null;
  const [feature, ...rest] = events;
  return (
    <div className="grid grid-cols-1 md:grid-cols-6 gap-3 md:gap-4">
      <BentoCard event={feature} span="md:col-span-4 md:row-span-2" featured />
      {rest.slice(0, 8).map((e) => (
        <BentoCard key={e.id} event={e} span="md:col-span-2" />
      ))}
    </div>
  );
}

function BentoCard({ event, span, featured }: { event: Event; span: string; featured?: boolean }) {
  const { color, soft } = categoryColor(event.category);
  const isLive = event.is_live;
  return (
    <Link
      href={`/e/${event.id}`}
      className={`group relative rim rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)] overflow-hidden transition-all hover:border-[var(--color-border-strong)] hover:-translate-y-0.5 ${span}`}
      style={
        isLive
          ? { boxShadow: `0 0 0 1px ${color}66, 0 8px 24px -8px ${color}33` }
          : undefined
      }
    >
      <div
        className="absolute left-0 top-0 bottom-0 w-[3px]"
        style={{ background: color }}
      />
      {featured && (
        <div
          className="absolute inset-0 opacity-40 pointer-events-none"
          style={{ background: `radial-gradient(circle at 80% 20%, ${color}22, transparent 55%)` }}
        />
      )}
      <div className={`relative p-5 ${featured ? "md:p-7 h-full flex flex-col" : ""}`}>
        <div className="flex items-center justify-between gap-3">
          <span
            className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-[0.1em]"
            style={{ background: soft, color }}
          >
            {isLive && <span className="w-1.5 h-1.5 rounded-full pulse-live" style={{ background: color }} />}
            {categoryLabel(event.category)}
          </span>
          <span className="font-mono text-[10px] text-[var(--color-text-tertiary)] tabular">
            {formatRelativeTime(event.starts_at)}
          </span>
        </div>

        <h3
          className={`mt-3 font-display font-medium tracking-[-0.015em] leading-[1.05] ${
            featured ? "text-3xl md:text-4xl" : "text-xl"
          }`}
          style={{ fontFamily: "var(--font-display)" }}
        >
          {event.title}
        </h3>

        {featured && (
          <p className="mt-3 text-[var(--color-text-secondary)] line-clamp-3 max-w-md">
            {event.summary}
          </p>
        )}

        <div className={`flex items-center gap-3 text-xs text-[var(--color-text-tertiary)] ${featured ? "mt-auto pt-6" : "mt-4"}`}>
          <span className="flex items-center gap-1.5 truncate">
            <MapPin size={12} />
            {event.location_name}
          </span>
          {typeof event.attendee_count === "number" && (
            <>
              <span>·</span>
              <span className="flex items-center gap-1 font-mono tabular">
                <Users size={12} /> {event.attendee_count}
              </span>
            </>
          )}
          <ArrowUpRight
            size={14}
            className="ml-auto text-[var(--color-text-tertiary)] transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5"
          />
        </div>
      </div>
    </Link>
  );
}
