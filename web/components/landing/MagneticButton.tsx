"use client";

import { useRef, useState, ReactNode } from "react";
import { motion, useMotionValue, useSpring, useTransform } from "framer-motion";
import Link from "next/link";

// Spring-attracted button. Pulled toward the cursor within a radius, released with
// physics when the pointer leaves. Feels like a real object.
export default function MagneticButton({
  href,
  children,
  variant = "primary",
}: {
  href: string;
  children: ReactNode;
  variant?: "primary" | "ghost";
}) {
  const ref = useRef<HTMLAnchorElement>(null);
  const [hover, setHover] = useState(false);

  const x = useMotionValue(0);
  const y = useMotionValue(0);
  const sx = useSpring(x, { stiffness: 150, damping: 15, mass: 0.1 });
  const sy = useSpring(y, { stiffness: 150, damping: 15, mass: 0.1 });
  const rotate = useTransform(sx, [-40, 40], [-2, 2]);

  function onMove(e: React.PointerEvent<HTMLAnchorElement>) {
    const rect = ref.current?.getBoundingClientRect();
    if (!rect) return;
    const cx = rect.left + rect.width / 2;
    const cy = rect.top + rect.height / 2;
    x.set((e.clientX - cx) * 0.35);
    y.set((e.clientY - cy) * 0.35);
  }

  function onLeave() {
    x.set(0); y.set(0); setHover(false);
  }

  const base =
    "relative inline-flex items-center gap-2 h-14 px-7 rounded-2xl font-semibold text-base overflow-hidden";
  const primary = "bg-[var(--color-accent)] text-black";
  const ghost   = "bg-[var(--color-surface)] border border-[var(--color-border-strong)] text-white";

  return (
    <motion.div style={{ x: sx, y: sy, rotate }}>
      <Link
        ref={ref}
        href={href}
        className={`${base} ${variant === "primary" ? primary : ghost}`}
        onPointerMove={onMove}
        onPointerEnter={() => setHover(true)}
        onPointerLeave={onLeave}
      >
        <span className="relative z-10 flex items-center gap-2">{children}</span>
        {/* Shine sweep on hover */}
        {variant === "primary" && hover && (
          <motion.span
            className="absolute inset-0 pointer-events-none"
            style={{
              background:
                "linear-gradient(110deg, transparent 20%, rgba(255,255,255,0.55) 50%, transparent 80%)",
            }}
            initial={{ x: "-120%" }}
            animate={{ x: "120%" }}
            transition={{ duration: 0.8, ease: "easeOut" }}
          />
        )}
      </Link>
    </motion.div>
  );
}
