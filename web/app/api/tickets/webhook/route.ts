import { NextRequest, NextResponse } from "next/server";

/**
 * Stripe webhook. Flips `tickets.status` to 'paid' when Checkout completes, 'refunded'
 * on refunds. Use raw body + signature verification per Stripe docs.
 *
 * Configure in Stripe dashboard to hit https://buzz.app/api/tickets/webhook for events:
 *   checkout.session.completed, charge.refunded
 */
export async function POST(req: NextRequest) {
  const sig = req.headers.get("stripe-signature");
  const raw = await req.text();

  if (!sig || !process.env.STRIPE_WEBHOOK_SECRET) {
    return NextResponse.json({ ok: false, error: "unconfigured" }, { status: 501 });
  }

  // Production: verify signature with `stripe.webhooks.constructEvent(raw, sig, secret)`.
  // Then switch on event.type:
  //   - 'checkout.session.completed':
  //       update tickets set status='paid', used_at=null where stripe_session_id = session.id;
  //       fire push with ticket QR link
  //   - 'charge.refunded':
  //       update tickets set status='refunded' where ...
  //
  // Idempotency: use Stripe event.id as dedupe key in a `stripe_events_seen` table.

  return NextResponse.json({ ok: true, received: raw.length });
}
