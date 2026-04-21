import { Fraunces, Geist, Geist_Mono } from "next/font/google";

// Editorial serif for display — Fraunces variable axis gives us weight + opticals
// that feel like a magazine, not a SaaS template.
export const fontDisplay = Fraunces({
  subsets: ["latin"],
  display: "swap",
  axes: ["opsz", "SOFT", "WONK"],
  variable: "--font-display",
});

export const fontSans = Geist({
  subsets: ["latin"],
  display: "swap",
  variable: "--font-sans",
});

export const fontMono = Geist_Mono({
  subsets: ["latin"],
  display: "swap",
  variable: "--font-mono",
});
