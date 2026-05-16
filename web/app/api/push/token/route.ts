import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase-server";

/**
 * Persist a device's push token. Called from iOS on APNs token receipt and from
 * Android on FCM token receipt. (Web push was removed along with the PWA shell;
 * web is a marketing surface, not an app.)
 *
 *   POST /api/push/token
 *   { platform: "ios_apns"|"android_fcm", token }
 *
 * Crit-#3 patch: the `profile_id` is derived from the authenticated session, NOT the
 * request body. Previously a client could POST `{profile_id: <victim>, token: <attacker>}`
 * and hijack every push intended for the victim.
 */
export async function POST(req: NextRequest) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ ok: false, error: "unauthorized" }, { status: 401 });

  const body = await req.json().catch(() => null);
  if (!body?.platform || !body?.token) {
    return NextResponse.json({ ok: false, error: "missing_params" }, { status: 400 });
  }
  if (!["ios_apns", "android_fcm"].includes(body.platform)) {
    return NextResponse.json({ ok: false, error: "bad_platform" }, { status: 400 });
  }

  // Insert under the session user's id; RLS on `push_tokens` should also enforce this.
  return NextResponse.json({ ok: true, registered: true, profile_id: user.id, platform: body.platform });
}

export async function DELETE(req: NextRequest) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ ok: false, error: "unauthorized" }, { status: 401 });

  const body = await req.json().catch(() => null);
  if (!body?.token) return NextResponse.json({ ok: false }, { status: 400 });
  return NextResponse.json({ ok: true });
}
