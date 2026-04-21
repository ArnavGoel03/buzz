"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { Search, Compass, Map as MapIcon, Users, MessageCircle, Settings, User, Sparkles } from "lucide-react";
import { mockEvents, mockOrgs } from "@/lib/mock-data";

type Item = {
  id: string;
  label: string;
  sub?: string;
  href: string;
  section: "Navigate" | "Events" | "Clubs";
  icon?: React.ReactNode;
};

// Raycast-style global palette. Triggered by ⌘K / ⌃K anywhere. Search navigates
// primary pages + matches events and clubs. The one UI element that says "real
// product" in a single keystroke.
export default function CommandPalette() {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [q, setQ] = useState("");
  const [active, setActive] = useState(0);

  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === "k") {
        e.preventDefault();
        setOpen((o) => !o);
      }
      if (e.key === "Escape") setOpen(false);
    }
    function onClick(e: MouseEvent) {
      const t = e.target as HTMLElement | null;
      if (t?.closest?.("[data-cmdk]")) setOpen(true);
    }
    window.addEventListener("keydown", onKey);
    window.addEventListener("click", onClick);
    return () => {
      window.removeEventListener("keydown", onKey);
      window.removeEventListener("click", onClick);
    };
  }, []);

  useEffect(() => { setActive(0); }, [q, open]);

  const items: Item[] = useMemo(() => {
    const nav: Item[] = [
      { id: "nav-feed",     label: "Feed",     href: "/",         section: "Navigate", icon: <Compass size={14} /> },
      { id: "nav-map",      label: "Live map", href: "/map",      section: "Navigate", icon: <MapIcon size={14} /> },
      { id: "nav-clubs",    label: "Clubs",    href: "/clubs",    section: "Navigate", icon: <Users size={14} /> },
      { id: "nav-messages", label: "Messages", href: "/messages", section: "Navigate", icon: <MessageCircle size={14} /> },
      { id: "nav-profile",  label: "Profile",  href: "/profile",  section: "Navigate", icon: <User size={14} /> },
      { id: "nav-settings", label: "Settings", href: "/settings", section: "Navigate", icon: <Settings size={14} /> },
    ];
    const eventItems: Item[] = mockEvents.map((e) => ({
      id: `e-${e.id}`, label: e.title, sub: e.location_name,
      href: `/e/${e.id}`, section: "Events",
    }));
    const orgItems: Item[] = mockOrgs.map((o) => ({
      id: `o-${o.id}`, label: o.name, sub: o.tagline,
      href: `/o/${o.handle}`, section: "Clubs",
    }));
    const all = [...nav, ...eventItems, ...orgItems];
    if (!q) return all;
    const t = q.toLowerCase();
    return all.filter((i) =>
      i.label.toLowerCase().includes(t) || (i.sub ?? "").toLowerCase().includes(t)
    );
  }, [q]);

  const grouped = useMemo(() => {
    const g: Record<string, Item[]> = {};
    for (const i of items) (g[i.section] ??= []).push(i);
    return g;
  }, [items]);

  function go(item: Item) {
    setOpen(false);
    setQ("");
    router.push(item.href);
  }

  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if (!open) return;
      if (e.key === "ArrowDown") { e.preventDefault(); setActive((a) => Math.min(a + 1, items.length - 1)); }
      if (e.key === "ArrowUp")   { e.preventDefault(); setActive((a) => Math.max(a - 1, 0)); }
      if (e.key === "Enter")     { e.preventDefault(); const picked = items[active]; if (picked) go(picked); }
    }
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [open, items, active]);

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-[100] flex items-start justify-center pt-[12vh] px-4">
      <button
        aria-label="Close"
        onClick={() => setOpen(false)}
        className="absolute inset-0 bg-black/70 backdrop-blur-sm"
      />
      <div className="relative w-full max-w-xl rim rounded-2xl bg-[var(--color-bg-elevated)] border border-[var(--color-border-strong)] shadow-2xl overflow-hidden">
        <div className="flex items-center gap-3 px-4 h-12 border-b border-[var(--color-border)]">
          <Search size={16} className="text-[var(--color-text-tertiary)]" />
          <input
            autoFocus
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Search events, clubs, navigate…"
            className="flex-1 bg-transparent outline-none text-sm"
          />
          <kbd className="font-mono text-[10px] text-[var(--color-text-tertiary)] px-1.5 py-0.5 rounded border border-[var(--color-border)]">esc</kbd>
        </div>
        <div className="max-h-[55vh] overflow-y-auto scrollbar-thin">
          {items.length === 0 ? (
            <p className="text-sm text-[var(--color-text-tertiary)] p-6 text-center">No matches.</p>
          ) : (
            Object.entries(grouped).map(([section, rows]) => (
              <div key={section} className="py-1.5">
                <div className="px-4 py-1.5 font-mono text-[10px] uppercase tracking-wider text-[var(--color-text-tertiary)]">
                  {section}
                </div>
                <ul>
                  {rows.map((row) => {
                    const idx = items.indexOf(row);
                    const isActive = idx === active;
                    return (
                      <li key={row.id}>
                        <button
                          onMouseEnter={() => setActive(idx)}
                          onClick={() => go(row)}
                          className={`w-full flex items-center gap-3 px-4 h-10 text-left text-sm ${
                            isActive
                              ? "bg-[var(--color-accent-dim)] text-white"
                              : "hover:bg-[var(--color-surface)]"
                          }`}
                        >
                          <span className="text-[var(--color-text-tertiary)]">{row.icon ?? <Sparkles size={14} />}</span>
                          <span className="font-medium">{row.label}</span>
                          {row.sub && (
                            <span className="text-[var(--color-text-tertiary)] truncate">{row.sub}</span>
                          )}
                        </button>
                      </li>
                    );
                  })}
                </ul>
              </div>
            ))
          )}
        </div>
        <div className="border-t border-[var(--color-border)] h-9 px-3 flex items-center justify-between text-[10px] font-mono text-[var(--color-text-tertiary)]">
          <span>
            <kbd>↑↓</kbd> nav <kbd className="ml-2">↵</kbd> select
          </span>
          <span>⌘K to toggle</span>
        </div>
      </div>
    </div>
  );
}
