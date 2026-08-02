import Link from "next/link";
import { ArrowRight, MessageCircle, Bell, QrCode, Ticket } from "lucide-react";
import GetApp from "@/components/GetApp";
import NotifyForm from "@/components/NotifyForm";
import { absoluteUrl } from "@/lib/site";

export const metadata = {
  title: "Messages",
  description: "Direct messages are not built yet. Here is what Buzz does today.",
  alternates: { canonical: absoluteUrl("/messages") },
};

/**
 * This page used to advertise chat, push, AR, and ticketing as if they shipped. None
 * of them do. Saying so costs one honest paragraph and buys the trust that makes the
 * rest of the product believable.
 */
export default function Messages() {
  const planned = [
    { icon: <MessageCircle size={18} />, title: "DMs and group chat", desc: "Message the people you RSVP with." },
    { icon: <Bell size={18} />, title: "Push notifications", desc: "A ping when free food drops near you." },
    { icon: <QrCode size={18} />, title: "Tap to check in", desc: "A QR at the door instead of a clipboard." },
    { icon: <Ticket size={18} />, title: "Paid tickets", desc: "For the events that charge at the door." },
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
        Not built yet.
      </h1>
      <p className="mt-4 text-[var(--color-text-secondary)] max-w-xl">
        There is no chat in Buzz today. What works right now is the part that matters
        most: finding what is on tonight, seeing who else is going, and sending it to
        the people you want there.
      </p>

      <div className="mt-7 flex flex-wrap items-center gap-3">
        <Link
          href="/feed"
          className="h-11 px-5 rounded-xl bg-[var(--color-accent)] text-[var(--color-accent-ink)] inline-flex items-center gap-2 font-semibold text-sm"
        >
          See tonight <ArrowRight size={14} />
        </Link>
        <GetApp variant="secondary" />
      </div>

      <section className="mt-12">
        <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-[var(--color-text-tertiary)] mb-3">
          § Planned, not shipped
        </p>
        <ul className="rim rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)] overflow-hidden divide-y divide-[var(--color-border)]">
          {planned.map((f) => (
            <li key={f.title} className="p-4 flex items-start gap-3 opacity-80">
              <div className="w-10 h-10 rounded-xl bg-[var(--color-surface-2)] text-[var(--color-text-tertiary)] flex items-center justify-center shrink-0">
                {f.icon}
              </div>
              <div className="flex-1">
                <p className="text-sm font-bold">{f.title}</p>
                <p className="text-xs text-[var(--color-text-tertiary)] mt-0.5">{f.desc}</p>
              </div>
            </li>
          ))}
        </ul>
        <p className="mt-3 text-xs text-[var(--color-text-tertiary)]">
          Order depends on what students actually ask for. Leave your email and you get
          told when one of these lands.
        </p>
        <div className="mt-4">
          <NotifyForm label="Tell me when there is more" hint="School email. One message, no newsletter." />
        </div>
      </section>

      <Link
        href="/feed"
        className="mt-10 inline-flex items-center gap-2 font-mono text-xs text-[var(--color-text-tertiary)] hover:text-[var(--color-text)]"
      >
        Back to feed <ArrowRight size={12} />
      </Link>
      <div className="h-16 md:h-0" />
    </div>
  );
}
