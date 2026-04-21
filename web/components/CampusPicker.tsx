"use client";

import { ChevronDown, MapPin } from "lucide-react";

// For now: shows the active campus as a badge. Wired to real campus switcher in
// Phase 2 when multi-campus profiles ship.
export default function CampusPicker({ name }: { name: string }) {
  return (
    <button className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-[var(--color-surface)] border border-[var(--color-border)] text-sm font-semibold hover:border-[var(--color-border-strong)]">
      <MapPin size={14} className="text-[var(--color-accent)]" />
      {name}
      <ChevronDown size={14} className="text-[var(--color-text-tertiary)]" />
    </button>
  );
}
