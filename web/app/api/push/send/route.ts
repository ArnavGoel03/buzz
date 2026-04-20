import { NextRequest, NextResponse } from "next/server";

/**
 * Fan-out send across APNs + FCM + Web Push in parallel. Called from:
 *   - Free-food beacon creation (supabase trigger → call this endpoint)
 *   - Friend RSVP notifications
 *   - Invite received
 *   - Event reminder cron
 *
 *   POST /api/push/send
 *   {
 *     profile_ids: string[],
 *     title: string,
 *     body: string,
 *     data?: Record<string, string>,   // deep link, event id, etc.
 *     collapseKey?: string
 *   }
 */
export async function POST(req: NextRequest) {
  const payload = (await req.json().catch(() => null)) as Partial<{
    profile_ids: string[];
    title: string;
    body: string;
    data: Record<string, string>;
    collapseKey: string;
  }>;

  if (!payload?.profile_ids?.length || !payload.title || !payload.body) {
    return NextResponse.json({ ok: false, error: "missing_params" }, { status: 400 });
  }

  // Production steps:
  //   1. Auth — verify caller has privilege (server-to-server via CRON_SECRET or
  //      Supabase service role token bridged via header).
  //   2. Query public.push_tokens for all rows matching profile_ids (service role).
  //   3. Group by platform; fan out:
  //        - ios_apns   → APNs HTTP/2 (via `apn` or `node-apn-http2`)
  //        - android_fcm→ FCM HTTP v1 (via service account JSON)
  //        - web_push   → WebPush library with VAPID keys
  //   4. Handle failures:
  //        - 410 Gone → delete token row
  //        - 429       → retry with backoff
  //        - 5xx       → exponential backoff
  //   5. Log counts; return { ok, delivered, failed, platform_breakdown }.

  return NextResponse.json({
    ok: true,
    queued: payload.profile_ids.length,
    title: payload.title,
    note: "Wire APNs/FCM/web-push clients; read tokens via service role.",
  });
}
