import { Flame } from "lucide-react";
import type { Event } from "@/lib/types";
import { categoryColor } from "@/lib/categories";

// Horizontal infinite-scroll ticker of live + imminent events. Signals "real product,
// real density" in a way static cards can't. Duplicated track so the scroll loops
// seamlessly. Pauses on hover so users can actually read it.
export default function LiveTicker({ events }: { events: Event[] }) {
  const show = events.slice(0, 12);
  if (show.length === 0) return null;
  return (
    <div className="relative overflow-hidden border-y border-[var(--color-border)] bg-[var(--color-bg-elevated)]/60">
      <div className="absolute left-0 top-0 bottom-0 w-32 z-10 bg-gradient-to-r from-[var(--color-bg-elevated)] to-transparent pointer-events-none" />
      <div className="absolute right-0 top-0 bottom-0 w-32 z-10 bg-gradient-to-l from-[var(--color-bg-elevated)] to-transparent pointer-events-none" />
      <div className="ticker-track flex gap-10 py-3.5 whitespace-nowrap">
        {[...show, ...show].map((e, i) => (
          <TickerItem key={`${e.id}-${i}`} event={e} />
        ))}
      </div>
    </div>
  );
}

function TickerItem({ event }: { event: Event }) {
  const { color } = categoryColor(event.category);
  return (
    <span className="inline-flex items-center gap-2 text-sm">
      {event.is_live ? (
        <Flame size={14} style={{ color: "var(--color-live)" }} />
      ) : (
        <span className="w-2 h-2 rounded-full" style={{ background: color }} />
      )}
      <span className="font-mono text-[11px] text-[var(--color-text-tertiary)] uppercase tracking-wider">
        {event.host_name}
      </span>
      <span className="font-semibold">{event.title}</span>
      <span className="text-[var(--color-text-tertiary)]">·</span>
      <span className="text-[var(--color-text-secondary)]">{event.location_name}</span>
    </span>
  );
}
