import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase-server";

/**
 * Officer-triggered broadcast (push / email / both) to org members.
 *
 * Crit-#9 patch: previously trusted the client-supplied `organization_id` with no auth.
 * Anonymous callers could fan out at any org. We now require an authenticated session
 * AND active officer membership of `organization_id` before the DB insert (the rate-limit
 * trigger then enforces 5/24h).
 */
export async function POST(req: NextRequest) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ ok: false, error: "unauthorized" }, { status: 401 });

  const { organization_id, channel, subject, body, event_id } =
    (await req.json().catch(() => ({}))) as Partial<{
      organization_id: string;
      channel: "push" | "email" | "both";
      subject: string;
      body: string;
      event_id?: string;
    }>;

  if (!organization_id || !channel || !subject || !body) {
    return NextResponse.json({ ok: false, error: "missing_params" }, { status: 400 });
  }
  if (subject.length > 120 || body.length > 2000) {
    return NextResponse.json({ ok: false, error: "too_long" }, { status: 413 });
  }
  if (!["push", "email", "both"].includes(channel)) {
    return NextResponse.json({ ok: false, error: "bad_channel" }, { status: 400 });
  }

  const { data: officer } = await supabase
    .from("memberships")
    .select("role")
    .eq("profile_id", user.id)
    .eq("organization_id", organization_id)
    .in("role", ["president", "founder", "vicePresident", "officer"])
    .maybeSingle();
  if (!officer) return NextResponse.json({ ok: false, error: "forbidden" }, { status: 403 });

  // Production:
  //   1. Insert into `broadcasts` table (rate limit enforced by trigger).
  //   2. Pull active member profile_ids; resolve push tokens + email addresses.
  //   3. Fan out via /api/push/send (Bearer CRON_SECRET) + Postmark in parallel batches.
  return NextResponse.json({ ok: true, organization_id, channel, event_id: event_id ?? null });
}
