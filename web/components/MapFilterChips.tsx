"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Flame, Music, Pizza, Users, Medal, BookOpen, Briefcase, Sparkle } from "lucide-react";
import type { EventCategory } from "@/lib/types";
import { categoryColor, categoryPlural } from "@/lib/categories";
import { COLOR } from "@/lib/tokens";

// Icons only. Colour and label come from lib/categories.ts, which reads
// design/tokens.json, so a hue change lands here without anyone touching this file.
const ICONS: Record<EventCategory | "all", React.ReactNode> = {
  all: <Flame size={12} />,
  party: <Music size={12} />,
  free_food: <Pizza size={12} />,
  club: <Users size={12} />,
  sports: <Medal size={12} />,
  academic: <BookOpen size={12} />,
  career: <Briefcase size={12} />,
  greek: <Users size={12} />,
  other: <Sparkle size={12} />,
};

const ORDER: (EventCategory | "all")[] = [
  "all", "party", "free_food", "club", "sports", "academic", "career", "greek",
];

const CHIPS = ORDER.map((cat) => ({
  cat,
  label: cat === "all" ? "All" : categoryPlural(cat),
  icon: ICONS[cat],
  color: cat === "all" ? COLOR.accent : categoryColor(cat).color,
}));

export default function MapFilterChips({
  selected,
  onSelect,
}: {
  selected: EventCategory | "all";
  onSelect: (cat: EventCategory | "all") => void;
}) {
  return (
    <div
      className="absolute top-4 left-1/2 -translate-x-1/2 z-20 flex gap-1.5 px-2 py-1.5 rounded-full rim border border-white/10 overflow-x-auto max-w-[calc(100%-340px-2rem)] md:max-w-[60vw]"
      style={{
        background: "linear-gradient(140deg, rgba(20,20,28,0.78), rgba(10,10,16,0.68))",
        backdropFilter: "blur(18px)",
        WebkitBackdropFilter: "blur(18px)",
      }}
    >
      {CHIPS.map((c) => {
        const active = selected === c.cat;
        return (
          <button
            key={c.cat}
            onClick={() => onSelect(c.cat)}
            className="relative flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold whitespace-nowrap transition-colors"
            style={{
              color: active ? COLOR.accentInk : c.color,
            }}
          >
            <AnimatePresence>
              {active && (
                <motion.span
                  layoutId="chip-bg"
                  className="absolute inset-0 rounded-full"
                  style={{ background: c.color }}
                  transition={{ type: "spring", stiffness: 400, damping: 36 }}
                />
              )}
            </AnimatePresence>
            <span className="relative z-10 flex items-center gap-1.5">
              {c.icon}
              {c.label}
            </span>
          </button>
        );
      })}
    </div>
  );
}
