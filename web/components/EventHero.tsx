"use client";

import { useRef } from "react";
import { motion, useScroll, useTransform } from "framer-motion";
import type { Event } from "@/lib/types";
import { categoryColor, categoryLabel } from "@/lib/categories";
import TextReveal from "./landing/TextReveal";

// Parallax event hero: category-tinted gradient orb zooms/drifts on scroll,
// serif title reveals word-by-word. Replaces the static color block with
// something that actually sells the event.
export default function EventHero({ event }: { event: Event }) {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({ target: ref, offset: ["start start", "end start"] });
  const y = useTransform(scrollYProgress, [0, 1], [0, 160]);
  const scale = useTransform(scrollYProgress, [0, 1], [1, 1.15]);
  const fade = useTransform(scrollYProgress, [0, 1], [1, 0.3]);

  const { color, soft } = categoryColor(event.category);

  return (
    <div ref={ref} className="relative h-[44vh] md:h-[56vh] overflow-hidden">
      {/* Base tint */}
      <div className="absolute inset-0" style={{ background: `linear-gradient(180deg, ${soft}, transparent 70%)` }} />
      {/* Parallax radial orb */}
      <motion.div
        aria-hidden
        className="absolute inset-0 pointer-events-none"
        style={{
          y, scale, opacity: fade,
          background: `radial-gradient(circle at 70% 25%, ${color}55, transparent 55%)`,
          filter: "blur(8px)",
        }}
      />
      {/* Grain */}
      <div
        aria-hidden
        className="absolute inset-0 mix-blend-overlay opacity-40 pointer-events-none"
        style={{
          backgroundImage:
            "url(\"data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='120' height='120'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='2' stitchTiles='stitch'/><feColorMatrix values='0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 0.08 0'/></filter><rect width='100%' height='100%' filter='url(%23n)'/></svg>\")",
        }}
      />

      {/* Copy */}
      <div className="absolute left-0 right-0 bottom-0 p-5 md:p-10">
        <div className="flex items-center gap-2 mb-4">
          <span
            className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-[0.14em]"
            style={{ background: soft, color }}
          >
            {event.is_live && (
              <span className="w-1.5 h-1.5 rounded-full pulse-live" style={{ background: color }} />
            )}
            {categoryLabel(event.category)}
          </span>
          <span className="font-mono text-[10px] uppercase tracking-[0.16em] text-white/60">
            Hosted by {event.host_name}
          </span>
        </div>
        <h1
          className="font-display font-medium tracking-[-0.03em] leading-[0.96] text-[clamp(2rem,6.5vw,5rem)] max-w-3xl"
          style={{ fontFamily: "var(--font-display)" }}
        >
          <TextReveal text={event.title} />
        </h1>
      </div>

      {/* Bottom fade into page */}
      <div className="absolute left-0 right-0 bottom-0 h-24 bg-gradient-to-b from-transparent to-[var(--color-bg)] pointer-events-none" />
    </div>
  );
}
