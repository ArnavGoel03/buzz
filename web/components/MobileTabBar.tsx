"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Compass, Map as MapIcon, Users, MessageCircle, User } from "lucide-react";

const tabs = [
  { href: "/feed",     label: "Feed",  icon: Compass },
  { href: "/map",      label: "Map",   icon: MapIcon },
  { href: "/clubs",    label: "Clubs", icon: Users },
  { href: "/messages", label: "Chats", icon: MessageCircle },
  { href: "/profile",  label: "Me",    icon: User },
];

export default function MobileTabBar() {
  const pathname = usePathname();
  // Hide on landing + auth routes so they go full-bleed.
  if (pathname === "/" || pathname === "/sign-in" || pathname?.startsWith("/auth/")) {
    return null;
  }
  return (
    <nav className="md:hidden sticky bottom-0 z-40 h-16 grid grid-cols-5 bg-[var(--color-bg)]/95 backdrop-blur border-t border-[var(--color-border)]">
      {tabs.map(({ href, label, icon: Icon }) => {
        const active = pathname === href;
        return (
          <Link
            key={href}
            href={href}
            className={`flex flex-col items-center justify-center gap-1 text-[10px] font-semibold ${
              active ? "text-[var(--color-accent)]" : "text-[var(--color-text-tertiary)]"
            }`}
          >
            <Icon size={20} />
            <span>{label}</span>
          </Link>
        );
      })}
    </nav>
  );
}
