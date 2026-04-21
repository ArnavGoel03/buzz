import Link from "next/link";
import { MapPin, Clock, Users } from "lucide-react";
import type { Event } from "@/lib/types";
import { categoryColor, categoryLabel } from "@/lib/categories";
import { formatRelativeTime } from "@/lib/format";

export default function EventCard({ event }: { event: Event }) {
  const { color, soft } = categoryColor(event.category);
  const time = formatRelativeTime(event.starts_at);

  return (
    <Link
      href={`/e/${event.id}`}
      className="block rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)] hover:border-[var(--color-border-strong)] p-5 transition-colors"
    >
      <div className="flex items-start justify-between gap-4">
        <div className="flex items-center gap-2">
          <span
            className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold uppercase tracking-wider"
            style={{ background: soft, color }}
          >
            {event.is_live && <span className="w-1.5 h-1.5 rounded-full bg-[var(--color-live)] pulse-live" />}
            {categoryLabel(event.category)}
          </span>
        </div>
        {typeof event.attendee_count === "number" && (
          <span className="flex items-center gap-1 text-xs text-[var(--color-text-tertiary)]">
            <Users size={12} />
            {event.attendee_count}
          </span>
        )}
      </div>
      <h3
        className="mt-3 text-xl font-black tracking-tight leading-tight"
        style={{ fontFamily: "var(--font-display)" }}
      >
        {event.title}
      </h3>
      <p className="mt-1.5 text-sm text-[var(--color-text-secondary)] line-clamp-2">
        {event.summary}
      </p>
      <div className="mt-4 flex items-center gap-4 text-xs text-[var(--color-text-tertiary)]">
        <span className="flex items-center gap-1.5">
          <Clock size={12} />
          {time}
        </span>
        <span className="flex items-center gap-1.5 truncate">
          <MapPin size={12} />
          {event.location_name}
        </span>
      </div>
    </Link>
  );
}
