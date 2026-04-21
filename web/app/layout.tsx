import type { Metadata, Viewport } from "next";
import "./globals.css";
import { fontDisplay, fontSans, fontMono } from "./fonts";
import { PWAInstaller } from "@/components/PWAInstaller";
import AppShell from "@/components/AppShell";
import MobileTabBar from "@/components/MobileTabBar";
import AppBanner from "@/components/AppBanner";
import CommandPalette from "@/components/CommandPalette";
import CursorGlow from "@/components/CursorGlow";
import KeyboardShortcuts from "@/components/KeyboardShortcuts";
import ScrollProgress from "@/components/ScrollProgress";

export const metadata: Metadata = {
  metadataBase: new URL("https://buzz.app"),
  title: { default: "Buzz — every college event, one feed", template: "%s · Buzz" },
  description:
    "Live discovery for college students. Parties, clubs, sports, free food, and academic events happening tonight on and around campus. Free on iOS, macOS, and web.",
  keywords: [
    "college events", "university events", "campus events", "college app",
    "rush week", "greek life", "college parties", "student app", "free food",
    "college clubs", "campus map", "ucsd events", "ucla events",
  ],
  alternates: { canonical: "https://buzz.app" },
  openGraph: {
    type: "website",
    siteName: "Buzz",
    title: "Buzz — every college event, one feed",
    description: "Live discovery for college students. Free. iOS, macOS, and web.",
    url: "https://buzz.app",
    locale: "en_US",
    images: [{ url: "/og.png", width: 1200, height: 630, alt: "Buzz — college events on a map" }],
  },
  twitter: {
    card: "summary_large_image",
    title: "Buzz — every college event, one feed",
    description: "Live discovery for college students.",
    images: ["/og.png"],
  },
  manifest: "/manifest.webmanifest",
  appleWebApp: { capable: true, statusBarStyle: "black-translucent", title: "Buzz" },
  category: "social",
  robots: {
    index: true, follow: true,
    googleBot: { index: true, follow: true, "max-image-preview": "large", "max-snippet": -1 },
  },
};

export const viewport: Viewport = {
  themeColor: "#0a0a0f",
  width: "device-width",
  initialScale: 1,
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html
      lang="en"
      className={`${fontDisplay.variable} ${fontSans.variable} ${fontMono.variable}`}
    >
      <head>
        <meta name="apple-itunes-app" content="app-id=TBD" />
      </head>
      <body className="font-sans">
        <ScrollProgress />
        <CursorGlow />
        <AppBanner />
        <AppShell>{children}</AppShell>
        <MobileTabBar />
        <CommandPalette />
        <KeyboardShortcuts />
        <PWAInstaller />
      </body>
    </html>
  );
}
