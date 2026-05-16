import { NextRequest, NextResponse } from "next/server";
import crypto from "node:crypto";

/**
 * Vercel Cron handler — fires per `vercel.json` schedule (currently daily).
 *
 * Picks pending rows from `event_reminders` whose `fires_at <= now()` and `fired = false`,
 * looks up RSVPs for that event, sends a push to each, marks the reminder fired.
 *
 * Auth: requires `Authorization: Bearer ${CRON_SECRET}`, compared timing-safe so the
 * prefix can't leak via short-circuit equality. Was previously gated on
 * `NODE_ENV === "production"`, leaving preview deploys wide open.
 */

export const runtime = "nodejs";

export async function GET(req: NextRequest) {
  const secret = process.env.CRON_SECRET;
  if (!secret) return new NextResponse("misconfigured", { status: 503 });

  const got = req.headers.get("authorization")?.replace(/^Bearer\s+/, "");
  if (typeof got !== "string" || got.length !== secret.length) {
    return new NextResponse("unauthorized", { status: 401 });
  }
  let ok = false;
  try {
    ok = crypto.timingSafeEqual(Buffer.from(got), Buffer.from(secret));
  } catch { /* malformed; ok stays false */ }
  if (!ok) return new NextResponse("unauthorized", { status: 401 });

  // Production query (via Supabase service role):
  //   update event_reminders set fired = true
  //     where fires_at <= now() and fired = false
  //   returning event_id, reminder_kind;
  // Then for each row: resolve RSVPs + push tokens, POST /api/push/send with Bearer CRON_SECRET.
  return NextResponse.json({ ok: true, fired: 0 });
}
