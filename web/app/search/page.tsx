"use client";

import { useState, useMemo, useEffect } from "react";
import Link from "next/link";
import { motion, AnimatePresence } from "framer-motion";
import { Search as SearchIcon, X, ArrowUpRight } from "lucide-react";
import { mockEvents, mockOrgs } from "@/lib/mock-data";
import EventCard from "@/components/EventCard";

export default function Search() {
  const [query, setQuery] = useState("");

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
    if (el) (el as HTMLInputElement).focus();
  }, []);

  return (
    <div className="max-w-3xl mx-auto px-4 md:px-8 py-6">
      <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-[var(--color-text-tertiary)] mb-3">
        § Search
      </p>
      <div className="relative">
        <SearchIcon size={18} className="absolute left-4 top-1/2 -translate-y-1/2 text-[var(--color-text-tertiary)]" />
        <input
          id="buzz-search-input"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Events, clubs, people…"
          className="w-full h-14 pl-11 pr-12 rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border-strong)] text-lg outline-none focus:border-[var(--color-accent)] placeholder:text-[var(--color-text-tertiary)]"
        />
        {query && (
          <button
            onClick={() => setQuery("")}
            aria-label="Clear"
            className="absolute right-4 top-1/2 -translate-y-1/2 text-[var(--color-text-tertiary)] hover:text-white"
          >
            <X size={18} />
          </button>
        )}
      </div>

      {!q && (
        <div className="mt-8">
          <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-[var(--color-text-tertiary)] mb-3">§ Try</p>
          <div className="flex flex-wrap gap-2">
            {["free food", "boba", "acm", "warren quad", "career fair"].map((s) => (
              <button
                key={s}
                onClick={() => setQuery(s)}
                className="px-4 py-2 rounded-full bg-[var(--color-surface)] border border-[var(--color-border)] text-sm hover:border-[var(--color-border-strong)] transition-colors"
              >
                {s}
              </button>
            ))}
          </div>
        </div>
      )}

      <AnimatePresence mode="wait">
        {q && (
          <motion.div
            key={q}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.2 }}
          >
            {events.length > 0 && (
              <Section title="Events" count={events.length}>
                {events.map((e, i) => (
                  <Reveal key={e.id} index={i}>
                    <EventCard event={e} />
                  </Reveal>
                ))}
              </Section>
            )}
            {orgs.length > 0 && (
              <Section title="Clubs" count={orgs.length}>
                {orgs.map((o, i) => (
                  <Reveal key={o.id} index={i}>
                    <Link
                      href={`/o/${o.handle}`}
                      className="group flex items-center gap-3 rim rounded-xl bg-[var(--color-surface)] border border-[var(--color-border)] hover:border-[var(--color-border-strong)] p-4"
                    >
                      <div
                        className="w-10 h-10 rounded-lg flex items-center justify-center font-black text-black"
                        style={{ background: o.accent_hex, fontFamily: "var(--font-display)" }}
                      >
                        {o.name[0]}
                      </div>
                      <div className="min-w-0 flex-1">
                        <p className="font-bold truncate">{o.name}</p>
                        <p className="text-xs text-[var(--color-text-tertiary)] truncate">{o.tagline}</p>
                      </div>
                      <ArrowUpRight size={16} className="text-[var(--color-text-tertiary)] transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5" />
                    </Link>
                  </Reveal>
                ))}
              </Section>
            )}
            {events.length === 0 && orgs.length === 0 && (
              <p className="mt-10 text-center text-sm text-[var(--color-text-tertiary)]">
                Nothing for &ldquo;{query}&rdquo;. Try fewer words.
              </p>
            )}
          </motion.div>
        )}
      </AnimatePresence>

      <div className="h-16 md:h-0" />
    </div>
  );
}

function Section({
  title, count, children,
}: { title: string; count: number; children: React.ReactNode }) {
  return (
    <section className="mt-8">
      <div className="flex items-baseline gap-3 mb-3">
        <h2 className="font-mono text-[10px] uppercase tracking-[0.2em] text-[var(--color-text-tertiary)]">
          § {title}
        </h2>
        <span className="font-mono text-[10px] tabular text-[var(--color-accent)]">{count}</span>
      </div>
      <div className="grid gap-3 md:grid-cols-2">{children}</div>
    </section>
  );
}

function Reveal({ index, children }: { index: number; children: React.ReactNode }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 12, filter: "blur(6px)" }}
      animate={{ opacity: 1, y: 0, filter: "blur(0px)" }}
      transition={{ duration: 0.45, delay: index * 0.04, ease: [0.16, 1, 0.3, 1] }}
    >
      {children}
    </motion.div>
  );
}
