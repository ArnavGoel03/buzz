import Link from "next/link";
import { CheckCircle2, Users } from "lucide-react";
import { getOrgs } from "@/lib/data";

export const revalidate = 300;
export const metadata = { title: "Clubs & organizations" };

export default async function Clubs() {
  const orgs = await getOrgs();
  return (
    <div className="max-w-5xl mx-auto px-4 md:px-8 py-6">
      <h1
        className="text-2xl md:text-3xl font-black tracking-tight"
        style={{ fontFamily: "var(--font-display)" }}
      >
        Clubs & organizations
      </h1>
      <p className="mt-1 text-sm text-[var(--color-text-secondary)]">
        {orgs.length} orgs on your campus
      </p>

      <div className="mt-6 grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {orgs.map((org) => (
          <Link
            key={org.id}
            href={`/o/${org.handle}`}
            className="rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)] hover:border-[var(--color-border-strong)] p-5 transition-colors"
          >
            <div className="flex items-center gap-3">
              <div
                className="w-12 h-12 rounded-xl flex items-center justify-center text-xl font-black"
                style={{ background: org.accent_hex, color: "#000", fontFamily: "var(--font-display)" }}
              >
                {org.name[0]}
              </div>
              <div className="min-w-0">
                <div className="flex items-center gap-1">
                  <h3 className="font-bold truncate">{org.name}</h3>
                  {org.verified && <CheckCircle2 size={14} className="text-[var(--color-accent)] shrink-0" />}
                </div>
                <p className="text-xs text-[var(--color-text-tertiary)] truncate">{org.tagline}</p>
              </div>
            </div>
            <div className="mt-3 flex items-center justify-between text-xs text-[var(--color-text-tertiary)]">
              <span className="flex items-center gap-1">
                <Users size={12} />
                {org.member_count.toLocaleString()}
              </span>
              {org.category && <span>{org.category}</span>}
            </div>
          </Link>
        ))}
      </div>
      <div className="h-16 md:h-0" />
    </div>
  );
}
