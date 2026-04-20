import { NextRequest, NextResponse } from "next/server";

/**
 * Imports events from a public iCal feed URL (Google Calendar's "secret address in iCal
 * format" works). Officer pastes the URL once → all upcoming events become drafts in
 * the org's queue.
 *
 *   POST /api/calendar-import
 *   { handle: "acm-ucsd", icalURL: "https://calendar.google.com/.../basic.ics" }
 */
export async function POST(req: NextRequest) {
  const { handle, icalURL } = await req.json().catch(() => ({}));
  if (!handle || !icalURL) {
    return NextResponse.json({ ok: false, error: "missing_params" }, { status: 400 });
  }

  let raw: string;
  try {
    const r = await fetch(icalURL, { headers: { "User-Agent": "BuzzImporter/1.0" } });
    if (!r.ok) throw new Error(`upstream ${r.status}`);
    raw = await r.text();
  } catch (e) {
    return NextResponse.json({ ok: false, error: "fetch_failed", detail: String(e) }, { status: 502 });
  }

  const events = parseICal(raw);
  // Real impl: insert each as event_drafts row for the org. Mock returns the parsed list.
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

/** Minimal iCalendar (RFC 5545) parser — handles the common subset Google Calendar emits. */
function parseICal(text: string): ParsedEvent[] {
  const events: ParsedEvent[] = [];
  let current: Partial<ParsedEvent> | null = null;
  // Unfold continuation lines (RFC 5545 § 3.1)
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
      const key = keyRaw.split(";")[0]; // strip params like ;TZID=…
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
  // Examples: 20260420T193000Z, 20260420, 20260420T193000
  const m = raw.match(/^(\d{4})(\d{2})(\d{2})(?:T(\d{2})(\d{2})(\d{2})(Z?))?/);
  if (!m) return null;
  const [, y, mo, d, h = "00", mi = "00", s = "00", z = ""] = m;
  return `${y}-${mo}-${d}T${h}:${mi}:${s}${z === "Z" ? "Z" : ""}`;
}
