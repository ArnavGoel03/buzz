"use client";

import { useRef } from "react";
import { motion, useScroll, useTransform } from "framer-motion";
import type { Organization } from "@/lib/types";
import TextReveal from "./landing/TextReveal";

// Parallax club cover — accent-color orb zooms + fades on scroll, grain overlay,
// serif name reveals word-by-word. Matches EventHero's treatment.
export default function OrgHero({ org }: { org: Organization }) {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({ target: ref, offset: ["start start", "end start"] });
  const y = useTransform(scrollYProgress, [0, 1], [0, 120]);
  const scale = useTransform(scrollYProgress, [0, 1], [1, 1.2]);
  const fade = useTransform(scrollYProgress, [0, 1], [1, 0.3]);

  return (
    <div ref={ref} className="relative h-[36vh] md:h-[44vh] overflow-hidden">
      <motion.div
        aria-hidden
        className="absolute inset-0 pointer-events-none"
        style={{
          y, scale, opacity: fade,
          background: `radial-gradient(circle at 75% 25%, ${org.accent_hex}66, transparent 55%), linear-gradient(180deg, ${org.accent_hex}33, transparent 70%)`,
          filter: "blur(4px)",
        }}
      />
      <div
        aria-hidden
        className="absolute inset-0 mix-blend-overlay opacity-35 pointer-events-none"
        style={{
          backgroundImage:
            "url(\"data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='120' height='120'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='2' stitchTiles='stitch'/><feColorMatrix values='0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 0.08 0'/></filter><rect width='100%' height='100%' filter='url(%23n)'/></svg>\")",
        }}
      />
      <div className="absolute inset-x-0 bottom-0 p-5 md:p-10">
        <p className="font-mono text-[10px] uppercase tracking-[0.18em] text-white/60">
          {org.category ?? "Organization"} · {org.campus?.toUpperCase() ?? ""}
        </p>
        <h1
          className="mt-3 font-display font-medium tracking-[-0.03em] leading-[0.96] text-[clamp(2rem,6vw,5rem)]"
          style={{ fontFamily: "var(--font-display)" }}
        >
          <TextReveal text={org.name} />
        </h1>
      </div>
      <div className="absolute inset-x-0 bottom-0 h-24 bg-gradient-to-b from-transparent to-[var(--color-bg)] pointer-events-none" />
    </div>
  );
}
