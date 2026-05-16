import { NextRequest, NextResponse } from "next/server";
import { assertPublicHttpsUrl, verifySharedSecret } from "@/lib/security";

/**
 * Supabase database-webhook receiver. Triggered on `events` insert/update where
 * `status = 'published'`. Fans out to registered Discord/Slack/generic endpoints.
 *
 * Crit-#17 patch: the route was unauthenticated, so anyone could forge a Supabase
 * webhook payload and use Buzz as a relay. We now require a shared `SUPABASE_WEBHOOK_SECRET`
 * header, AND every outbound delivery URL passes the SSRF guard so a malicious officer
 * can't register `http://169.254.169.254/...` and trigger it remotely.
 */
export async function POST(req: NextRequest) {
  if (!verifySharedSecret(req, "SUPABASE_WEBHOOK_SECRET")) {
    return NextResponse.json({ ok: false, error: "unauthorized" }, { status: 401 });
  }

  const payload = (await req.json().catch(() => null)) as
    | { record?: { id: string; title: string; organization_id: string; starts_at: string; status: string } }
    | null;
  const event = payload?.record;
  if (!event || event.status !== "published") {
    return NextResponse.json({ ok: true, skipped: true });
  }

  const endpoints: Endpoint[] = MOCK_ENDPOINTS_FOR_DEV;

  const results = await Promise.allSettled(endpoints.map((ep) => deliverTo(ep, event)));
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
  // SSRF guard before every outbound fetch — protects against an officer registering a
  // metadata/loopback URL that we'd otherwise POST credentials-bearing payloads to.
  let target: URL;
  try { target = await assertPublicHttpsUrl(ep.url); }
  catch { throw new Error(`blocked_${ep.kind}_url`); }

  // Defense-in-depth: validate per-kind hostnames per Red-team #18.
  const host = target.hostname.toLowerCase();
  if (ep.kind === "discord" && !host.endsWith("discord.com") && !host.endsWith("discordapp.com")) {
    throw new Error("discord_host_mismatch");
  }
  if (ep.kind === "slack" && !host.endsWith("slack.com")) {
    throw new Error("slack_host_mismatch");
  }

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

  const controller = new AbortController();
  const t = setTimeout(() => controller.abort(), 5_000);
  try {
    const res = await fetch(target, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
      signal: controller.signal,
    });
    if (!res.ok) throw new Error(`webhook ${ep.kind} ${res.status}`);
  } finally { clearTimeout(t); }
}
