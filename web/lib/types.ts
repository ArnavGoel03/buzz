export type EventCategory =
  | "party"
  | "free_food"
  | "club"
  | "sports"
  | "academic"
  | "greek"
  | "career"
  | "other";

export type Event = {
  id: string;
  title: string;
  summary: string;
  starts_at: string;
  ends_at?: string | null;
  location_name: string;
  latitude?: number | null;
  longitude?: number | null;
  host_name: string;
  host_handle?: string | null;
  category: EventCategory;
  is_live?: boolean;
  attendee_count?: number;
  cover_url?: string | null;
  tags?: string[];
};

export type Organization = {
  id: string;
  handle: string;
  name: string;
  tagline: string;
  description: string;
  member_count: number;
  accent_hex: string;
  category?: string;
  campus?: string;
  verified?: boolean;
  logo_url?: string | null;
};

export type Profile = {
  id: string;
  handle: string;
  display_name: string;
  bio?: string | null;
  avatar_url?: string | null;
  campus?: string | null;
  graduating_year?: number | null;
  streak?: number;
  events_attended?: number;
};

export type Campus = {
  id: string;
  name: string;
  slug: string;
  city: string;
  country: string;
  center_lat: number;
  center_lng: number;
  accent_hex?: string;
};
