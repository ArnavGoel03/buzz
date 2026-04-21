"use client";

import { motion } from "framer-motion";
import { ReactNode } from "react";

// Children fade + rise into place with staggered delays. Wrap any grid to make
// its entrance feel intentional instead of instantaneous.
export default function StaggerIn({
  children,
  stagger = 0.05,
  initialDelay = 0,
  className,
}: {
  children: ReactNode;
  stagger?: number;
  initialDelay?: number;
  className?: string;
}) {
  return (
    <motion.div
      className={className}
      initial="hidden"
      animate="visible"
      variants={{
        visible: {
          transition: { staggerChildren: stagger, delayChildren: initialDelay },
        },
      }}
    >
      {children}
    </motion.div>
  );
}

export function StaggerItem({ children, className }: { children: ReactNode; className?: string }) {
  return (
    <motion.div
      className={className}
      variants={{
        hidden: { opacity: 0, y: 16, filter: "blur(8px)" },
        visible: { opacity: 1, y: 0, filter: "blur(0px)", transition: { duration: 0.55, ease: [0.16, 1, 0.3, 1] } },
      }}
    >
      {children}
    </motion.div>
  );
}
