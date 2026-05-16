import { NextRequest, NextResponse } from "next/server";

/**
 * Fan-out send across APNs + FCM. Internal-only — invoked by Supabase triggers, the
 * reminder cron, and broadcast workers via the CRON_SECRET header. Web push was
 * removed with the PWA shell; web is marketing/share-previews/admin only.
 *
 *   POST /api/push/send
 *   Authorization: Bearer <CRON_SECRET>
 *   { profile_ids, title, body, data?, collapseKey? }
 *
 * Crit-#4 patch: every public caller was able to push arbitrary content at any user.
 * We now reject anything without the shared internal secret.
 */
export async function POST(req: NextRequest) {
  const secret = process.env.CRON_SECRET;
  const got = req.headers.get("authorization")?.replace(/^Bearer\s+/, "");
  // Timing-safe Bearer compare so the prefix can't leak via short-circuit string equality.
  let ok = false;
  if (secret && typeof got === "string" && got.length === secret.length) {
    try {
      const crypto = await import("node:crypto");
      ok = crypto.timingSafeEqual(Buffer.from(got), Buffer.from(secret));
    } catch { /* keep ok=false */ }
  }
  if (!ok) return NextResponse.json({ ok: false, error: "unauthorized" }, { status: 401 });

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
  if (payload.title.length > 120 || payload.body.length > 2000) {
    return NextResponse.json({ ok: false, error: "too_long" }, { status: 413 });
  }

  // Production: read `push_tokens` via service role, fan out via APNs/FCM in parallel,
  // delete 410 Gone tokens, retry 429/5xx with backoff.
  return NextResponse.json({
    ok: true,
    queued: payload.profile_ids.length,
    note: "Wire APNs/FCM clients; read tokens via service role.",
  });
}
