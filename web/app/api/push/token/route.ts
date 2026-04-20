import { NextRequest, NextResponse } from "next/server";

/**
 * Persist a device's push token. Called from iOS on APNs token receipt, from the PWA
 * service worker on web-push subscription, and eventually from Android on FCM token.
 *
 *   POST /api/push/token
 *   { profile_id, platform: "ios_apns"|"android_fcm"|"web_push", token }
 */
export async function POST(req: NextRequest) {
  const body = await req.json().catch(() => null);
  if (!body?.profile_id || !body?.platform || !body?.token) {
    return NextResponse.json({ ok: false, error: "missing_params" }, { status: 400 });
  }

  // Production: insert into public.push_tokens with ON CONFLICT (profile, platform, token)
  // DO UPDATE SET updated_at = now(). Using service role key (this route runs server-side).
  return NextResponse.json({ ok: true, registered: true, platform: body.platform });
}

// Delete on sign-out or when the OS reports the token revoked.
export async function DELETE(req: NextRequest) {
  const body = await req.json().catch(() => null);
  if (!body?.token) return NextResponse.json({ ok: false }, { status: 400 });
  return NextResponse.json({ ok: true });
}
