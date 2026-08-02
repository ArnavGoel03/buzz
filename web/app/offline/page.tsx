import Link from "next/link";
import { WifiOff } from "lucide-react";

export const metadata = {
  title: "Offline",
  description: "You are offline. Cached pages still work.",
};

/**
 * Served by the service worker when a navigation fails with no network. Kept static
 * and dependency-free so it is guaranteed to be in the cache when it is needed.
 */
export default function Offline() {
  return (
    <div className="max-w-md mx-auto px-4 py-24 text-center">
      <div className="w-12 h-12 mx-auto rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)] flex items-center justify-center text-[var(--color-text-tertiary)]">
        <WifiOff size={20} />
      </div>
      <h1
        className="mt-5 font-display font-medium tracking-[-0.02em] text-3xl"
        style={{ fontFamily: "var(--font-display)" }}
      >
        No signal.
      </h1>
      <p className="mt-3 text-sm text-[var(--color-text-secondary)]">
        Campus wifi drops in basements and lecture halls. Pages you have already opened
        still work, and this one will reload itself the moment you are back.
      </p>
      <Link
        href="/feed"
        className="mt-6 inline-flex h-11 px-5 items-center rounded-xl bg-[var(--color-accent)] text-[var(--color-accent-ink)] font-semibold text-sm"
      >
        Back to the feed
      </Link>
    </div>
  );
}
