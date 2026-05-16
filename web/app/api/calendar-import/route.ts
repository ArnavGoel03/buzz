import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase-server";
import { assertPublicHttpsUrl } from "@/lib/security";

/**
 * Imports events from a public iCal feed. Officer pastes the URL → all upcoming
 * events become drafts in the org's queue.
 *
 * Crit-#5 patch: previously an unauthenticated caller could pass any URL — including
 * `http://169.254.169.254/...` or `http://localhost/...` — and the response body would
 * be reflected in the error path. We now require a signed-in session AND that the
 * caller belongs to `handle`'s officer set, then route the fetch through the SSRF
 * guard (https-only, blocks RFC1918/link-local/loopback after DNS resolution), enforce
 * a hard timeout, and cap the body size.
 */
export async function POST(req: NextRequest) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ ok: false, error: "unauthorized" }, { status: 401 });

  const { handle, icalURL } = await req.json().catch(() => ({} as Record<string, string>));
  if (!handle || !icalURL) {
    return NextResponse.json({ ok: false, error: "missing_params" }, { status: 400 });
  }

  // Officer check — server-side, RLS-readable. The `memberships` table uses
  // `organization_id` (UUID), so resolve `handle` → org first, then check membership.
  const { data: org } = await supabase
    .from("organizations")
    .select("id")
    .eq("handle", handle)
    .maybeSingle();
  if (!org) return NextResponse.json({ ok: false, error: "forbidden" }, { status: 403 });
  const { data: membership } = await supabase
    .from("memberships")
    .select("role")
    .eq("profile_id", user.id)
    .eq("organization_id", org.id)
    .in("role", ["president", "founder", "vicePresident", "officer"])
    .maybeSingle();
  if (!membership) return NextResponse.json({ ok: false, error: "forbidden" }, { status: 403 });

  let url: URL;
  try { url = await assertPublicHttpsUrl(icalURL); }
  catch (e) {
    return NextResponse.json({ ok: false, error: "blocked_url", reason: String((e as Error).message) }, { status: 400 });
  }

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 5_000);
  let raw: string;
  try {
    const r = await fetch(url, {
      headers: { "User-Agent": "BuzzImporter/1.0" },
      redirect: "manual",
      signal: controller.signal,
    });
    if (!r.ok) throw new Error(`upstream ${r.status}`);
    // Cap response at 2 MB so a malicious URL can't exhaust memory.
    const buf = await r.arrayBuffer();
    if (buf.byteLength > 2 * 1024 * 1024) throw new Error("response_too_large");
    raw = new TextDecoder().decode(buf);
  } catch (e) {
    return NextResponse.json({ ok: false, error: "fetch_failed" }, { status: 502 });
  } finally {
    clearTimeout(timer);
  }

  const events = parseICal(raw);
  return NextResponse.json({ ok: true, handle, count: events.length, events });
}

type ParsedEvent = {
  uid: string;
  summary: string;
  description: string;
  startsAt: string | null;
  endsAt: string | null;
  location: string | null;
};

function parseICal(text: string): ParsedEvent[] {
  const events: ParsedEvent[] = [];
  let current: Partial<ParsedEvent> | null = null;
  const unfolded = text.replace(/\r?\n[ \t]/g, "");
  for (const line of unfolded.split(/\r?\n/)) {
    if (line === "BEGIN:VEVENT") current = {};
    else if (line === "END:VEVENT" && current) {
      events.push({
        uid: current.uid ?? crypto.randomUUID(),
        summary: current.summary ?? "(untitled)",
        description: current.description ?? "",
        startsAt: current.startsAt ?? null,
        endsAt: current.endsAt ?? null,
        location: current.location ?? null,
      });
      current = null;
    } else if (current) {
      const [keyRaw, ...valParts] = line.split(":");
      const key = keyRaw.split(";")[0];
      const val = valParts.join(":");
      switch (key) {
        case "UID": current.uid = val; break;
        case "SUMMARY": current.summary = unescapeICal(val); break;
        case "DESCRIPTION": current.description = unescapeICal(val); break;
        case "LOCATION": current.location = unescapeICal(val); break;
        case "DTSTART": current.startsAt = parseICalDate(val); break;
        case "DTEND": current.endsAt = parseICalDate(val); break;
      }
    }
  }
  return events;
}

function unescapeICal(s: string): string {
  return s.replace(/\\n/g, "\n").replace(/\\,/g, ",").replace(/\\;/g, ";").replace(/\\\\/g, "\\");
}

function parseICalDate(raw: string): string | null {
  const m = raw.match(/^(\d{4})(\d{2})(\d{2})(?:T(\d{2})(\d{2})(\d{2})(Z?))?/);
  if (!m) return null;
  const [, y, mo, d, h = "00", mi = "00", s = "00", z = ""] = m;
  return `${y}-${mo}-${d}T${h}:${mi}:${s}${z === "Z" ? "Z" : ""}`;
}
