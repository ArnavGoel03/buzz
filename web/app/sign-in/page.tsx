"use client";

import { useState } from "react";
import { createClient } from "@/lib/supabase-browser";
import { Sparkles } from "lucide-react";
import AppStoreBadges from "@/components/AppStoreBadges";

export default function SignIn() {
  const [email, setEmail] = useState("");
  const [status, setStatus] = useState<"idle" | "sending" | "sent" | "error">("idle");
  const [error, setError] = useState("");

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setStatus("sending");
    setError("");
    try {
      const supabase = createClient();
      const { error } = await supabase.auth.signInWithOtp({
        email,
        options: { emailRedirectTo: `${window.location.origin}/auth/callback` },
      });
      if (error) throw error;
      setStatus("sent");
    } catch (err) {
      setStatus("error");
      setError(err instanceof Error ? err.message : "Something went wrong");
    }
  }

  return (
    <div className="max-w-md mx-auto px-6 pt-12 pb-16 text-center">
      <div className="w-14 h-14 mx-auto rounded-2xl bg-[var(--color-accent)] flex items-center justify-center">
        <Sparkles size={26} className="text-black" strokeWidth={2.5} />
      </div>
      <h1
        className="mt-5 text-3xl font-black tracking-tight"
        style={{ fontFamily: "var(--font-display)" }}
      >
        Sign in to Buzz
      </h1>
      <p className="mt-2 text-sm text-[var(--color-text-secondary)]">
        Use your .edu email. We&apos;ll send a magic link — no password.
      </p>

      {status === "sent" ? (
        <div className="mt-8 p-5 rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)]">
          <p className="text-base font-bold">Check your email</p>
          <p className="mt-1 text-sm text-[var(--color-text-secondary)]">
            We sent a sign-in link to <span className="font-semibold">{email}</span>. Open it on this device.
          </p>
        </div>
      ) : (
        <form onSubmit={handleSubmit} className="mt-8 space-y-3">
          <input
            type="email"
            required
            autoComplete="email"
            inputMode="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="your@school.edu"
            className="w-full h-12 px-4 rounded-xl bg-[var(--color-surface)] border border-[var(--color-border-strong)] text-base outline-none focus:border-[var(--color-accent)]"
          />
          <button
            type="submit"
            disabled={status === "sending"}
            className="w-full h-12 rounded-xl bg-[var(--color-accent)] text-black font-bold text-base disabled:opacity-60"
          >
            {status === "sending" ? "Sending…" : "Email me a link"}
          </button>
          {error && <p className="text-sm text-[var(--color-live)]">{error}</p>}
        </form>
      )}

      <div className="mt-10 pt-8 border-t border-[var(--color-border)]">
        <p className="text-xs font-bold uppercase tracking-wider text-[var(--color-text-tertiary)] mb-3">
          Or skip the web
        </p>
        <p className="text-sm text-[var(--color-text-secondary)] mb-4">
          The Buzz app signs you in with Apple in one tap. Push, chat, check-in — all native.
        </p>
        <AppStoreBadges layout="stack" />
      </div>

      <p className="mt-8 text-xs text-[var(--color-text-tertiary)]">
        By continuing you agree to the{" "}
        <a href="/legal/terms" className="underline">Terms</a> and{" "}
        <a href="/legal/privacy" className="underline">Privacy Policy</a>.
      </p>
    </div>
  );
}
