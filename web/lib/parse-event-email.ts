/**
 * Heuristic event parser. Officers forward an email to events@buzz.app and we extract
 * a draft event from the subject + body. Pure regex pass first (fast, free); falls back
 * to an LLM extraction call when the regex pass produces low-confidence output.
 *
 * In production:
 *  - Mailgun/Postmark → POST /api/inbound-email with parsed email JSON
 *  - This function turns that into a `DraftEvent` row in Supabase
 *  - Officer reviews + publishes from the app or web
 */

export type DraftEvent = {
  title: string;
  summary: string;
  startsAt: Date | null;
  endsAt: Date | null;
  locationName: string | null;
  confidence: "high" | "medium" | "low";
};

const TIME_RE =
  /(\d{1,2})(?::(\d{2}))?\s*(am|pm|AM|PM)\s*(?:[-–to]+\s*(\d{1,2})(?::(\d{2}))?\s*(am|pm|AM|PM))?/;
const DATE_RE =
  /(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\.?\s+(\d{1,2})(?:[a-z]{0,2})?(?:,?\s+(\d{4}))?/i;
const LOCATION_RE = /(?:at|@|location:)\s+([^\n.]{3,80})/i;

const MONTHS: Record<string, number> = {
  jan: 0, feb: 1, mar: 2, apr: 3, may: 4, jun: 5,
  jul: 6, aug: 7, sep: 8, oct: 9, nov: 10, dec: 11,
};

export function parseEventEmail(subject: string, body: string): DraftEvent {
  const text = `${subject}\n${body}`;
  const dateMatch = text.match(DATE_RE);
  const timeMatch = text.match(TIME_RE);
  const locationMatch = text.match(LOCATION_RE);

  const now = new Date();
  let startsAt: Date | null = null;
  let endsAt: Date | null = null;

  if (dateMatch && timeMatch) {
    const month = MONTHS[dateMatch[1].slice(0, 3).toLowerCase()];
    const day = parseInt(dateMatch[2], 10);
    const year = dateMatch[3] ? parseInt(dateMatch[3], 10) : now.getFullYear();
    let hour = parseInt(timeMatch[1], 10);
    const minute = timeMatch[2] ? parseInt(timeMatch[2], 10) : 0;
    if (timeMatch[3]?.toLowerCase() === "pm" && hour < 12) hour += 12;
    if (timeMatch[3]?.toLowerCase() === "am" && hour === 12) hour = 0;
    startsAt = new Date(year, month, day, hour, minute);

    if (timeMatch[4]) {
      let endHour = parseInt(timeMatch[4], 10);
      const endMin = timeMatch[5] ? parseInt(timeMatch[5], 10) : 0;
      if (timeMatch[6]?.toLowerCase() === "pm" && endHour < 12) endHour += 12;
      if (timeMatch[6]?.toLowerCase() === "am" && endHour === 12) endHour = 0;
      endsAt = new Date(year, month, day, endHour, endMin);
    } else {
      endsAt = new Date(startsAt.getTime() + 2 * 3600 * 1000);
    }
  }

  const confidence: DraftEvent["confidence"] =
    startsAt && locationMatch ? "high" : startsAt || locationMatch ? "medium" : "low";

  return {
    title: subject.trim().slice(0, 120) || "(untitled event)",
    summary: body.split("\n").slice(0, 4).join(" ").trim().slice(0, 500),
    startsAt,
    endsAt,
    locationName: locationMatch?.[1]?.trim() ?? null,
    confidence,
  };
}
