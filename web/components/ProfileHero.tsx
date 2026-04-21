"use client";

import { useRef } from "react";
import { motion, useScroll, useTransform } from "framer-motion";
import TextReveal from "./landing/TextReveal";

// Parallax user profile hero: giant serif initial bleeds into the background,
// display name reveals, meta strip with mono/tracking.
export default function ProfileHero({
  displayName,
  handle,
  campus,
  bio,
  accentHex = "#FFD60A",
}: {
  displayName: string;
  handle: string;
  campus?: string;
  bio?: string;
  accentHex?: string;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({ target: ref, offset: ["start start", "end start"] });
  const y = useTransform(scrollYProgress, [0, 1], [0, 120]);
  const scale = useTransform(scrollYProgress, [0, 1], [1, 1.15]);
  const glyphY = useTransform(scrollYProgress, [0, 1], [0, -40]);
  const glyphOpacity = useTransform(scrollYProgress, [0, 1], [0.38, 0.08]);

  const initial = displayName.slice(0, 1).toUpperCase();

  return (
    <div ref={ref} className="relative h-[46vh] md:h-[52vh] overflow-hidden">
      <motion.div
        aria-hidden
        className="absolute inset-0 pointer-events-none"
        style={{
          y, scale,
          background: `radial-gradient(circle at 78% 22%, ${accentHex}55, transparent 55%), linear-gradient(180deg, ${accentHex}22, transparent 70%)`,
          filter: "blur(6px)",
        }}
      />
      {/* Giant serif initial floating in the background */}
      <motion.div
        aria-hidden
        className="absolute right-[-4vw] top-[2vh] font-display font-medium leading-none tracking-[-0.08em] select-none text-[clamp(20rem,42vw,48rem)]"
        style={{
          y: glyphY,
          opacity: glyphOpacity,
          color: accentHex,
          fontFamily: "var(--font-display)",
        }}
      >
        {initial}
      </motion.div>

      <div className="absolute inset-x-0 bottom-0 p-5 md:p-10">
        <p className="font-mono text-[10px] uppercase tracking-[0.18em] text-white/60">
          @{handle}{campus ? ` · ${campus.toUpperCase()}` : ""}
        </p>
        <h1
          className="mt-3 font-display font-medium tracking-[-0.03em] leading-[0.96] text-[clamp(2rem,6vw,5rem)]"
          style={{ fontFamily: "var(--font-display)" }}
        >
          <TextReveal text={displayName} />
        </h1>
        {bio && (
          <p className="mt-3 text-base md:text-lg text-white/70 max-w-xl">{bio}</p>
        )}
      </div>
      <div className="absolute inset-x-0 bottom-0 h-24 bg-gradient-to-b from-transparent to-[var(--color-bg)] pointer-events-none" />
    </div>
  );
}
