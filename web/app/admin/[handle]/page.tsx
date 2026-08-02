import type { Metadata } from "next";
import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import { mockOrg } from "@/lib/supabase";
import { createClient } from "@/lib/supabase-server";
import { Users, Calendar, Megaphone, FileText, Webhook, KeyRound } from "lucide-react";
import { absoluteUrl } from "@/lib/site";

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

      <section className="mt-8">
        <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-[var(--color-text-tertiary)]">
          § On the way
        </p>
        <p className="mt-2 text-sm text-[var(--color-text-secondary)] max-w-xl">
          Member management, broadcasts, and analytics are being built. The embed below
          works today. Nothing here shows a number until it is a real one.
        </p>
        <div className="mt-4 grid grid-cols-1 md:grid-cols-3 gap-4">
          <ActionCard title="Members" body="Bulk invite by paste or CSV. Approve join requests." icon={<Users size={18} />} />
          <ActionCard title="Events" body="Create, duplicate, repeat, draft." icon={<Calendar size={18} />} />
          <ActionCard title="Broadcast" body="Push or email everyone who follows you." icon={<Megaphone size={18} />} />
          <ActionCard title="Drafts" body="Forwarded-email drafts waiting on review." icon={<FileText size={18} />} />
          <ActionCard title="Webhooks" body="Discord, Slack, and generic JSON outputs." icon={<Webhook size={18} />} />
          <ActionCard title="Transfer ownership" body="Hand off to next year's officers." icon={<KeyRound size={18} />} />
        </div>
      </section>

      <section className="mt-10">
        <h2 className="text-lg font-bold" style={{ fontFamily: "var(--font-display)" }}>
          Embed code
        </h2>
        <p className="text-sm text-[var(--color-text-secondary)] mt-1">
          Paste this on your existing club website. It shows your upcoming events live.
        </p>
        <pre className="mt-3 p-4 rounded-xl bg-[var(--color-surface)] border border-[var(--color-border)] overflow-x-auto text-xs">
{`<iframe src="${absoluteUrl(`/embed/o/${handle}`)}"
        width="100%" height="500"
        style="border:0;border-radius:16px"></iframe>`}
        </pre>
      </section>
    </main>
  );
}

/** Not a link yet. A card that navigates nowhere is worse than one that says so. */
function ActionCard({ title, body, icon }: { title: string; body: string; icon: React.ReactNode }) {
  return (
    <div className="p-5 rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)] opacity-70">
      <div className="text-[var(--color-text-tertiary)]">{icon}</div>
      <div className="font-bold mt-2" style={{ fontFamily: "var(--font-display)" }}>
        {title}
      </div>
      <div className="text-sm text-[var(--color-text-secondary)] mt-1">{body}</div>
    </div>
  );
}
