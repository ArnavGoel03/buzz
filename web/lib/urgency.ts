// Mirror of iOS `EventUrgency` on Event.swift. Keep buckets aligned across surfaces
// so a card that reads "LIVE" on iOS also reads "LIVE" on web at the same moment.

export type EventUrgency = "live" | "starting" | "soon" | "upcoming" | "past";

export function eventUrgency(startsAt: string, endsAt?: string | null, isLive?: boolean): EventUrgency {
  const start = new Date(startsAt).getTime();
  const end = endsAt ? new Date(endsAt).getTime() : start + 2 * 3600 * 1000;
  const now = Date.now();
  if (now > end) return "past";
  if (isLive || now >= start) return "live";
  const delta = (start - now) / 1000;
  if (delta <= 30 * 60) return "starting";
  if (delta <= 24 * 3600) return "soon";
  return "upcoming";
}

export function urgencyColor(u: EventUrgency): string {
  switch (u) {
    case "live":     return "rgb(255,69,51)";
    case "starting": return "rgb(255,149,0)";
    case "soon":     return "rgb(48,209,88)";
    case "upcoming": return "rgba(255,255,255,0.12)";
    case "past":     return "rgba(255,255,255,0.06)";
  }
}
