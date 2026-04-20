import { NextRequest, NextResponse } from "next/server";

/**
 * Triggered by a Supabase Database Webhook on `events` insert/update where
 * `status = 'published'`. Looks up registered `webhook_endpoints` for the org and
 * fans out an announcement to Discord / Slack / generic JSON consumers.
 *
 *   POST /api/webhook-relay
 *   Body: Supabase webhook payload
 */
export async function POST(req: NextRequest) {
  const payload = (await req.json().catch(() => null)) as
    | { record?: { id: string; title: string; organization_id: string; starts_at: string; status: string } }
    | null;

  const event = payload?.record;
  if (!event || event.status !== "published") {
    return NextResponse.json({ ok: true, skipped: true });
  }

  // Real impl: fetch all webhook_endpoints for event.organization_id from Supabase, then
  // POST a kind-specific payload to each URL in parallel. We log failures but never block
  // the publish flow — this is best-effort fan-out.
  const endpoints = MOCK_ENDPOINTS_FOR_DEV;

  const results = await Promise.allSettled(
    endpoints.map((ep) => deliverTo(ep, event))
  );

  return NextResponse.json({
    ok: true,
    event_id: event.id,
    delivered: results.filter((r) => r.status === "fulfilled").length,
    failed: results.filter((r) => r.status === "rejected").length,
  });
}

type Endpoint = { kind: "discord" | "slack" | "generic"; url: string };

const MOCK_ENDPOINTS_FOR_DEV: Endpoint[] = [];

async function deliverTo(
  ep: Endpoint,
  event: { id: string; title: string; starts_at: string }
): Promise<void> {
  const url = `https://buzz.app/e/${event.id}`;
  let body: object;

  switch (ep.kind) {
    case "discord":
      body = {
        embeds: [{
          title: event.title,
          url,
          description: `Starts ${new Date(event.starts_at).toLocaleString()}`,
          color: 0xFFD60A,
          footer: { text: "Posted via Buzz" },
        }],
      };
      break;
    case "slack":
      body = {
        text: `*<${url}|${event.title}>* — starts ${new Date(event.starts_at).toLocaleString()}`,
      };
      break;
    case "generic":
      body = { event_id: event.id, title: event.title, starts_at: event.starts_at, url };
      break;
  }

  const res = await fetch(ep.url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error(`webhook ${ep.kind} ${res.status}`);
}
