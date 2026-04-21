import { MessageCircle } from "lucide-react";

export const metadata = { title: "Messages" };

export default function Messages() {
  return (
    <div className="max-w-2xl mx-auto px-4 py-16 text-center">
      <div className="w-14 h-14 mx-auto rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)] flex items-center justify-center">
        <MessageCircle size={26} className="text-[var(--color-accent)]" />
      </div>
      <h1
        className="mt-5 text-2xl font-black tracking-tight"
        style={{ fontFamily: "var(--font-display)" }}
      >
        Messages
      </h1>
      <p className="mt-2 text-sm text-[var(--color-text-secondary)]">
        Real-time DMs and club chat ship in Phase 2 — wired to Supabase Realtime.
      </p>
      <p className="mt-6 text-xs text-[var(--color-text-tertiary)]">
        For now: open Buzz on your iPhone to see your chats.
      </p>
    </div>
  );
}
