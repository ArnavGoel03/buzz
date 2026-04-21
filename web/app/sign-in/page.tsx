"use client";

import { useState, useMemo } from "react";
import Link from "next/link";
import { createClient } from "@/lib/supabase-browser";
import { Sparkles, GraduationCap, ShieldCheck, ArrowRight } from "lucide-react";
import AppStoreBadges from "@/components/AppStoreBadges";
import { isAcademicEmail, resolveCampus, rejectReason } from "@/lib/campus-domains";

type Status = "idle" | "sending" | "sent" | "error" | "waitlist";

export default function SignIn() {
  const [email, setEmail] = useState("");
  const [status, setStatus] = useState<Status>("idle");
  const [error, setError] = useState("");

  const campus = useMemo(() => {
    if (!isAcademicEmail(email)) return null;
    return resolveCampus(email);
  }, [email]);

  const clientError = useMemo(() => rejectReason(email), [email]);
  const canSubmit = email.length > 0 && isAcademicEmail(email) && status !== "sending";

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!canSubmit) return;

    setStatus("sending");
    setError("");
    try {
      const supabase = createClient();
      const { error } = await supabase.auth.signInWithOtp({
        email,
        options: {
          emailRedirectTo: `${window.location.origin}/auth/callback`,
          data: { campus_id: campus?.campusId },
        },
      });
      if (error) throw error;
      setStatus("sent");
    } catch (err) {
      setStatus("error");
      setError(err instanceof Error ? err.message : "Something went wrong");
    }
  }

  return (
    <div className="max-w-md mx-auto px-6 pt-12 pb-16">
      <div className="text-center">
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
          Use your school email. We verify you as a real student automatically.
        </p>
      </div>

      {status === "sent" ? (
        <SuccessState email={email} campusName={campus?.campusName ?? "your campus"} />
      ) : (
        <form onSubmit={handleSubmit} className="mt-8 space-y-3">
          <div className="relative">
            <GraduationCap
              size={18}
              className="absolute left-4 top-1/2 -translate-y-1/2 text-[var(--color-text-tertiary)]"
            />
            <input
              type="email"
              required
              autoComplete="email"
              inputMode="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="your@school.edu"
              className="w-full h-12 pl-11 pr-4 rounded-xl bg-[var(--color-surface)] border border-[var(--color-border-strong)] text-base outline-none focus:border-[var(--color-accent)]"
            />
          </div>

          {campus && (
            <div className="flex items-center gap-2 text-xs text-[var(--color-accent)] px-1">
              <ShieldCheck size={14} />
              <span className="font-semibold">
                Verified as {campus.campusName} student · {campus.country}
              </span>
            </div>
          )}
          {clientError && email.length > 4 && (
            <p className="text-xs text-[var(--color-text-tertiary)] px-1">{clientError}</p>
          )}

          <button
            type="submit"
            disabled={!canSubmit}
            className="w-full h-12 flex items-center justify-center gap-2 rounded-xl bg-[var(--color-accent)] text-black font-bold text-base disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {status === "sending" ? "Sending…" : "Email me a link"}
            {status !== "sending" && <ArrowRight size={16} />}
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

      <p className="mt-8 text-center text-xs text-[var(--color-text-tertiary)]">
        By continuing you agree to the{" "}
        <Link href="/legal/terms" className="underline">Terms</Link> and{" "}
        <Link href="/legal/privacy" className="underline">Privacy</Link>.
      </p>
    </div>
  );
}

function SuccessState({ email, campusName }: { email: string; campusName: string }) {
  return (
    <div className="mt-8 p-5 rounded-2xl bg-[var(--color-surface)] border border-[var(--color-accent)]/30">
      <ShieldCheck size={22} className="text-[var(--color-accent)]" />
      <p className="mt-3 text-base font-bold">Check your inbox</p>
      <p className="mt-1 text-sm text-[var(--color-text-secondary)]">
        Magic link sent to <span className="font-semibold text-white">{email}</span>.
      </p>
      <p className="mt-1 text-sm text-[var(--color-text-secondary)]">
        Opening it will sign you in and verify you as a {campusName} student.
      </p>
      <p className="mt-4 text-xs text-[var(--color-text-tertiary)]">
        Not in your inbox? Check spam. Link expires in 15 min.
      </p>
    </div>
  );
}

