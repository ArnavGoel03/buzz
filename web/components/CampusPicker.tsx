"use client";

import { useEffect, useRef, useState } from "react";
import { ChevronDown, MapPin, X } from "lucide-react";
import NotifyForm from "./NotifyForm";

/**
 * The campus badge used to be a chevron that did nothing, which is worse than no
 * chevron at all. One campus is live, so the honest version of a campus switcher is a
 * panel that says exactly that and takes the address of whoever wants theirs next.
 *
 * That waitlist is also the only signal deciding which campus opens after this one.
 */
export default function CampusPicker({ name }: { name: string }) {
  const [open, setOpen] = useState(false);
  const wrap = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!open) return;
    function onDown(e: MouseEvent) {
      if (!wrap.current?.contains(e.target as Node)) setOpen(false);
    }
    function onKey(e: KeyboardEvent) {
      if (e.key === "Escape") setOpen(false);
    }
    document.addEventListener("mousedown", onDown);
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("mousedown", onDown);
      document.removeEventListener("keydown", onKey);
    };
  }, [open]);

  return (
    <div className="relative" ref={wrap}>
      <button
        onClick={() => setOpen((v) => !v)}
        aria-expanded={open}
        aria-haspopup="dialog"
        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-[var(--color-surface)] border border-[var(--color-border)] text-sm font-semibold hover:border-[var(--color-border-strong)]"
      >
        <MapPin size={14} className="text-[var(--color-accent)]" />
        {name}
        <ChevronDown
          size={14}
          className={`text-[var(--color-text-tertiary)] transition-transform ${open ? "rotate-180" : ""}`}
        />
      </button>

      {open && (
        <div
          role="dialog"
          aria-label="Campus"
          className="absolute z-40 mt-2 left-0 w-[min(22rem,calc(100vw-2rem))] p-4 rounded-2xl rim bg-[var(--color-bg-elevated)] border border-[var(--color-border-strong)] shadow-2xl"
        >
          <div className="flex items-start justify-between gap-3">
            <p className="text-sm font-bold">{name} is the only campus live.</p>
            <button
              onClick={() => setOpen(false)}
              aria-label="Close"
              className="shrink-0 text-[var(--color-text-tertiary)] hover:text-[var(--color-text)]"
            >
              <X size={15} />
            </button>
          </div>
          <p className="mt-1.5 text-xs text-[var(--color-text-tertiary)]">
            Campuses open in the order they fill up. Drop your school email and yours
            moves up the queue.
          </p>
          <div className="mt-3">
            <NotifyForm compact hint="School email. One message, when yours opens." />
          </div>
        </div>
      )}
    </div>
  );
}
