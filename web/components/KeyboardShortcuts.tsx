"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import { X } from "lucide-react";

// Global keyboard router + shortcut overlay. Matches GitHub / Linear / Raycast
// conventions: `g` then a single key = go to section; `/` focuses search; `?`
// opens help. Respects inputs — no hijacking when the user is typing.

type Shortcut = { combo: string[]; label: string };
const SECTIONS: { title: string; items: Shortcut[] }[] = [
  {
    title: "Navigate",
    items: [
      { combo: ["g", "f"], label: "Go to feed" },
      { combo: ["g", "m"], label: "Go to map" },
      { combo: ["g", "c"], label: "Go to clubs" },
      { combo: ["g", "p"], label: "Go to profile" },
      { combo: ["g", "s"], label: "Go to settings" },
      { combo: ["g", "h"], label: "Go home" },
    ],
  },
  {
    title: "Actions",
    items: [
      { combo: ["⌘", "K"], label: "Command palette" },
      { combo: ["/"], label: "Focus search" },
      { combo: ["?"], label: "This overlay" },
    ],
  },
  {
    title: "View",
    items: [
      { combo: ["esc"], label: "Close modal / overlay" },
    ],
  },
];

export default function KeyboardShortcuts() {
  const router = useRouter();
  const [helpOpen, setHelpOpen] = useState(false);

  useEffect(() => {
    let prefix = false;
    let prefixTimer: number | null = null;

    function reset() {
      prefix = false;
      if (prefixTimer != null) { clearTimeout(prefixTimer); prefixTimer = null; }
    }

    function isTyping(e: KeyboardEvent) {
      const t = e.target as HTMLElement | null;
      if (!t) return false;
      const tag = t.tagName;
      return tag === "INPUT" || tag === "TEXTAREA" || t.isContentEditable;
    }

    function onKey(e: KeyboardEvent) {
      if (e.metaKey || e.ctrlKey || e.altKey) return;
      if (isTyping(e)) return;
      const k = e.key.toLowerCase();

      if (k === "escape") { setHelpOpen(false); reset(); return; }
      if (k === "?") { e.preventDefault(); setHelpOpen((o) => !o); return; }
      if (k === "/") { e.preventDefault(); router.push("/search"); return; }

      if (prefix) {
        reset();
        switch (k) {
          case "f": router.push("/feed"); return;
          case "m": router.push("/map"); return;
          case "c": router.push("/clubs"); return;
          case "p": router.push("/profile"); return;
          case "s": router.push("/settings"); return;
          case "h": router.push("/"); return;
        }
      }

      if (k === "g") {
        prefix = true;
        prefixTimer = window.setTimeout(reset, 1500);
      }
    }

    window.addEventListener("keydown", onKey);
    return () => {
      window.removeEventListener("keydown", onKey);
      reset();
    };
  }, [router]);

  return (
    <AnimatePresence>
      {helpOpen && (
        <motion.div
          className="fixed inset-0 z-[120] flex items-center justify-center px-4"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.15 }}
        >
          <button
            aria-label="Close"
            className="absolute inset-0 bg-black/70 backdrop-blur-md"
            onClick={() => setHelpOpen(false)}
          />
          <motion.div
            initial={{ opacity: 0, y: 20, filter: "blur(10px)" }}
            animate={{ opacity: 1, y: 0, filter: "blur(0px)" }}
            exit={{ opacity: 0, y: 20, filter: "blur(10px)" }}
            transition={{ duration: 0.3, ease: [0.16, 1, 0.3, 1] }}
            className="relative w-full max-w-xl rim rounded-2xl bg-[var(--color-bg-elevated)] border border-[var(--color-border-strong)] overflow-hidden"
          >
            <div className="flex items-center justify-between p-5 border-b border-[var(--color-border)]">
              <div>
                <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-[var(--color-text-tertiary)]">
                  § Keyboard shortcuts
                </p>
                <h2
                  className="font-display text-2xl font-medium tracking-[-0.02em] mt-1"
                  style={{ fontFamily: "var(--font-display)" }}
                >
                  Fly around Buzz.
                </h2>
              </div>
              <button
                onClick={() => setHelpOpen(false)}
                className="w-9 h-9 rounded-lg flex items-center justify-center hover:bg-[var(--color-surface)]"
                aria-label="Close"
              >
                <X size={16} />
              </button>
            </div>
            <div className="p-5 space-y-5 max-h-[60vh] overflow-y-auto scrollbar-thin">
              {SECTIONS.map((section) => (
                <div key={section.title}>
                  <p className="font-mono text-[10px] uppercase tracking-[0.18em] text-[var(--color-text-tertiary)] mb-2">
                    § {section.title}
                  </p>
                  <ul className="divide-y divide-[var(--color-border)] rounded-xl border border-[var(--color-border)] overflow-hidden">
                    {section.items.map((item, i) => (
                      <li key={i} className="flex items-center justify-between px-4 py-2.5 text-sm">
                        <span className="text-[var(--color-text-secondary)]">{item.label}</span>
                        <span className="flex items-center gap-1.5">
                          {item.combo.map((k, idx) => (
                            <kbd
                              key={idx}
                              className="font-mono text-[11px] px-2 py-0.5 rounded border border-[var(--color-border)] text-white bg-[var(--color-surface)]"
                            >
                              {k}
                            </kbd>
                          ))}
                        </span>
                      </li>
                    ))}
                  </ul>
                </div>
              ))}
            </div>
            <div className="border-t border-[var(--color-border)] px-5 py-3 font-mono text-[10px] text-[var(--color-text-tertiary)]">
              press <kbd className="px-1.5 py-0.5 rounded border border-[var(--color-border)]">esc</kbd> or click outside to dismiss
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
