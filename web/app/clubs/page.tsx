import Link from "next/link";
import { CheckCircle2, Users } from "lucide-react";
import { getOrgs } from "@/lib/data";
import AppPushStrip from "@/components/AppPushStrip";
import StaggerIn, { StaggerItem } from "@/components/StaggerIn";
import TiltCard from "@/components/landing/TiltCard";

export const revalidate = 300;
export const metadata = { title: "Clubs & organizations" };

export default async function Clubs() {
  const orgs = await getOrgs();
  const verifiedCount = orgs.filter((o) => o.verified).length;

  return (
    <div className="max-w-5xl mx-auto px-4 md:px-8 py-6">
      <header className="flex items-end justify-between gap-4 flex-wrap">
        <div>
          <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-[var(--color-text-tertiary)]">
            Campus · {orgs.length} orgs · {verifiedCount} verified
          </p>
          <h1
            className="mt-3 font-display font-medium tracking-[-0.02em] text-3xl md:text-5xl"
            style={{ fontFamily: "var(--font-display)" }}
          >
            Clubs & organizations
          </h1>
        </div>
      </header>

      <StaggerIn className="mt-8 grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {orgs.map((org) => (
          <StaggerItem key={org.id}>
            <TiltCard intensity={4} className="h-full">
              <Link
                href={`/o/${org.handle}`}
                className="block rim rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)] hover:border-[var(--color-border-strong)] p-5 transition-colors"
                style={{ background: `linear-gradient(160deg, ${org.accent_hex}14 0%, transparent 55%), var(--color-surface)` }}
              >
                <div className="flex items-center gap-3">
                  <div
                    className="w-12 h-12 rounded-xl flex items-center justify-center text-xl font-black"
                    style={{ background: org.accent_hex, color: "#000", fontFamily: "var(--font-display)" }}
                  >
                    {org.name[0]}
                  </div>
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center gap-1">
                      <h3 className="font-bold truncate">{org.name}</h3>
                      {org.verified && <CheckCircle2 size={14} className="text-[var(--color-accent)] shrink-0" />}
                    </div>
                    <p className="text-xs text-[var(--color-text-tertiary)] truncate">{org.tagline}</p>
                  </div>
                </div>
                <div className="mt-3 flex items-center justify-between text-xs text-[var(--color-text-tertiary)]">
                  <span className="flex items-center gap-1 font-mono tabular">
                    <Users size={12} />
                    {org.member_count.toLocaleString()}
                  </span>
                  {org.category && <span className="font-mono text-[10px] tracking-[0.1em] uppercase">{org.category}</span>}
                </div>
              </Link>
            </TiltCard>
          </StaggerItem>
        ))}
      </StaggerIn>
      <AppPushStrip />
      <div className="h-16 md:h-0" />
    </div>
  );
}
