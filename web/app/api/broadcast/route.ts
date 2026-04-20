import { NextRequest, NextResponse } from "next/server";

/**
 * Sends a broadcast (push / email / both) to org members. Server fans out to:
 *   - APNs / FCM for push
 *   - Postmark / Resend for email
 * Server-side rate limiting via the `enforce_broadcast_rate` trigger (5/24h per org).
 *
 *   POST /api/broadcast
 *   { organization_id, channel: "push"|"email"|"both", subject, body, event_id? }
 */
export async function POST(req: NextRequest) {
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

  // Production:
  //   1. Verify caller is an active officer of `organization_id` via Supabase JWT.
  //   2. Insert into `broadcasts` table (rate limit enforced by trigger).
  //   3. Pull active member profile_ids; resolve push tokens + email addresses.
  //   4. Fan out via APNs/FCM/Postmark in parallel batches (background worker, not inline).
  //
  // For this scaffold we just echo the intent.
  return NextResponse.json({
    ok: true,
    organization_id,
    channel,
    event_id: event_id ?? null,
    estimatedRecipients: 412,
    note: "Wire to APNs/FCM/Postmark; insert into public.broadcasts.",
  });
}
