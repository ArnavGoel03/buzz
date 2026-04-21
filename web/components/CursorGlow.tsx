"use client";

import { useEffect, useRef } from "react";
import { isMobile } from "@/lib/platform";

// Ambient gradient orb that trails the cursor. Only on desktop — mobile users don't
// have a cursor and it's a performance hit to animate it anyway. Uses transform +
// will-change so it doesn't trigger layout reflows.
export default function CursorGlow() {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (isMobile()) return;
    const el = ref.current;
    if (!el) return;
    let raf = 0, targetX = 0, targetY = 0, curX = 0, curY = 0;
    function onMove(e: MouseEvent) {
      targetX = e.clientX; targetY = e.clientY;
    }
    function tick() {
      curX += (targetX - curX) * 0.12;
      curY += (targetY - curY) * 0.12;
      if (el) el.style.transform = `translate3d(${curX - 200}px, ${curY - 200}px, 0)`;
      raf = requestAnimationFrame(tick);
    }
    window.addEventListener("pointermove", onMove);
    raf = requestAnimationFrame(tick);
    return () => {
      window.removeEventListener("pointermove", onMove);
      cancelAnimationFrame(raf);
    };
  }, []);

  return (
    <div
      ref={ref}
      aria-hidden
      className="pointer-events-none fixed top-0 left-0 w-[400px] h-[400px] z-0"
      style={{
        willChange: "transform",
        background:
          "radial-gradient(closest-side, oklch(0.90 0.18 99 / 0.10), transparent 70%)",
        filter: "blur(30px)",
      }}
    />
  );
}
