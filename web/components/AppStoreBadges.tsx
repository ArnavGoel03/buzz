"use client";

import Link from "next/link";
import GetApp from "./GetApp";
import { INSTALL_PATH } from "@/lib/app-links";

/**
 * Replaces the old store badges. There is no App Store or Play listing yet, so a pair
 * of badge images would have been decoration pointing at nothing. This offers the
 * install that actually works, plus the link to the full install page.
 */
export default function AppStoreBadges({ layout = "row" }: { layout?: "row" | "stack" }) {
  const stacked = layout === "stack";
  return (
    <div className={stacked ? "grid gap-2" : "flex flex-wrap items-center gap-3"}>
      <GetApp className={stacked ? "w-full" : ""} />
      <Link
        href={INSTALL_PATH}
        className={`h-11 px-5 rounded-xl border border-[var(--color-border-strong)] inline-flex items-center justify-center text-sm font-semibold hover:border-[var(--color-border-bright)] ${
          stacked ? "w-full" : ""
        }`}
      >
        How it works
      </Link>
    </div>
  );
}
