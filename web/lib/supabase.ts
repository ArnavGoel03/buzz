import { createClient } from "@supabase/supabase-js";

// Public anon key — safe to ship in the browser. Real protection lives in Supabase RLS,
// not in keeping this string secret. Placeholder values let the site build without
// backend env vars wired up yet; mock data kicks in at runtime when the URL is fake.
const url = process.env.NEXT_PUBLIC_SUPABASE_URL || "https://placeholder.supabase.co";
const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "placeholder-anon-key";

export const supabase = createClient(url, anonKey, {
  auth: { persistSession: false },
});

// ── Mock fallback so the site renders previews without a backend ────────────
export type MockEvent = {
  id: string;
  title: string;
  summary: string;
  starts_at: string;
  location_name: string;
  host_name: string;
  category: string;
};

export type MockOrg = {
  id: string;
  handle: string;
  name: string;
  tagline: string;
  description: string;
  member_count: number;
  accent_hex: string;
};

export const mockEvent = (id: string): MockEvent => ({
  id,
  title: "Warren Quad Takeover",
  summary: "DJ set, food trucks, glow sticks. Outdoor. 18+.",
  starts_at: new Date(Date.now() + 3 * 3600 * 1000).toISOString(),
  location_name: "Warren Quad, UCSD",
  host_name: "Warren College Council",
  category: "party",
});

export const mockOrg = (handle: string): MockOrg => ({
  id: "00000000-0000-0000-0000-000000000000",
  handle,
  name: handle.toUpperCase().replace(/-/g, " "),
  tagline: "On Buzz.",
  description: "A college organization. Get the Buzz app to see members and events.",
  member_count: 0,
  accent_hex: "#FFD60A",
});
