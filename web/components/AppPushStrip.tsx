import { Sparkles, Bell, MessageCircle, QrCode, Ticket } from "lucide-react";
import AppStoreBadges from "./AppStoreBadges";

// Section placed at the bottom of main browse pages to funnel web visitors into the
// native app, where the full product lives.
export default function AppPushStrip() {
  const bullets = [
    { icon: <Bell size={14} />, text: "Push alerts for free food + RSVPs" },
    { icon: <MessageCircle size={14} />, text: "Real-time chat with attendees" },
    { icon: <QrCode size={14} />, text: "Tap-to-check-in at the door" },
    { icon: <Ticket size={14} />, text: "Apple Pay tickets + Wallet" },
  ];
  return (
    <section className="mx-4 md:mx-8 my-10 p-6 md:p-8 rounded-2xl bg-gradient-to-br from-[var(--color-accent-dim)] to-[var(--color-surface)] border border-[var(--color-accent)]/30">
      <div className="flex items-center gap-2">
        <div className="w-8 h-8 rounded-lg bg-[var(--color-accent)] flex items-center justify-center">
          <Sparkles size={16} className="text-black" strokeWidth={2.6} />
        </div>
        <p className="text-xs font-bold uppercase tracking-wider text-[var(--color-accent)]">
          Full product
        </p>
      </div>
      <h2
        className="mt-3 text-2xl md:text-3xl font-black tracking-tight"
        style={{ fontFamily: "var(--font-display)" }}
      >
        Get Buzz — it unlocks everything.
      </h2>
      <ul className="mt-4 grid gap-2 md:grid-cols-2 text-sm text-[var(--color-text-secondary)]">
        {bullets.map((b) => (
          <li key={b.text} className="flex items-center gap-2">
            <span className="text-[var(--color-accent)]">{b.icon}</span>
            {b.text}
          </li>
        ))}
      </ul>
      <div className="mt-6">
        <AppStoreBadges />
      </div>
    </section>
  );
}
