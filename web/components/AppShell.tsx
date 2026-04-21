"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  Compass,
  Map as MapIcon,
  Users,
  MessageCircle,
  User,
  Settings,
  Search,
  Bell,
  Sparkles,
} from "lucide-react";

const primary = [
  { href: "/", label: "Feed", icon: Compass },
  { href: "/map", label: "Map", icon: MapIcon },
  { href: "/clubs", label: "Clubs", icon: Users },
  { href: "/messages", label: "Messages", icon: MessageCircle },
];

const secondary = [
  { href: "/profile", label: "Profile", icon: User },
  { href: "/settings", label: "Settings", icon: Settings },
];

export default function AppShell({ children }: { children: React.ReactNode }) {
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
    <header className="sticky top-0 z-40 h-14 px-4 md:px-6 flex items-center justify-between bg-[var(--color-bg)]/85 backdrop-blur border-b border-[var(--color-border)]">
      <Link href="/" className="flex items-center gap-2">
        <span className="w-7 h-7 rounded-lg bg-[var(--color-accent)] flex items-center justify-center">
          <Sparkles size={16} className="text-black" strokeWidth={2.6} />
        </span>
        <span className="font-black text-lg tracking-tight" style={{ fontFamily: "var(--font-display)" }}>
          Buzz
        </span>
      </Link>
      <div className="flex-1 max-w-lg mx-4 hidden md:block">
        <SearchBar />
      </div>
      <div className="flex items-center gap-2">
        <Link
          href="/search"
          className="md:hidden w-9 h-9 rounded-lg flex items-center justify-center hover:bg-[var(--color-surface)]"
          aria-label="Search"
        >
          <Search size={18} />
        </Link>
        <button
          className="w-9 h-9 rounded-lg flex items-center justify-center hover:bg-[var(--color-surface)] relative"
          aria-label="Notifications"
        >
          <Bell size={18} />
          <span className="absolute top-2 right-2 w-2 h-2 rounded-full bg-[var(--color-live)]" />
        </button>
        <Link
          href="/sign-in"
          className="hidden md:inline-flex h-9 px-4 items-center rounded-lg bg-[var(--color-accent)] text-black font-bold text-sm"
        >
          Sign in
        </Link>
      </div>
    </header>
  );
}

function SearchBar() {
  return (
    <Link
      href="/search"
      className="flex items-center gap-2 h-9 px-3 rounded-lg bg-[var(--color-surface)] border border-[var(--color-border)] text-sm text-[var(--color-text-tertiary)] hover:border-[var(--color-border-strong)]"
    >
      <Search size={16} />
      <span>Search events, clubs, people…</span>
    </Link>
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
    </nav>
  );
}

function SidebarItem({
  href,
  label,
  icon: Icon,
  active,
}: {
  href: string;
  label: string;
  icon: React.ComponentType<{ size?: number }>;
  active: boolean;
}) {
  return (
    <li>
      <Link
        href={href}
        className={`flex items-center gap-3 h-10 px-3 rounded-lg text-sm font-medium transition-colors ${
          active
            ? "bg-[var(--color-accent-dim)] text-[var(--color-accent)]"
            : "text-[var(--color-text-secondary)] hover:bg-[var(--color-surface)] hover:text-[var(--color-text)]"
        }`}
      >
        <Icon size={18} />
        {label}
      </Link>
    </li>
  );
}
