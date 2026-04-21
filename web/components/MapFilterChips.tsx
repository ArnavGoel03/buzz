"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Flame, Music, Pizza, Users, Medal, BookOpen, Briefcase } from "lucide-react";
import type { EventCategory } from "@/lib/types";

const CHIPS: { cat: EventCategory | "all"; label: string; icon: React.ReactNode; color: string }[] = [
  { cat: "all",      label: "All",      icon: <Flame size={12} />,      color: "#FFD60A" },
  { cat: "party",    label: "Parties",  icon: <Music size={12} />,      color: "#FF2D92" },
  { cat: "free_food",label: "Free food",icon: <Pizza size={12} />,      color: "#34C759" },
  { cat: "club",     label: "Clubs",    icon: <Users size={12} />,      color: "#FFD60A" },
  { cat: "sports",   label: "Sports",   icon: <Medal size={12} />,      color: "#FF9500" },
  { cat: "academic", label: "Academic", icon: <BookOpen size={12} />,   color: "#5AC8FA" },
  { cat: "career",   label: "Career",   icon: <Briefcase size={12} />,  color: "#0A84FF" },
  { cat: "greek",    label: "Greek",    icon: <Users size={12} />,      color: "#BF5AF2" },
];

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
              color: active ? "#000" : c.color,
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
