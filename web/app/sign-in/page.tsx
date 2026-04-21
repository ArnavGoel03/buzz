"use client";

import { useState, useMemo } from "react";
import Link from "next/link";
import dynamic from "next/dynamic";
import { createClient } from "@/lib/supabase-browser";
import { GraduationCap, ShieldCheck, ArrowRight } from "lucide-react";
import AppStoreBadges from "@/components/AppStoreBadges";
import Wordmark from "@/components/Wordmark";
import TextReveal from "@/components/landing/TextReveal";
import { isAcademicEmail, resolveCampus, rejectReason } from "@/lib/campus-domains";

const ShaderBackground = dynamic(() => import("@/components/landing/ShaderBackground"), { ssr: false });

type Status = "idle" | "sending" | "sent" | "error";

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
    <main className="relative min-h-screen overflow-hidden text-white">
      <ShaderBackground />

      <header className="relative z-10 px-5 md:px-8 h-14 flex items-center justify-between border-b border-white/5 backdrop-blur-md bg-black/20">
        <Link href="/"><Wordmark /></Link>
        <Link href="/feed" className="font-mono text-[11px] uppercase tracking-[0.18em] text-white/60 hover:text-white">
          Browse feed
        </Link>
      </header>

      <div className="relative z-10 max-w-md mx-auto px-6 pt-16 pb-20">
        <p className="font-mono text-[11px] uppercase tracking-[0.24em] text-white/60 flex items-center gap-2">
          <span className="w-1.5 h-1.5 rounded-full bg-[var(--color-accent)] pulse-live" />
          Verified · school email only
        </p>
        <h1
          className="mt-5 font-display font-medium leading-[0.96] tracking-[-0.03em] text-[clamp(2.5rem,7vw,4.25rem)]"
          style={{ fontFamily: "var(--font-display)" }}
        >
          <TextReveal text="Prove you're" />{" "}
          <span
            className="italic text-[var(--color-accent)]"
            style={{ fontVariationSettings: "'SOFT' 80, 'WONK' 1" }}
          >
            <TextReveal text="a student." delay={0.2} />
          </span>
        </h1>
        <p className="mt-5 text-white/70 leading-relaxed">
          Type your school email. We send one magic link. Possession of the
          inbox is the verification — no passwords, no profile fill.
        </p>

        {status === "sent" ? (
          <SuccessState email={email} campusName={campus?.campusName ?? "your campus"} />
        ) : (
          <form onSubmit={handleSubmit} className="mt-8 space-y-3">
            <div className="relative">
              <GraduationCap
                size={18}
                className="absolute left-4 top-1/2 -translate-y-1/2 text-white/40 pointer-events-none"
              />
              <input
                type="email"
                required
                autoComplete="email"
                inputMode="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="your@school.edu"
                className="w-full h-14 pl-12 pr-4 rounded-2xl bg-black/40 backdrop-blur border border-white/15 text-base outline-none focus:border-[var(--color-accent)] focus:ring-1 focus:ring-[var(--color-accent)] placeholder:text-white/35"
              />
            </div>

            {campus && (
              <div className="flex items-center gap-2 text-xs text-[var(--color-accent)] px-1">
                <ShieldCheck size={14} />
                <span className="font-mono tracking-wider">
                  VERIFIED · {campus.campusName.toUpperCase()} · {campus.country.toUpperCase()}
                </span>
              </div>
            )}
            {clientError && email.length > 4 && (
              <p className="text-xs text-white/50 px-1">{clientError}</p>
            )}

            <button
              type="submit"
              disabled={!canSubmit}
              className="group relative w-full h-14 flex items-center justify-center gap-2 rounded-2xl bg-[var(--color-accent)] text-black font-semibold text-base disabled:opacity-50 disabled:cursor-not-allowed overflow-hidden"
            >
              <span className="relative z-10 flex items-center gap-2">
                {status === "sending" ? "Sending…" : "Email me a link"}
                {status !== "sending" && (
                  <ArrowRight size={16} className="transition-transform group-hover:translate-x-0.5" />
                )}
              </span>
            </button>
            {error && <p className="text-sm text-[var(--color-live)]">{error}</p>}
          </form>
        )}

        <div className="mt-12 pt-8 border-t border-white/10">
          <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-white/50 mb-3">
            § Or — native app
          </p>
          <p className="text-sm text-white/65 mb-4">
            Sign in with Apple in one tap. Push, chat, check-in — all native.
          </p>
          <AppStoreBadges layout="stack" />
        </div>

        <p className="mt-10 text-center font-mono text-[10px] text-white/40 tracking-wider">
          By continuing · {" "}
          <Link href="/legal/terms" className="underline">Terms</Link> · {" "}
          <Link href="/legal/privacy" className="underline">Privacy</Link>
        </p>
      </div>
    </main>
  );
}

function SuccessState({ email, campusName }: { email: string; campusName: string }) {
  return (
    <div className="mt-8 p-6 rounded-2xl rim bg-black/40 backdrop-blur border border-[var(--color-accent)]/40">
      <div className="flex items-center gap-3">
        <ShieldCheck size={22} className="text-[var(--color-accent)]" />
        <p className="font-mono text-[11px] uppercase tracking-[0.2em] text-[var(--color-accent)]">
          Magic link · en route
        </p>
      </div>
      <p className="mt-3 font-display text-2xl font-medium tracking-[-0.02em]" style={{ fontFamily: "var(--font-display)" }}>
        Check your inbox
      </p>
      <p className="mt-2 text-sm text-white/70">
        Sent to <span className="font-semibold text-white">{email}</span>. Opening
        the link signs you in and verifies you as a {campusName} student.
      </p>
      <p className="mt-4 font-mono text-[10px] text-white/40 tracking-wider uppercase">
        Not in inbox? Check spam · expires in 15 min
      </p>
    </div>
  );
}
