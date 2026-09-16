"use client";

import { lazy, Suspense, useEffect, useRef, useState } from "react";
import type { ComponentProps } from "react";
import type EventMapComponent from "./EventMap";
import { whenNearViewport } from "@/lib/near-viewport";

const EventMap = lazy(() => import("./EventMap"));

export default function DeferredEventMap(props: ComponentProps<typeof EventMapComponent>) {
  const container = useRef<HTMLDivElement>(null);
  const [visible, setVisible] = useState(false);
  useEffect(() => {
    if (!container.current) return;
    return whenNearViewport(container.current, () => setVisible(true));
  }, []);
  return (
    <div ref={container} className="w-full h-full">
      {visible && <Suspense fallback={<div className="w-full h-full" aria-busy="true" />}><EventMap {...props} /></Suspense>}
    </div>
  );
}
