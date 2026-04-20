import type { Metadata, Viewport } from "next";
import "./globals.css";
import { PWAInstaller } from "@/components/PWAInstaller";

export const metadata: Metadata = {
  metadataBase: new URL("https://buzz.app"),
  title: {
    default: "Buzz — every college event, on one map",
    template: "%s · Buzz",
  },
  description:
    "Live discovery for college students. See parties, clubs, sports, free food, and academic events happening tonight on and around campus. Free on iOS, macOS, and web.",
  keywords: [
    "college events","university events","campus events","college app",
    "rush week","greek life","college parties","student app","free food",
    "college clubs","campus map","ucsd events","ucla events","harvard events",
  ],
  authors: [{ name: "Buzz" }],
  creator: "Buzz",
  publisher: "Buzz",
  alternates: { canonical: "https://buzz.app" },
  openGraph: {
    type: "website",
    siteName: "Buzz",
    title: "Buzz — every college event, on one map",
    description: "Live discovery for college students. Free. iOS, macOS, and web.",
    url: "https://buzz.app",
    locale: "en_US",
    images: [{ url: "/og.png", width: 1200, height: 630, alt: "Buzz — college events on a map" }],
  },
  twitter: {
    card: "summary_large_image",
    title: "Buzz — every college event, on one map",
    description: "Live discovery for college students.",
    images: ["/og.png"],
  },
  manifest: "/manifest.webmanifest",
  appleWebApp: { capable: true, statusBarStyle: "black-translucent", title: "Buzz" },
  itunes: { appId: "TBD" },      // replace with real App Store ID once assigned
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
    <html lang="en">
      <head>
        {/* iOS Smart App Banner — one-tap App Store install prompt on Safari iOS. Replace
            `TBD` with the App Store numeric ID once Apple assigns it post-submission. */}
        <meta name="apple-itunes-app" content="app-id=TBD" />
      </head>
      <body>
        {children}
        <PWAInstaller />
      </body>
    </html>
  );
}
