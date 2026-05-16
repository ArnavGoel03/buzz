import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase-server";
import { createClient as createSupabaseClient } from "@supabase/supabase-js";

/**
 * Create a Stripe Checkout session for a ticket purchase. Auth-gated; `buyer_id` is
 * derived from the session (never trusted from the request body).
 *
 *   POST /api/tickets/checkout
 *   { ticket_type_id }
 *
 * The org's Stripe Connect account receives the payment minus a 5% platform fee.
 * Missing `STRIPE_SECRET_KEY` returns 500 in production — never a plausible-looking
 * "mock" URL that would deceive the iOS client into thinking a purchase succeeded.
 */
export async function POST(req: NextRequest) {
  const userClient = await createClient();
  const { data: { user } } = await userClient.auth.getUser();
  if (!user) return NextResponse.json({ ok: false, error: "unauthorized" }, { status: 401 });

  const { ticket_type_id } = (await req.json().catch(() => ({}))) as { ticket_type_id?: string };
  if (!ticket_type_id) {
    return NextResponse.json({ ok: false, error: "missing_params" }, { status: 400 });
  }

  const stripeKey = process.env.STRIPE_SECRET_KEY;
  const supaUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const supaServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!stripeKey || !supaUrl || !supaServiceKey) {
    if (process.env.NODE_ENV !== "production") {
      // Local dev without keys — surface the unconfigured state explicitly rather than
      // returning a fake URL that downstream clients might treat as success.
      return NextResponse.json({ ok: false, error: "dev_unconfigured" }, { status: 503 });
    }
    return NextResponse.json({ ok: false, error: "unconfigured" }, { status: 500 });
  }

  const admin = createSupabaseClient(supaUrl, supaServiceKey, { auth: { persistSession: false } });

  // Resolve ticket type → event → organization → connect account.
  const { data: type } = await admin
    .from("ticket_types")
    .select("id, event_id, price_cents, name, quantity_total")
    .eq("id", ticket_type_id)
    .maybeSingle();
  if (!type) return NextResponse.json({ ok: false, error: "ticket_type_not_found" }, { status: 404 });

  const { data: event } = await admin
    .from("events")
    .select("id, organization_id, title")
    .eq("id", type.event_id)
    .maybeSingle();
  if (!event?.organization_id) {
    return NextResponse.json({ ok: false, error: "event_not_ticketed" }, { status: 400 });
  }

  const { data: org } = await admin
    .from("organizations")
    .select("stripe_connect_account_id")
    .eq("id", event.organization_id)
    .maybeSingle();
  const connectId = org?.stripe_connect_account_id;
  if (!connectId) {
    return NextResponse.json({ ok: false, error: "org_not_onboarded" }, { status: 400 });
  }

  // Sold-out short-circuit (the DB trigger also enforces this, but a 200 here saves
  // the user a redirect to Stripe just to land back at the cancel URL).
  const { count } = await admin
    .from("tickets")
    .select("id", { count: "exact", head: true })
    .eq("ticket_type_id", ticket_type_id)
    .in("status", ["pending", "paid"]);
  if (type.quantity_total != null && count != null && count >= type.quantity_total) {
    return NextResponse.json({ ok: false, error: "sold_out" }, { status: 409 });
  }

  const fee = Math.floor(type.price_cents * 0.05);
  const body = new URLSearchParams();
  body.set("mode", "payment");
  body.set("payment_method_types[0]", "card");
  body.set("line_items[0][price_data][currency]", "usd");
  body.set("line_items[0][price_data][unit_amount]", String(type.price_cents));
  body.set("line_items[0][price_data][product_data][name]", `${event.title} — ${type.name}`);
  body.set("line_items[0][quantity]", "1");
  body.set("payment_intent_data[application_fee_amount]", String(fee));
  body.set("payment_intent_data[transfer_data][destination]", connectId);
  body.set("success_url", "https://buzz.app/tickets/success?session_id={CHECKOUT_SESSION_ID}");
  body.set("cancel_url", `https://buzz.app/e/${event.id}`);

  const res = await fetch("https://api.stripe.com/v1/checkout/sessions", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${stripeKey}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: body.toString(),
  });
  if (!res.ok) {
    return NextResponse.json({ ok: false, error: "stripe_error" }, { status: 502 });
  }
  const session = (await res.json()) as { id: string; url: string };

  // Insert pending row via the service-role-only RPC (declared in 0003 migration).
  await admin.rpc("tickets_insert_pending", {
    p_ticket_type_id: ticket_type_id,
    p_buyer_id: user.id,
    p_price_cents: type.price_cents,
    p_stripe_session: session.id,
  });

  return NextResponse.json({ ok: true, url: session.url });
}
