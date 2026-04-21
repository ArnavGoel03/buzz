"use client";

import { motion } from "framer-motion";
import { Radio, Users, Sparkles } from "lucide-react";
import type { Event } from "@/lib/types";

// Glass stats panel pinned to the top-left of the map. Conveys "real product,
// live data" at a glance. Slides in + fades up on mount.
export default function MapStatsPanel({
  events,
  campusName,
}: {
  events: Event[];
  campusName: string;
}) {
  const live = events.filter((e) => e.is_live).length;
  const total = events.length;
  const attendees = events.reduce((a, e) => a + (e.attendee_count ?? 0), 0);

  return (
    <motion.div
      initial={{ opacity: 0, y: -10, filter: "blur(10px)" }}
      animate={{ opacity: 1, y: 0, filter: "blur(0px)" }}
      transition={{ duration: 0.55, ease: [0.16, 1, 0.3, 1] }}
      className="absolute top-4 left-4 z-20 w-[min(340px,calc(100vw-2rem))] rim rounded-2xl overflow-hidden"
      style={{
        background: "linear-gradient(140deg, rgba(20,20,28,0.82), rgba(10,10,16,0.72))",
        backdropFilter: "blur(18px)",
        WebkitBackdropFilter: "blur(18px)",
      }}
    >
      <div className="px-4 pt-4">
        <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-white/50">
          Live map · {campusName}
        </p>
        <h2
          className="mt-1.5 font-display text-2xl font-medium tracking-[-0.02em]"
          style={{ fontFamily: "var(--font-display)" }}
        >
          Happening now
        </h2>
      </div>
      <div className="grid grid-cols-3 gap-px bg-white/5 mt-3">
        <Stat icon={<Radio size={12} />} label="Live" value={live} accent />
        <Stat icon={<Sparkles size={12} />} label="Events" value={total} />
        <Stat icon={<Users size={12} />} label="Going" value={attendees.toLocaleString()} />
      </div>
    </motion.div>
  );
}

function Stat({
  icon, label, value, accent,
}: { icon: React.ReactNode; label: string; value: string | number; accent?: boolean }) {
  return (
    <div className="p-3 bg-[var(--color-surface)]/60">
      <div className={`flex items-center gap-1.5 text-[10px] uppercase tracking-wider ${accent ? "text-[var(--color-live)]" : "text-white/50"}`}>
        {icon} {label}
      </div>
      <div
        className={`mt-1 font-display tabular font-medium text-xl ${accent ? "text-[var(--color-live)]" : ""}`}
        style={{ fontFamily: "var(--font-display)" }}
      >
        {value}
      </div>
    </div>
  );
}
