"use client";

import { useEffect, useRef, useState } from "react";
import { isMobile } from "@/lib/platform";

// Replaces the native cursor with a blend-mode orb. Detects interactive elements
// (a, button) and expands + brightens on hover. Desktop only.
export default function CustomCursor() {
  const ring = useRef<HTMLDivElement>(null);
  const dot  = useRef<HTMLDivElement>(null);
  const [enabled, setEnabled] = useState(false);

  useEffect(() => {
    if (isMobile()) return;
    setEnabled(true);
    document.body.style.cursor = "none";

    let rx = 0, ry = 0, dx = 0, dy = 0;
    let tx = 0, ty = 0;
    let overInteractive = false;

    function onMove(e: MouseEvent) {
      tx = e.clientX; ty = e.clientY;
      const el = e.target as HTMLElement | null;
      overInteractive = !!el?.closest?.("a, button, [data-cursor='pointer']");
    }

    function frame() {
      rx += (tx - rx) * 0.22;
      ry += (ty - ry) * 0.22;
      dx += (tx - dx) * 0.5;
      dy += (ty - dy) * 0.5;
      if (ring.current) {
        const scale = overInteractive ? 2.5 : 1;
        ring.current.style.transform = `translate3d(${rx - 18}px, ${ry - 18}px, 0) scale(${scale})`;
        ring.current.style.opacity = overInteractive ? "0.85" : "0.45";
      }
      if (dot.current) dot.current.style.transform = `translate3d(${dx - 2}px, ${dy - 2}px, 0)`;
      requestAnimationFrame(frame);
    }
    window.addEventListener("pointermove", onMove);
    const raf = requestAnimationFrame(frame);
    return () => {
      document.body.style.cursor = "";
      window.removeEventListener("pointermove", onMove);
      cancelAnimationFrame(raf);
    };
  }, []);

  if (!enabled) return null;
  return (
    <>
      <div
        ref={ring}
        aria-hidden
        className="fixed top-0 left-0 w-9 h-9 rounded-full pointer-events-none z-[200] mix-blend-difference border border-white"
        style={{ willChange: "transform", transition: "opacity 0.2s" }}
      />
      <div
        ref={dot}
        aria-hidden
        className="fixed top-0 left-0 w-1 h-1 rounded-full bg-white pointer-events-none z-[200] mix-blend-difference"
        style={{ willChange: "transform" }}
      />
    </>
  );
}
