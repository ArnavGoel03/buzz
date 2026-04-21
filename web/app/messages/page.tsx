import { MessageCircle, Bell, QrCode, Camera, Ticket } from "lucide-react";
import AppStoreBadges from "@/components/AppStoreBadges";

export const metadata = {
  title: "Chat & more — in the app",
  description: "Real-time DMs, push notifications, and check-in live in the Buzz native app.",
};

export default function Messages() {
  const features = [
    { icon: <MessageCircle size={20} />, title: "DMs & group chat", desc: "Message anyone you RSVP with, live." },
    { icon: <Bell size={20} />, title: "Push notifications", desc: "Never miss a free-food drop." },
    { icon: <QrCode size={20} />, title: "Tap-to-check-in", desc: "QR scanner at the door. Your streak builds." },
    { icon: <Camera size={20} />, title: "AR Look Around", desc: "Point your phone, see events in real space." },
    { icon: <Ticket size={20} />, title: "Paid tickets", desc: "Apple Pay · saved in Wallet · scanned at entry." },
  ];
  return (
    <div className="max-w-md mx-auto px-4 py-12 text-center">
      <div className="w-14 h-14 mx-auto rounded-2xl bg-[var(--color-accent)] flex items-center justify-center">
        <MessageCircle size={26} className="text-black" strokeWidth={2.5} />
      </div>
      <h1
        className="mt-5 text-3xl font-black tracking-tight"
        style={{ fontFamily: "var(--font-display)" }}
      >
        Chat lives in the app
      </h1>
      <p className="mt-2 text-sm text-[var(--color-text-secondary)]">
        Real-time messaging is way smoother on native. Get Buzz — it&apos;s free.
      </p>

      <div className="mt-6">
        <AppStoreBadges layout="stack" />
      </div>

      <div className="mt-10 text-left">
        <p className="text-xs font-bold uppercase tracking-wider text-[var(--color-text-tertiary)] mb-2 px-1">
          Also in the app
        </p>
        <ul className="rounded-xl bg-[var(--color-surface)] border border-[var(--color-border)] divide-y divide-[var(--color-border)]">
          {features.map((f) => (
            <li key={f.title} className="p-4 flex items-start gap-3">
              <div className="w-9 h-9 rounded-lg bg-[var(--color-accent-dim)] text-[var(--color-accent)] flex items-center justify-center shrink-0">
                {f.icon}
              </div>
              <div>
                <p className="text-sm font-bold">{f.title}</p>
                <p className="text-xs text-[var(--color-text-tertiary)]">{f.desc}</p>
              </div>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
