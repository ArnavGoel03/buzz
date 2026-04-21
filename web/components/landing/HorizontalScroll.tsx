"use client";

import { useRef } from "react";
import { motion, useScroll, useTransform } from "framer-motion";
import { ReactNode } from "react";

// Pinned horizontal scroll section. Uses vertical scroll as input, translates the
// inner track horizontally. Apple-product-page style.
export default function HorizontalScroll({
  children,
  heightVh = 300,
}: {
  children: ReactNode;
  heightVh?: number;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({ target: ref, offset: ["start start", "end end"] });
  const x = useTransform(scrollYProgress, [0, 1], ["0%", "-66%"]);

  return (
    <section ref={ref} style={{ height: `${heightVh}vh` }}>
      <div className="sticky top-14 h-[calc(100vh-3.5rem)] overflow-hidden flex items-center">
        <motion.div className="flex gap-5 pl-4 md:pl-8" style={{ x }}>
          {children}
        </motion.div>
      </div>
    </section>
  );
}
