"use client";

import { useRef, ReactNode } from "react";
import { motion, useMotionValue, useSpring, useTransform } from "framer-motion";

// 3D-tilt card with a cursor-following spotlight. Tracks pointer within the card
// and rotates around X/Y axes, plus a radial gradient overlay that follows the
// mouse position for a "rim-lit" glow that reacts to cursor.
export default function TiltCard({
  children,
  className,
  intensity = 8,
}: {
  children: ReactNode;
  className?: string;
  intensity?: number;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const mx = useMotionValue(0.5);
  const my = useMotionValue(0.5);
  const rotateX = useSpring(useTransform(my, [0, 1], [intensity, -intensity]), { stiffness: 220, damping: 20 });
  const rotateY = useSpring(useTransform(mx, [0, 1], [-intensity, intensity]), { stiffness: 220, damping: 20 });

  const spotlight = useTransform(
    [mx, my],
    ([x, y]) =>
      `radial-gradient(600px circle at ${Number(x) * 100}% ${Number(y) * 100}%, rgba(255, 214, 10, 0.12), transparent 40%)`
  );

  function onMove(e: React.PointerEvent<HTMLDivElement>) {
    const rect = ref.current?.getBoundingClientRect();
    if (!rect) return;
    mx.set((e.clientX - rect.left) / rect.width);
    my.set((e.clientY - rect.top) / rect.height);
  }

  function onLeave() { mx.set(0.5); my.set(0.5); }

  return (
    <motion.div
      ref={ref}
      onPointerMove={onMove}
      onPointerLeave={onLeave}
      style={{ rotateX, rotateY, transformPerspective: 1200 }}
      className={`relative transform-gpu ${className ?? ""}`}
    >
      {children}
      <motion.div
        aria-hidden
        className="absolute inset-0 rounded-[inherit] pointer-events-none"
        style={{ background: spotlight }}
      />
    </motion.div>
  );
}
