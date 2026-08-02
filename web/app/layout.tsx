import type { Metadata, Viewport } from "next";
import { Analytics } from "@vercel/analytics/next";
import { SpeedInsights } from "@vercel/speed-insights/next";
import "./globals.css";
import { fontDisplay, fontSans, fontMono } from "./fonts";
import AppShell from "@/components/AppShell";
import MobileTabBar from "@/components/MobileTabBar";
import AppBanner from "@/components/AppBanner";
import CommandPalette from "@/components/CommandPalette";
import CursorGlow from "@/components/CursorGlow";
import KeyboardShortcuts from "@/components/KeyboardShortcuts";
import ScrollProgress from "@/components/ScrollProgress";
import PWA from "@/components/PWA";
import { SITE, SITE_URL } from "@/lib/site";

const TITLE = `${SITE.name}: ${SITE.tagline}`;

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: { default: TITLE, template: `%s · ${SITE.name}` },
  description: SITE.description,
  applicationName: SITE.name,
  appleWebApp: { capable: true, title: SITE.name, statusBarStyle: "black-translucent" },
  keywords: [
    "college events", "university events", "campus events", "college app",
    "rush week", "greek life", "college parties", "student app", "free food",
    "college clubs", "campus map", "ucsd events", "ucla events",
  ],
  alternates: { canonical: SITE_URL },
  openGraph: {
    type: "website",
    siteName: SITE.name,
    title: TITLE,
    description: SITE.shortDescription,
    url: SITE_URL,
    locale: "en_US",
  },
  twitter: {
    card: "summary_large_image",
    title: TITLE,
    description: SITE.shortDescription,
  },
  category: "social",
  robots: {
    index: true, follow: true,
    googleBot: { index: true, follow: true, "max-image-preview": "large", "max-snippet": -1 },
  },
  verification: {
    google: process.env.NEXT_PUBLIC_GOOGLE_SITE_VERIFICATION,
  },
};

export const viewport: Viewport = {
  themeColor: SITE.themeColor,
  width: "device-width",
  initialScale: 1,
  viewportFit: "cover",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html
      lang="en"
      className={`${fontDisplay.variable} ${fontSans.variable} ${fontMono.variable}`}
    >
      <body className="font-sans">
        <a href="#main" className="skip-link">Skip to content</a>
        <ScrollProgress />
        <CursorGlow />
        <AppBanner />
        <AppShell>{children}</AppShell>
        <MobileTabBar />
        <CommandPalette />
        <KeyboardShortcuts />
        <PWA />
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  );
}
