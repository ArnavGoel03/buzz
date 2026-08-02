"use client";

import { useState } from "react";
import { ArrowRight, Check, Loader2 } from "lucide-react";
import { rejectReason } from "@/lib/academic-domains";

type State =
  | { kind: "idle" }
  | { kind: "sending" }
  | { kind: "queued" }
  | { kind: "live" }
  | { kind: "error"; message: string };

/**
 * Campus waitlist capture. One form, used on /download and anywhere a student hits a
 * campus Buzz has not opened yet.
 *
 * The email is validated client side first so an obvious typo costs a keystroke
 * instead of a round trip, then again on the server, which is the check that counts.
 */
export default function NotifyForm({
  label = "Get Buzz on your campus",
  hint = "Use your .edu address. We email once, when your campus opens.",
  compact = false,
}: {
  label?: string;
  hint?: string;
  compact?: boolean;
}) {
  const [email, setEmail] = useState("");
  const [state, setState] = useState<State>({ kind: "idle" });

  async function submit(e: React.SyntheticEvent) {
    e.preventDefault();
    const local = rejectReason(email.trim());
    if (local) return setState({ kind: "error", message: local });

    setState({ kind: "sending" });
    try {
      const res = await fetch("/api/waitlist", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ email: email.trim() }),
      });
      const data = (await res.json()) as { ok?: boolean; already_live?: boolean; error?: string };

      if (res.status === 429) {
        return setState({ kind: "error", message: "Too many tries. Give it a minute." });
      }
      if (!res.ok || !data.ok) {
        return setState({ kind: "error", message: "That address did not look like a campus email." });
      }
      setState({ kind: data.already_live ? "live" : "queued" });
    } catch {
      setState({ kind: "error", message: "Network hiccup. Try that again." });
    }
  }

  if (state.kind === "queued" || state.kind === "live") {
    return (
      <div className="flex items-start gap-3 p-4 rounded-xl bg-[var(--color-accent-dim)] border border-[var(--color-accent)]/30">
        <Check size={18} className="text-[var(--color-accent)] mt-0.5 shrink-0" strokeWidth={2.6} />
        <p className="text-sm">
          {state.kind === "live" ? (
            <>
              <b>Your campus is already live.</b> Install Buzz and the feed fills in straight away.
            </>
          ) : (
            <>
              <b>You are on the list.</b> Buzz opens campuses in the order they fill up, so a few
              friends signing up moves yours forward.
            </>
          )}
        </p>
      </div>
    );
  }

  const sending = state.kind === "sending";

  return (
    <form onSubmit={submit} className={compact ? "" : "max-w-md"}>
      {!compact && (
        <label htmlFor="notify-email" className="block text-sm font-semibold">
          {label}
        </label>
      )}
      <div className="mt-2 flex gap-2">
        <input
          id="notify-email"
          type="email"
          required
          autoComplete="email"
          inputMode="email"
          placeholder="you@university.edu"
          value={email}
          onChange={(e) => {
            setEmail(e.target.value);
            if (state.kind === "error") setState({ kind: "idle" });
          }}
          aria-invalid={state.kind === "error"}
          aria-describedby="notify-hint"
          className="flex-1 min-w-0 h-11 px-3.5 rounded-xl bg-[var(--color-surface)] border border-[var(--color-border-strong)] text-sm outline-none focus:border-[var(--color-accent)] placeholder:text-[var(--color-text-quaternary)]"
        />
        <button
          type="submit"
          disabled={sending}
          className="h-11 px-4 shrink-0 rounded-xl bg-[var(--color-accent)] text-[var(--color-accent-ink)] font-semibold text-sm inline-flex items-center gap-1.5 disabled:opacity-60"
        >
          {sending ? <Loader2 size={15} className="animate-spin" /> : <ArrowRight size={15} strokeWidth={2.6} />}
          {sending ? "Sending" : "Notify me"}
        </button>
      </div>
      <p
        id="notify-hint"
        className={`mt-2 text-xs ${state.kind === "error" ? "text-[var(--color-live)]" : "text-[var(--color-text-tertiary)]"}`}
        role={state.kind === "error" ? "alert" : undefined}
      >
        {state.kind === "error" ? state.message : hint}
      </p>
    </form>
  );
}
