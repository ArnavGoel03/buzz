"use client";

import { useState, useRef } from "react";
import { Check, Plus } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";
import { createClient } from "@/lib/supabase-browser";

// Client-side RSVP with particle burst on success. Tactile — the button pulses,
// 12 accent-colored particles radiate outward, and a checkmark slides in. Feels
// like committing to something real.
export default function RSVPButton({ eventId }: { eventId: string }) {
  const [going, setGoing] = useState(false);
  const [loading, setLoading] = useState(false);
  const [bursting, setBursting] = useState(false);
  const burstId = useRef(0);

  async function toggle() {
    if (loading) return;
    setLoading(true);
    const next = !going;
    if (next) {
      setBursting(true);
      burstId.current += 1;
      setTimeout(() => setBursting(false), 800);
    }
    setGoing(next);
    try {
      const supabase = createClient();
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        const key = "buzz:rsvp:pending";
        const pending = JSON.parse(localStorage.getItem(key) || "[]");
        localStorage.setItem(key, JSON.stringify([...new Set([...pending, eventId])]));
      } else if (next) {
        await supabase.from("rsvps").upsert({ event_id: eventId, user_id: user.id, status: "going" });
      } else {
        await supabase.from("rsvps").delete().match({ event_id: eventId, user_id: user.id });
      }
    } catch {
      setGoing(!next);
    } finally {
      setLoading(false);
    }
  }

  return (
    <motion.button
      onClick={toggle}
      disabled={loading}
      whileTap={{ scale: 0.96 }}
      className={`relative h-12 flex items-center justify-center gap-2 rounded-xl font-bold text-base overflow-visible transition-colors ${
        going
          ? "bg-[var(--color-surface)] border border-[var(--color-accent)] text-[var(--color-accent)]"
          : "bg-[var(--color-accent)] text-black hover:brightness-110"
      }`}
    >
      <AnimatePresence mode="wait">
        {going ? (
          <motion.span
            key="going"
            className="flex items-center gap-2"
            initial={{ opacity: 0, y: 6 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -6 }}
            transition={{ duration: 0.2 }}
          >
            <Check size={18} /> You&apos;re in
          </motion.span>
        ) : (
          <motion.span
            key="idle"
            className="flex items-center gap-2"
            initial={{ opacity: 0, y: 6 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -6 }}
            transition={{ duration: 0.2 }}
          >
            <Plus size={18} /> RSVP — I&apos;m in
          </motion.span>
        )}
      </AnimatePresence>

      {bursting && <ParticleBurst key={burstId.current} />}
    </motion.button>
  );
}

// 12 particles radiating outward, fading + scaling down. Pure transform animation
// — no CPU cost beyond initial mount.
function ParticleBurst() {
  const particles = Array.from({ length: 12 });
  return (
    <span className="absolute inset-0 pointer-events-none">
      {particles.map((_, i) => {
        const angle = (i / particles.length) * Math.PI * 2;
        const dx = Math.cos(angle) * 80;
        const dy = Math.sin(angle) * 80;
        return (
          <motion.span
            key={i}
            className="absolute left-1/2 top-1/2 w-1.5 h-1.5 rounded-full bg-[var(--color-accent)]"
            initial={{ x: -3, y: -3, opacity: 1, scale: 1 }}
            animate={{ x: dx - 3, y: dy - 3, opacity: 0, scale: 0.4 }}
            transition={{ duration: 0.65, ease: "easeOut" }}
          />
        );
      })}
    </span>
  );
}
