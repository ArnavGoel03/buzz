import { createClient } from "./supabase-server";
import { mockCampus, mockEvents, mockOrgs, mockProfile } from "./mock-data";
import type { Event, Organization, Profile, Campus } from "./types";

// Thin data layer. When Supabase env is configured and tables exist, these hit the
// real Postgres. Otherwise they fall back to the mock fixtures so the site always
// renders — useful for previews, demos, and this-weekend builds.

function hasRealSupabase(): boolean {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL || "";
  return url.startsWith("https://") && !url.includes("placeholder");
}

export async function getFeedEvents(): Promise<Event[]> {
  if (!hasRealSupabase()) return mockEvents;
  try {
    const supabase = await createClient();
    const { data, error } = await supabase
      .from("events")
      .select("*")
      .gte("starts_at", new Date(Date.now() - 3600_000).toISOString())
      .order("starts_at", { ascending: true })
      .limit(50);
    if (error || !data?.length) return mockEvents;
    return data as Event[];
  } catch {
    return mockEvents;
  }
}

export async function getEvent(id: string): Promise<Event | null> {
  if (!hasRealSupabase()) {
    return mockEvents.find((e) => e.id === id) ?? mockEvents[0];
  }
  try {
    const supabase = await createClient();
    const { data } = await supabase.from("events").select("*").eq("id", id).single();
    return (data as Event) ?? mockEvents.find((e) => e.id === id) ?? null;
  } catch {
    return mockEvents.find((e) => e.id === id) ?? null;
  }
}

export async function getOrg(handle: string): Promise<Organization | null> {
  if (!hasRealSupabase()) {
    return mockOrgs.find((o) => o.handle === handle) ?? mockOrgs[0];
  }
  try {
    const supabase = await createClient();
    const { data } = await supabase.from("organizations").select("*").eq("handle", handle).single();
    return (data as Organization) ?? mockOrgs.find((o) => o.handle === handle) ?? null;
  } catch {
    return mockOrgs.find((o) => o.handle === handle) ?? null;
  }
}

export async function getOrgs(): Promise<Organization[]> {
  if (!hasRealSupabase()) return mockOrgs;
  try {
    const supabase = await createClient();
    const { data } = await supabase.from("organizations").select("*").limit(100);
    return (data as Organization[]) ?? mockOrgs;
  } catch {
    return mockOrgs;
  }
}

export async function getEventsByOrg(handle: string): Promise<Event[]> {
  if (!hasRealSupabase()) {
    return mockEvents.filter((e) => e.host_handle === handle);
  }
  try {
    const supabase = await createClient();
    const { data } = await supabase
      .from("events")
      .select("*")
      .eq("host_handle", handle)
      .order("starts_at", { ascending: true });
    return (data as Event[]) ?? [];
  } catch {
    return [];
  }
}

export async function getActiveCampus(): Promise<Campus> {
  return mockCampus;
}

export async function getCurrentProfile(): Promise<Profile | null> {
  if (!hasRealSupabase()) return null;
  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (!user) return null;
    const { data } = await supabase.from("profiles").select("*").eq("id", user.id).single();
    return (data as Profile) ?? mockProfile;
  } catch {
    return null;
  }
}
