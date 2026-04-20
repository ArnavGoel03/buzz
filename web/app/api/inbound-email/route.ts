import { NextRequest, NextResponse } from "next/server";
import { parseEventEmail } from "@/lib/parse-event-email";

/**
 * Inbound email webhook. DNS setup:
 *  1. Create MX record: `events.buzz.app` → Mailgun (or Postmark) routes
 *  2. Configure provider to POST parsed JSON to https://buzz.app/api/inbound-email
 *  3. Address pattern: `<org-handle>@events.buzz.app`
 *      - "acm-ucsd@events.buzz.app" → drafts an event for the ACM @ UCSD org
 *
 * The parsed email body is turned into a DraftEvent and inserted as a `pending` row.
 * The org's officers see a notification: "We drafted an event from your forwarded email."
 * One tap to publish.
 */
export async function POST(req: NextRequest) {
  // Mailgun/Postmark send slightly different shapes; normalize both.
  const payload = await req.json().catch(() => null);
  if (!payload) {
    return NextResponse.json({ ok: false, error: "invalid_payload" }, { status: 400 });
  }

  const recipient: string = payload.recipient ?? payload.To ?? "";
  const subject: string = payload.subject ?? payload.Subject ?? "";
  const body: string = payload["body-plain"] ?? payload.TextBody ?? payload.text ?? "";
  const fromEmail: string = payload.sender ?? payload.From ?? "";

  // Extract org handle from "<handle>@events.buzz.app"
  const handle = recipient.split("@")[0]?.toLowerCase().trim() ?? "";
  if (!handle) {
    return NextResponse.json({ ok: false, error: "missing_handle" }, { status: 400 });
  }

  const draft = parseEventEmail(subject, body);

  // Production: verify fromEmail belongs to a verified officer of `handle` via Supabase,
  // then `insert into events (status='draft', organization_id, ...)`. For now we just echo.
  return NextResponse.json({
    ok: true,
    handle,
    sender: fromEmail,
    draft,
    nextStep: draft.confidence === "low"
      ? "low_confidence_review_needed"
      : "ready_for_officer_review",
  });
}
