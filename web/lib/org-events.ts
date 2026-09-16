import type { SupabaseClient } from "@supabase/supabase-js";
import type { Event } from "./types";

export const ORG_EVENT_PAGE_SIZE = 25;
type Cursor = { date: string; id: string };
export type OrgEventPage = { events: Event[]; next: string | null };

export function parseEventCursor(raw?: string): Cursor | null {
  if (!raw || raw.length > 512) return null;
  try {
    const value = JSON.parse(Buffer.from(raw, "base64url").toString("utf8"));
    if (typeof value.date !== "string" || typeof value.id !== "string" ||
        !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value.id) ||
        !/^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(?:\.[0-9]{1,6})?(?:Z|[+-][0-9]{2}:[0-9]{2})$/.test(value.date) || !Number.isFinite(Date.parse(value.date))) return null;
    const offset = value.date.match(/[+-]([0-9]{2}):([0-9]{2})$/);
    if (offset && (Number(offset[1]) > 14 || Number(offset[2]) > 59 || (Number(offset[1]) === 14 && Number(offset[2]) !== 0))) return null;
    const [year, month, day] = value.date.slice(0, 10).split("-").map(Number);
    const leap = year % 4 === 0 && (year % 100 !== 0 || year % 400 === 0);
    const days = [31, leap ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (year < 1 || month < 1 || month > 12 || day < 1 || day > days[month - 1]) return null;
    return { date: value.date, id: value.id };
  } catch { return null; }
}

export function eventPage(rows: Event[]): OrgEventPage {
  const events = rows.slice(0, ORG_EVENT_PAGE_SIZE);
  const last = events.at(-1);
  const next = rows.length > ORG_EVENT_PAGE_SIZE && last
    ? Buffer.from(JSON.stringify({ date: last.starts_at, id: last.id })).toString("base64url") : null;
  return { events, next };
}

export function mockOrgEventPage(rows: Event[], handle: string, raw?: string): OrgEventPage {
  const cursor = parseEventCursor(raw);
  return eventPage(rows.filter(row => row.host_handle === handle)
    .sort((a, b) => Date.parse(a.starts_at) - Date.parse(b.starts_at) || (a.id < b.id ? -1 : a.id > b.id ? 1 : 0))
    .filter(row => !cursor || Date.parse(row.starts_at) > Date.parse(cursor.date) ||
      (Date.parse(row.starts_at) === Date.parse(cursor.date) && row.id > cursor.id)));
}

export async function queryOrgEventPage(client: SupabaseClient, handle: string, raw?: string): Promise<OrgEventPage> {
  const cursor = parseEventCursor(raw);
  let query = client.from("events").select("*").eq("host_handle", handle)
    .order("starts_at", { ascending: true }).order("id", { ascending: true }).limit(ORG_EVENT_PAGE_SIZE + 1);
  // The validated timestamp and identifier cannot inject PostgREST filter syntax.
  if (cursor) query = query.or(`starts_at.gt.${cursor.date},and(starts_at.eq.${cursor.date},id.gt.${cursor.id})`);
  const { data, error } = await query;
  if (error) throw error;
  return eventPage((data ?? []) as Event[]);
}
