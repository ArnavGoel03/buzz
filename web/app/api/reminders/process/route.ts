import { NextRequest, NextResponse } from "next/server";

/**
 * Vercel Cron handler — fires every 5 minutes (see vercel.json).
 *
 * Picks pending rows from `event_reminders` whose `fires_at <= now()` and `fired = false`,
 * looks up RSVPs for that event, sends a push to each, marks the reminder fired.
 *
 * Idempotent: an UPDATE in a single statement flips `fired = true` so a re-run during
 * a deploy or retry doesn't double-send.
 */

export const runtime = "nodejs";    // not edge — needs Postmark/FCM SDKs

export async function GET(req: NextRequest) {
  // Vercel signs cron requests; verify in production.
  if (process.env.NODE_ENV === "production") {
    const auth = req.headers.get("authorization");
    if (auth !== `Bearer ${process.env.CRON_SECRET}`) {
      return new NextResponse("unauthorized", { status: 401 });
    }
  }

  // Production query (parameterized via Supabase service role):
  //   update event_reminders set fired = true
  //     where fires_at <= now() and fired = false
  //   returning event_id, reminder_kind;
  // Then for each returned (event_id, reminder_kind):
  //   - fetch event title, starts_at, location_name
  //   - fetch RSVPs where status='going'
  //   - resolve push tokens from auth_identities (or store push_tokens table)
  //   - send via APNs/FCM with copy like "Doors open in 30 — Warren Quad Takeover"

  return NextResponse.json({
    ok: true,
    note: "Wire to Supabase + APNs/FCM. Returns count of reminders fired.",
    fired: 0,
  });
}
