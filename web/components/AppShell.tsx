"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  Compass, Map as MapIcon, Users, MessageCircle, User, Settings, Search, Bell,
} from "lucide-react";
import Wordmark from "./Wordmark";

const primary = [
  { href: "/feed",     label: "Feed",     icon: Compass,       shortcut: "F" },
  { href: "/map",      label: "Map",      icon: MapIcon,       shortcut: "M" },
  { href: "/clubs",    label: "Clubs",    icon: Users,         shortcut: "C" },
  { href: "/messages", label: "Messages", icon: MessageCircle, shortcut: "I" },
];

const secondary = [
  { href: "/profile",  label: "Profile",  icon: User,     shortcut: "P" },
  { href: "/settings", label: "Settings", icon: Settings, shortcut: "," },
];

export default function AppShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  // Landing and route-less pages render without the app chrome so they can go
  // full-bleed (shader canvas, 3D hero, etc.).
  if (pathname === "/" || pathname === "/sign-in" || pathname?.startsWith("/auth/")) {
    return <>{children}</>;
  }
  return (
    <div className="min-h-screen flex flex-col">
      <TopBar />
      <div className="flex-1 flex">
        <Sidebar />
        <main className="flex-1 min-w-0">{children}</main>
      </div>
    </div>
  );
}

function TopBar() {
  return (
    <header className="sticky top-0 z-40 h-14 px-4 md:px-6 flex items-center justify-between bg-[var(--color-bg)]/75 backdrop-blur-xl border-b border-[var(--color-border)]">
      <Link href="/" className="flex items-center gap-2.5">
        <Wordmark />
      </Link>
      <div className="flex-1 max-w-lg mx-4 hidden md:block">
        <button
          data-cmdk
          className="w-full flex items-center gap-2 h-9 px-3 rounded-lg bg-[var(--color-surface)] border border-[var(--color-border)] hover:border-[var(--color-border-strong)] text-left text-sm text-[var(--color-text-tertiary)]"
        >
          <Search size={14} />
          <span className="flex-1">Search events, clubs, people…</span>
          <kbd className="font-mono text-[10px] px-1.5 py-0.5 rounded border border-[var(--color-border)] text-[var(--color-text-tertiary)]">
            ⌘K
          </kbd>
        </button>
      </div>
      <div className="flex items-center gap-1.5">
        <button data-cmdk className="md:hidden w-9 h-9 rounded-lg flex items-center justify-center hover:bg-[var(--color-surface)]" aria-label="Search">
          <Search size={16} />
        </button>
        <button className="w-9 h-9 rounded-lg flex items-center justify-center hover:bg-[var(--color-surface)] relative" aria-label="Notifications">
          <Bell size={16} />
          <span className="absolute top-2 right-2 w-1.5 h-1.5 rounded-full bg-[var(--color-live)]" />
        </button>
        <Link
          href="/sign-in"
          className="hidden md:inline-flex h-9 px-4 items-center rounded-lg bg-[var(--color-accent)] text-black font-semibold text-sm"
        >
          Sign in
        </Link>
      </div>
    </header>
  );
}

function Sidebar() {
  const pathname = usePathname();
  return (
    <nav className="hidden md:flex w-56 shrink-0 border-r border-[var(--color-border)] flex-col py-4 px-3 sticky top-14 h-[calc(100vh-3.5rem)]">
      <ul className="space-y-0.5">
        {primary.map((item) => (
          <SidebarItem key={item.href} {...item} active={pathname === item.href} />
        ))}
      </ul>
      <div className="mt-auto space-y-0.5">
        {secondary.map((item) => (
          <SidebarItem key={item.href} {...item} active={pathname === item.href} />
        ))}
      </div>
      <div className="mt-3 px-3 font-mono text-[10px] text-[var(--color-text-quaternary)] uppercase tracking-[0.18em]">
        v0.1 · built at UCSD
      </div>
    </nav>
  );
}

function SidebarItem({
  href, label, icon: Icon, shortcut, active,
}: {
  href: string;
  label: string;
  icon: React.ComponentType<{ size?: number }>;
  shortcut?: string;
  active: boolean;
}) {
  return (
    <li>
      <Link
        href={href}
        className={`group flex items-center gap-3 h-9 px-3 rounded-lg text-sm font-medium transition-colors ${
          active
            ? "bg-[var(--color-accent-dim)] text-[var(--color-accent-bright)]"
            : "text-[var(--color-text-secondary)] hover:bg-[var(--color-surface)] hover:text-[var(--color-text)]"
        }`}
      >
        <Icon size={16} />
        <span className="flex-1">{label}</span>
        {shortcut && (
          <kbd
            className={`font-mono text-[10px] px-1.5 py-0.5 rounded border ${
              active
                ? "border-[var(--color-accent)]/40 text-[var(--color-accent-bright)]"
                : "border-[var(--color-border)] text-[var(--color-text-quaternary)] group-hover:border-[var(--color-border-strong)]"
            }`}
          >
            {shortcut}
          </kbd>
        )}
      </Link>
    </li>
  );
}
