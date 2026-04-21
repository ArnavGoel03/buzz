"use client";

import { motion } from "framer-motion";
import { ReactNode } from "react";

// Infinite horizontal marquee — duplicates children so the scroll loops seamlessly.
// Pauses on hover so users can actually read items. Used for campus logos +
// testimonial snippets.
export default function Marquee({
  children,
  speed = 40,
  reverse = false,
  gap = 48,
}: {
  children: ReactNode;
  speed?: number;
  reverse?: boolean;
  gap?: number;
}) {
  return (
    <div className="relative overflow-hidden group">
      <div className="absolute left-0 top-0 bottom-0 w-24 z-10 bg-gradient-to-r from-[var(--color-bg)] to-transparent pointer-events-none" />
      <div className="absolute right-0 top-0 bottom-0 w-24 z-10 bg-gradient-to-l from-[var(--color-bg)] to-transparent pointer-events-none" />
      <motion.div
        className="flex shrink-0 group-hover:[animation-play-state:paused]"
        style={{ gap }}
        initial={{ x: 0 }}
        animate={{ x: reverse ? "50%" : "-50%" }}
        transition={{ duration: speed, ease: "linear", repeat: Infinity }}
      >
        <div className="flex shrink-0 items-center" style={{ gap }}>{children}</div>
        <div className="flex shrink-0 items-center" style={{ gap }} aria-hidden>{children}</div>
      </motion.div>
    </div>
  );
}
