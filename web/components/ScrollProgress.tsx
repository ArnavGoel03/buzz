"use client";

import { motion, useScroll, useSpring } from "framer-motion";

// Thin accent-colored progress bar pinned at the very top of the viewport.
// Use sparingly — makes long reading pages feel premium (event detail, org
// detail, profile). Width 0→1 driven by window scroll progress.
export default function ScrollProgress() {
  const { scrollYProgress } = useScroll();
  const scale = useSpring(scrollYProgress, { stiffness: 200, damping: 30, restDelta: 0.001 });

  return (
    <motion.div
      aria-hidden
      className="fixed top-0 left-0 right-0 h-[2px] z-[110] origin-left"
      style={{
        scaleX: scale,
        background:
          "linear-gradient(90deg, transparent, var(--color-accent) 20%, var(--color-accent) 80%, transparent)",
      }}
    />
  );
}
