"use client";

import { useScroll, useTransform, motion } from "framer-motion";
import { useRef, ReactNode } from "react";

// Vertical stack of cards that stick & compress as you scroll past. Each card
// scales/rotates/fades based on its position in the scroll progress range.
// Used for the "How it works" sequence.
export default function StickyStack({
  items,
}: {
  items: { title: string; body: string; accent?: string; kicker?: string }[];
}) {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({ target: ref, offset: ["start start", "end end"] });

  return (
    <section ref={ref} style={{ height: `${items.length * 90}vh` }}>
      <div className="sticky top-0 h-screen flex items-center justify-center px-4">
        <div className="relative w-full max-w-3xl h-[70vh]">
          {items.map((item, i) => (
            <StackCard
              key={i}
              item={item}
              index={i}
              total={items.length}
              progress={scrollYProgress}
            />
          ))}
        </div>
      </div>
    </section>
  );
}

function StackCard({
  item, index, total, progress,
}: {
  item: { title: string; body: string; accent?: string; kicker?: string };
  index: number;
  total: number;
  progress: ReturnType<typeof useScroll>["scrollYProgress"];
}) {
  const start = index / total;
  const end = (index + 1) / total;

  const y = useTransform(progress, [start, end], [0, -80]);
  const scale = useTransform(progress, [start, end], [1, 0.92]);
  const opacity = useTransform(progress, [start, end, Math.min(end + 0.1, 1)], [1, 0.7, 0.2]);
  const rotate = useTransform(progress, [start, end], [0, -2]);

  return (
    <motion.div
      className="absolute inset-0 rim rounded-3xl bg-[var(--color-surface)] border border-[var(--color-border)] p-10 md:p-14 flex flex-col justify-between"
      style={{ y, scale, opacity, rotate, zIndex: total - index }}
    >
      {item.kicker && (
        <span className="font-mono text-[10px] uppercase tracking-[0.2em] text-[var(--color-accent)]">
          {item.kicker}
        </span>
      )}
      <div className="mt-auto">
        <h3
          className="font-display text-4xl md:text-6xl leading-[1.02] tracking-[-0.025em] font-medium"
          style={{ fontFamily: "var(--font-display)" }}
        >
          {item.title}
        </h3>
        <p className="mt-4 text-lg text-[var(--color-text-secondary)] max-w-xl leading-relaxed">
          {item.body}
        </p>
      </div>
    </motion.div>
  );
}
