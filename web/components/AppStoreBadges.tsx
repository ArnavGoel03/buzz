import Link from "next/link";
import { Apple, Smartphone, Monitor } from "lucide-react";
import { APP_STORE_URL, PLAY_STORE_URL, MAC_APP_STORE_URL } from "@/lib/app-links";

// Three store badges: App Store, Mac App Store, Play Store. Use on download strips,
// the sign-in page, empty states ("No messages here — get the app"), etc.
export default function AppStoreBadges({ layout = "row" }: { layout?: "row" | "stack" }) {
  const badges = [
    { href: APP_STORE_URL, icon: <Apple size={18} />, top: "Download on the", bottom: "App Store" },
    { href: MAC_APP_STORE_URL, icon: <Monitor size={18} />, top: "Download on the", bottom: "Mac App Store" },
    { href: PLAY_STORE_URL, icon: <Smartphone size={18} />, top: "Get it on", bottom: "Google Play" },
  ];
  return (
    <div className={layout === "stack" ? "flex flex-col gap-2" : "flex flex-wrap gap-2"}>
      {badges.map((b) => (
        <Link
          key={b.bottom}
          href={b.href}
          className="flex items-center gap-2.5 px-4 h-12 rounded-xl bg-white text-black font-semibold"
        >
          {b.icon}
          <div className="text-left leading-none">
            <p className="text-[9px] uppercase tracking-wider opacity-70">{b.top}</p>
            <p className="text-sm font-black">{b.bottom}</p>
          </div>
        </Link>
      ))}
    </div>
  );
}
