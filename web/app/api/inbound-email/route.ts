import { NextRequest, NextResponse } from "next/server";
import { parseEventEmail } from "@/lib/parse-event-email";
import { createClient } from "@/lib/supabase-server";
import { verifyMailgunSignature } from "@/lib/security";

/**
 * Inbound email webhook. MX `events.buzz.app` → Mailgun → POST here.
 * Address pattern: `<org-handle>@events.buzz.app`.
 *
 * Mailgun's "Forward" / "Store and Notify" routes POST `multipart/form-data`, not JSON,
 * with `timestamp`/`token`/`signature` at the top level (per Mailgun docs). The previous
 * implementation assumed JSON and a nested signature shape — both wrong. This version
 * uses `req.formData()` and the canonical Mailgun field names.
 *
 * Crit-#6 patch: HMAC verified; sender must own an officer membership of the target org.
 */
export async function POST(req: NextRequest) {
  const signingKey = process.env.MAILGUN_SIGNING_KEY;
  if (!signingKey) {
    return NextResponse.json({ ok: false, error: "unconfigured" }, { status: 503 });
  }

  const form = await req.formData().catch(() => null);
  if (!form) return NextResponse.json({ ok: false, error: "invalid_payload" }, { status: 400 });

  const get = (k: string) => {
    const v = form.get(k);
    return typeof v === "string" ? v : "";
  };
  const timestamp = get("timestamp");
  const token     = get("token");
  const signature = get("signature");
  if (!verifyMailgunSignature(timestamp, token, signature, signingKey)) {
    return NextResponse.json({ ok: false, error: "bad_signature" }, { status: 401 });
  }

  const recipient = get("recipient") || get("To");
  const subject   = get("subject")   || get("Subject");
  const body      = get("body-plain") || get("stripped-text") || get("body-html") || "";
  const fromEmail = (get("sender") || get("From")).toLowerCase().trim();

  // Handle shape: `^[a-z0-9-]{1,40}$` matches the admin-route guard.
  const handle = (recipient.split("@")[0] ?? "").toLowerCase().trim();
  if (!handle || !/^[a-z0-9-]{1,40}$/.test(handle) || !fromEmail) {
    return NextResponse.json({ ok: false, error: "bad_handle_or_sender" }, { status: 400 });
  }

  const supabase = await createClient();
  // Look up the sender by email on `profiles` (which carries `email` after the auth-callback
  // upsert). Falls back to a 403 — no draft is created for unknown senders.
  const { data: senderProfile } = await supabase
    .from("profiles")
    .select("id")
    .eq("email", fromEmail)
    .maybeSingle();
  if (!senderProfile) {
    return NextResponse.json({ ok: false, error: "sender_unknown" }, { status: 403 });
  }
  // Officer check by handle. The membership table uses `organization_id`; resolve the
  // org first, then check membership against its UUID — avoids the `org_handle` column
  // mismatch that broke earlier versions.
  const { data: org } = await supabase
    .from("organizations")
    .select("id")
    .eq("handle", handle)
    .maybeSingle();
  if (!org) {
    return NextResponse.json({ ok: false, error: "org_unknown" }, { status: 403 });
  }
  const { data: officer } = await supabase
    .from("memberships")
    .select("role")
    .eq("profile_id", senderProfile.id)
    .eq("organization_id", org.id)
    .in("role", ["president", "founder", "vicePresident", "officer"])
    .maybeSingle();
  if (!officer) {
    return NextResponse.json({ ok: false, error: "not_officer" }, { status: 403 });
  }

  const draft = parseEventEmail(subject, body);
  return NextResponse.json({
    ok: true,
    handle,
    draft,
    nextStep: draft.confidence === "low" ? "low_confidence_review_needed" : "ready_for_officer_review",
  });
}
