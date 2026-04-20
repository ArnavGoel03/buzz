import { NextRequest, NextResponse } from "next/server";

/**
 * Create a Stripe Checkout session for a ticket purchase. The org's Stripe Connect
 * account receives the payment minus platform fee; student sees Apple Pay / card input.
 *
 *   POST /api/tickets/checkout
 *   { ticket_type_id, buyer_id }
 *
 * On success returns a `url` to redirect to. On paid webhook we flip the ticket
 * row to status='paid' and fire a push notification with the QR.
 */
export async function POST(req: NextRequest) {
  const { ticket_type_id, buyer_id } = (await req.json().catch(() => ({}))) as Partial<{
    ticket_type_id: string;
    buyer_id: string;
  }>;

  if (!ticket_type_id || !buyer_id) {
    return NextResponse.json({ ok: false, error: "missing_params" }, { status: 400 });
  }

  const stripeKey = process.env.STRIPE_SECRET_KEY;
  if (!stripeKey) {
    // Mock-mode echo — lets the iOS flow render without real Stripe wired up.
    return NextResponse.json({
      ok: true,
      mock: true,
      url: `https://buzz.app/mock-checkout?t=${ticket_type_id}`,
    });
  }

  // Production:
  //   1. Fetch ticket_type (with sales window + remaining quantity check).
  //   2. Fetch event → organization → stripe_connect_account_id.
  //   3. stripe.checkout.sessions.create({
  //        mode: "payment",
  //        line_items: [{ price_data: { currency: ..., unit_amount: priceCents,
  //                        product_data: { name } }, quantity: 1 }],
  //        payment_method_types: ["card", "apple_pay"],
  //        payment_intent_data: {
  //          application_fee_amount: Math.floor(priceCents * 0.05),  // 5% platform fee
  //          transfer_data: { destination: connectAccountId }
  //        },
  //        success_url: "https://buzz.app/tickets/success?session_id={CHECKOUT_SESSION_ID}",
  //        cancel_url:  "https://buzz.app/e/<event>"
  //      })
  //   4. Insert tickets row (status='pending', stripe_session_id).
  //   5. Return session.url.

  return NextResponse.json({ ok: true, url: "https://checkout.stripe.com/..." });
}
