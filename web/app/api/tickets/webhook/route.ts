import { NextRequest, NextResponse } from "next/server";
import crypto from "node:crypto";
import { createClient as createSupabaseClient } from "@supabase/supabase-js";

/**
 * Stripe webhook. Flips `tickets.status` between pending/paid/refunded as Stripe
 * confirms / refunds Checkout sessions.
 *
 * - Verifies the Stripe v1 signature manually (multi-`v1=` tolerant; any one match
 *   passes), with a 5-minute replay window.
 * - Idempotent via `stripe_events_seen.event_id` UNIQUE — duplicate Stripe deliveries
 *   no-op without re-writing the ticket row.
 * - Missing `STRIPE_WEBHOOK_SECRET` now returns 500 (was 200), so Stripe retries +
 *   logs the misconfig instead of silently dropping every payment forever.
 */
export async function POST(req: NextRequest) {
  const sig = req.headers.get("stripe-signature");
  const raw = await req.text();
  const secret = process.env.STRIPE_WEBHOOK_SECRET;
  const supaUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const supaServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!secret) {
    console.error("[stripe-webhook] STRIPE_WEBHOOK_SECRET not set; payment confirmations are dropping.");
    return NextResponse.json({ ok: false, error: "unconfigured" }, { status: 500 });
  }
  if (!sig) return NextResponse.json({ ok: false, error: "no_signature" }, { status: 401 });
  if (!verifyStripeSignature(raw, sig, secret)) {
    return NextResponse.json({ ok: false, error: "bad_signature" }, { status: 401 });
  }

  let event: { id: string; type: string; data: { object: Record<string, unknown> } };
  try { event = JSON.parse(raw); }
  catch { return NextResponse.json({ ok: false, error: "bad_json" }, { status: 400 }); }

  if (!supaUrl || !supaServiceKey) {
    console.error("[stripe-webhook] Supabase service-role missing; cannot record event.");
    return NextResponse.json({ ok: false, error: "supabase_unconfigured" }, { status: 500 });
  }
  const supabase = createSupabaseClient(supaUrl, supaServiceKey, { auth: { persistSession: false } });

  // Idempotency dedupe — UNIQUE PK on event_id means a duplicate fails fast.
  const { error: dupeErr } = await supabase
    .from("stripe_events_seen")
    .insert({ event_id: event.id });
  if (dupeErr && (dupeErr as { code?: string }).code === "23505") {
    return NextResponse.json({ ok: true, deduped: true });
  }
  if (dupeErr) {
    console.error("[stripe-webhook] dedupe insert failed:", dupeErr);
    return NextResponse.json({ ok: false, error: "dedupe_failed" }, { status: 500 });
  }

  if (event.type === "checkout.session.completed") {
    const session = event.data.object as { id: string };
    const { error } = await supabase
      .from("tickets")
      .update({ status: "paid" })
      .eq("stripe_session_id", session.id);
    if (error) return NextResponse.json({ ok: false, error: "ticket_update_failed" }, { status: 500 });
  } else if (event.type === "charge.refunded") {
    const charge = event.data.object as { payment_intent?: string };
    if (charge.payment_intent) {
      await supabase.rpc("tickets_mark_refunded", { p_stripe_session: charge.payment_intent });
    }
  }

  return NextResponse.json({ ok: true, type: event.type });
}

/**
 * Stripe v1 signature. Accepts any `v1=` entry matching during key rotation; rejects
 * if the timestamp is outside the 5-minute replay window.
 */
function verifyStripeSignature(rawBody: string, header: string, secret: string): boolean {
  let t: string | null = null;
  const v1s: string[] = [];
  for (const part of header.split(",")) {
    const i = part.indexOf("=");
    if (i < 0) continue;
    const k = part.slice(0, i), v = part.slice(i + 1);
    if (k === "t") t = v;
    else if (k === "v1") v1s.push(v);
  }
  if (!t || v1s.length === 0) return false;
  const now = Math.floor(Date.now() / 1000);
  if (Math.abs(now - parseInt(t, 10)) > 300) return false;
  const expected = crypto.createHmac("sha256", secret).update(`${t}.${rawBody}`).digest("hex");
  try {
    const a = Buffer.from(expected, "hex");
    if (a.length === 0) return false;
    return v1s.some((v) => {
      const b = Buffer.from(v, "hex");
      return b.length === a.length && crypto.timingSafeEqual(a, b);
    });
  } catch { return false; }
}
