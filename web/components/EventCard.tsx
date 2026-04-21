import Link from "next/link";
import { MapPin, Users, ArrowUpRight } from "lucide-react";
import type { Event } from "@/lib/types";
import { categoryColor, categoryLabel } from "@/lib/categories";
import { formatRelativeTime } from "@/lib/format";

// Secondary event card — used outside the bento grid (club pages, search). Still
// carries the category bar + mono time for brand consistency.
export default function EventCard({ event }: { event: Event }) {
  const { color, soft } = categoryColor(event.category);

  return (
    <Link
      href={`/e/${event.id}`}
      className="group relative rim block rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)] hover:border-[var(--color-border-strong)] hover:-translate-y-0.5 transition-all overflow-hidden"
    >
      <div className="absolute left-0 top-0 bottom-0 w-[3px]" style={{ background: color }} />
      <div className="relative p-5 pl-6">
        <div className="flex items-center justify-between gap-3">
          <span
            className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-[0.1em]"
            style={{ background: soft, color }}
          >
            {event.is_live && <span className="w-1.5 h-1.5 rounded-full pulse-live" style={{ background: color }} />}
            {categoryLabel(event.category)}
          </span>
          <span className="font-mono text-[10px] text-[var(--color-text-tertiary)] tabular">
            {formatRelativeTime(event.starts_at)}
          </span>
        </div>
        <h3
          className="mt-3 font-display text-xl leading-[1.1] tracking-[-0.015em] font-medium"
          style={{ fontFamily: "var(--font-display)" }}
        >
          {event.title}
        </h3>
        {event.summary && (
          <p className="mt-1.5 text-sm text-[var(--color-text-secondary)] line-clamp-2">{event.summary}</p>
        )}
        <div className="mt-4 flex items-center gap-3 text-xs text-[var(--color-text-tertiary)]">
          <span className="flex items-center gap-1.5 truncate">
            <MapPin size={12} /> {event.location_name}
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
            className="ml-auto transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5"
          />
        </div>
      </div>
    </Link>
  );
}
