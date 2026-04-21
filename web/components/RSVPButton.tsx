"use client";

import { useState } from "react";
import { Check, Plus } from "lucide-react";
import { createClient } from "@/lib/supabase-browser";

// Client-side RSVP. Optimistic UI — flips immediately, writes to Supabase in the
// background. Falls back to localStorage when unauthenticated so guests can still
// mark intent and get prompted to sign in on next visit.
export default function RSVPButton({ eventId }: { eventId: string }) {
  const [going, setGoing] = useState(false);
  const [loading, setLoading] = useState(false);

  async function toggle() {
    setLoading(true);
    const next = !going;
    setGoing(next);
    try {
      const supabase = createClient();
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) {
        // Stash intent locally; push to server after sign-in.
        const key = "buzz:rsvp:pending";
        const pending = JSON.parse(localStorage.getItem(key) || "[]");
        localStorage.setItem(key, JSON.stringify([...new Set([...pending, eventId])]));
      } else {
        if (next) {
          await supabase.from("rsvps").upsert({ event_id: eventId, user_id: user.id, status: "going" });
        } else {
          await supabase.from("rsvps").delete().match({ event_id: eventId, user_id: user.id });
        }
      }
    } catch {
      // Revert on failure — don't block the UI.
      setGoing(!next);
    } finally {
      setLoading(false);
    }
  }

  return (
    <button
      onClick={toggle}
      disabled={loading}
      className={`h-12 flex items-center justify-center gap-2 rounded-xl font-bold text-base transition-colors ${
        going
          ? "bg-[var(--color-surface)] border border-[var(--color-accent)] text-[var(--color-accent)]"
          : "bg-[var(--color-accent)] text-black hover:brightness-110"
      }`}
    >
      {going ? <Check size={18} /> : <Plus size={18} />}
      {going ? "Going" : "RSVP — I'm in"}
    </button>
  );
}
