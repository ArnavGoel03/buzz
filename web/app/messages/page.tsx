import { MessageCircle, Bell, QrCode, Camera, Ticket, ArrowRight } from "lucide-react";
import Link from "next/link";
import AppStoreBadges from "@/components/AppStoreBadges";

export const metadata = {
  title: "Chat & more — in the app",
  description: "Real-time DMs, push notifications, and check-in live in the Buzz native app.",
};

export default function Messages() {
  const features = [
    { icon: <MessageCircle size={18} />, title: "DMs & group chat", desc: "Message anyone you RSVP with, in realtime." },
    { icon: <Bell size={18} />, title: "Push notifications", desc: "Never miss a free-food drop." },
    { icon: <QrCode size={18} />, title: "Tap-to-check-in", desc: "QR scanner at the door. Your streak builds." },
    { icon: <Camera size={18} />, title: "AR Look Around", desc: "Point your phone, see events in real space." },
    { icon: <Ticket size={18} />, title: "Paid tickets", desc: "Apple Pay · Wallet · scanned at entry." },
  ];
  return (
    <div className="max-w-2xl mx-auto px-4 md:px-8 py-10">
      <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-[var(--color-text-tertiary)]">
        § Messages
      </p>
      <h1
        className="mt-3 font-display font-medium tracking-[-0.02em] leading-[1] text-4xl md:text-5xl"
        style={{ fontFamily: "var(--font-display)" }}
      >
        Chat lives in the app.
      </h1>
      <p className="mt-4 text-[var(--color-text-secondary)] max-w-xl">
        Realtime messaging, push, and check-in are smoother on native. Get Buzz — it&apos;s free for students.
      </p>

      <div className="mt-8">
        <AppStoreBadges />
      </div>

      <section className="mt-12">
        <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-[var(--color-text-tertiary)] mb-3">
          § Also in the app
        </p>
        <ul className="rim rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)] overflow-hidden divide-y divide-[var(--color-border)]">
          {features.map((f) => (
            <li key={f.title} className="p-4 flex items-start gap-3">
              <div className="w-10 h-10 rounded-xl bg-[var(--color-accent-dim)] text-[var(--color-accent)] flex items-center justify-center shrink-0">
                {f.icon}
              </div>
              <div className="flex-1">
                <p className="text-sm font-bold">{f.title}</p>
                <p className="text-xs text-[var(--color-text-tertiary)] mt-0.5">{f.desc}</p>
              </div>
            </li>
          ))}
        </ul>
      </section>

      <Link
        href="/feed"
        className="mt-10 inline-flex items-center gap-2 font-mono text-xs text-[var(--color-text-tertiary)] hover:text-white"
      >
        Back to feed <ArrowRight size={12} />
      </Link>
      <div className="h-16 md:h-0" />
    </div>
  );
}
