import type { Metadata } from "next";
import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import { mockOrg } from "@/lib/supabase";
import { createClient } from "@/lib/supabase-server";

type Params = Promise<{ handle: string }>;

export const metadata: Metadata = { robots: { index: false, follow: false } };

// Officer-only web dashboard. High-#22 patch: previously rendered for anyone who knew the
// URL. Now requires an authenticated session AND active officer membership of `handle`.
export default async function AdminDashboard({ params }: { params: Params }) {
  const { handle } = await params;
  // Web #35 / sanity: bound the path param shape so a malicious handle can't smuggle HTML
  // characters into the embed snippet below.
  if (!/^[a-z0-9-]{1,40}$/.test(handle)) notFound();

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect(`/sign-in?next=/admin/${handle}`);

  // Membership uses organization_id (UUID); resolve the handle first.
  const { data: org } = await supabase
    .from("organizations")
    .select("id")
    .eq("handle", handle)
    .maybeSingle();
  if (!org) notFound();
  const { data: officer } = await supabase
    .from("memberships")
    .select("role")
    .eq("profile_id", user.id)
    .eq("organization_id", org.id)
    .in("role", ["president", "founder", "vicePresident", "officer"])
    .maybeSingle();
  if (!officer) notFound();

  const orgView = mockOrg(handle);

  return (
    <main className="min-h-screen px-6 py-12 max-w-5xl mx-auto">
      <header className="flex items-center gap-4">
        <div
          className="w-14 h-14 rounded-full flex items-center justify-center font-black"
          style={{ background: orgView.accent_hex, color: "#000" }}
        >
          {orgView.name[0]}
        </div>
        <div className="flex-1">
          <div className="text-xs font-bold uppercase tracking-wider text-[var(--color-text-tertiary)]">
            Admin
          </div>
          <h1 className="text-2xl font-black" style={{ fontFamily: "var(--font-display)" }}>
            {orgView.name}
          </h1>
        </div>
        <Link
          href={`/o/${handle}`}
          className="px-3 py-2 rounded-lg bg-[var(--color-surface)] border border-[var(--color-border)] text-sm font-semibold"
        >
          View public page
        </Link>
      </header>

      <section className="mt-8 grid grid-cols-2 md:grid-cols-4 gap-4">
        <Stat label="Members" value="412" />
        <Stat label="Events / 30d" value="9" />
        <Stat label="RSVPs / 30d" value="1.2k" />
        <Stat label="Attend rate" value="73%" />
      </section>

      <section className="mt-10 grid grid-cols-1 md:grid-cols-3 gap-4">
        <ActionCard title="Members" body="Bulk invite via paste / CSV. Approve join requests." href="#" icon="👥" />
        <ActionCard title="Events" body="Create, duplicate, recur, draft." href="#" icon="📅" />
        <ActionCard title="Broadcast" body="Push or email to all members." href="#" icon="📣" />
        <ActionCard title="Drafts" body="Forwarded-email drafts awaiting review." href="#" icon="✉️" />
        <ActionCard title="Webhooks" body="Discord, Slack, generic JSON outputs." href="#" icon="🔗" />
        <ActionCard title="Transfer ownership" body="Hand off to next year's officers." href="#" icon="🪪" />
      </section>

      <section className="mt-10">
        <h2 className="text-lg font-bold" style={{ fontFamily: "var(--font-display)" }}>
          Embed code
        </h2>
        <p className="text-sm text-[var(--color-text-secondary)] mt-1">
          Paste this on your existing club website — it'll show your upcoming events live.
        </p>
        <pre className="mt-3 p-4 rounded-xl bg-[var(--color-surface)] border border-[var(--color-border)] overflow-x-auto text-xs">
{`<iframe src="https://buzz.app/embed/o/${handle}"
        width="100%" height="500"
        style="border:0;border-radius:16px"></iframe>`}
        </pre>
      </section>
    </main>
  );
}

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div className="p-4 rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)]">
      <div className="text-2xl font-black" style={{ fontFamily: "var(--font-display)" }}>
        {value}
      </div>
      <div className="text-xs text-[var(--color-text-secondary)] mt-1">{label}</div>
    </div>
  );
}

function ActionCard({ title, body, href, icon }: { title: string; body: string; href: string; icon: string }) {
  return (
    <Link
      href={href}
      className="p-5 rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)] hover:border-[var(--color-accent)] transition-colors"
    >
      <div className="text-2xl">{icon}</div>
      <div className="font-bold mt-2" style={{ fontFamily: "var(--font-display)" }}>
        {title}
      </div>
      <div className="text-sm text-[var(--color-text-secondary)] mt-1">{body}</div>
    </Link>
  );
}
