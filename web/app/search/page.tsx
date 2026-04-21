"use client";

import { useState, useMemo, useEffect } from "react";
import Link from "next/link";
import { Search as SearchIcon, X } from "lucide-react";
import { mockEvents, mockOrgs } from "@/lib/mock-data";
import EventCard from "@/components/EventCard";

export default function Search() {
  const [query, setQuery] = useState("");
  const [active, setActive] = useState(true);

  const q = query.trim().toLowerCase();
  const events = useMemo(() => {
    if (!q) return [];
    return mockEvents.filter(
      (e) =>
        e.title.toLowerCase().includes(q) ||
        e.summary.toLowerCase().includes(q) ||
        e.tags?.some((t) => t.toLowerCase().includes(q))
    );
  }, [q]);

  const orgs = useMemo(() => {
    if (!q) return [];
    return mockOrgs.filter(
      (o) => o.name.toLowerCase().includes(q) || o.handle.toLowerCase().includes(q)
    );
  }, [q]);

  useEffect(() => {
    const el = document.getElementById("buzz-search-input");
    if (active && el) (el as HTMLInputElement).focus();
  }, [active]);

  return (
    <div className="max-w-3xl mx-auto px-4 md:px-8 py-6">
      <div className="flex items-center gap-2 h-12 px-4 rounded-xl bg-[var(--color-surface)] border border-[var(--color-border-strong)]">
        <SearchIcon size={18} className="text-[var(--color-text-tertiary)]" />
        <input
          id="buzz-search-input"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onFocus={() => setActive(true)}
          placeholder="Events, clubs, people…"
          className="flex-1 bg-transparent outline-none text-base"
        />
        {query && (
          <button onClick={() => setQuery("")} aria-label="Clear">
            <X size={16} className="text-[var(--color-text-tertiary)]" />
          </button>
        )}
      </div>

      {!q && (
        <div className="mt-8">
          <h2 className="text-sm font-bold uppercase tracking-wider text-[var(--color-text-tertiary)] mb-3">Try</h2>
          <div className="flex flex-wrap gap-2">
            {["free food", "boba", "acm", "warren quad", "career fair"].map((s) => (
              <button
                key={s}
                onClick={() => setQuery(s)}
                className="px-3 py-1.5 rounded-full bg-[var(--color-surface)] border border-[var(--color-border)] text-sm"
              >
                {s}
              </button>
            ))}
          </div>
        </div>
      )}

      {events.length > 0 && (
        <section className="mt-8">
          <h2 className="text-sm font-bold uppercase tracking-wider text-[var(--color-text-tertiary)] mb-3">
            Events · {events.length}
          </h2>
          <div className="grid gap-3 md:grid-cols-2">
            {events.map((e) => (
              <EventCard key={e.id} event={e} />
            ))}
          </div>
        </section>
      )}

      {orgs.length > 0 && (
        <section className="mt-8">
          <h2 className="text-sm font-bold uppercase tracking-wider text-[var(--color-text-tertiary)] mb-3">
            Clubs · {orgs.length}
          </h2>
          <div className="grid gap-3 md:grid-cols-2">
            {orgs.map((o) => (
              <Link
                key={o.id}
                href={`/o/${o.handle}`}
                className="rounded-xl bg-[var(--color-surface)] border border-[var(--color-border)] p-4 flex items-center gap-3"
              >
                <div
                  className="w-10 h-10 rounded-lg flex items-center justify-center font-black text-black"
                  style={{ background: o.accent_hex, fontFamily: "var(--font-display)" }}
                >
                  {o.name[0]}
                </div>
                <div className="min-w-0">
                  <p className="font-bold truncate">{o.name}</p>
                  <p className="text-xs text-[var(--color-text-tertiary)] truncate">{o.tagline}</p>
                </div>
              </Link>
            ))}
          </div>
        </section>
      )}

      {q && events.length === 0 && orgs.length === 0 && (
        <p className="mt-10 text-center text-sm text-[var(--color-text-tertiary)]">
          Nothing found for &ldquo;{query}&rdquo;. Try fewer words.
        </p>
      )}
      <div className="h-16 md:h-0" />
    </div>
  );
}
