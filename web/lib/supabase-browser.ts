"use client";

import { createBrowserClient } from "@supabase/ssr";

// Singleton Supabase client for the browser. Magic-link auth tokens land in cookies,
// persisted by the ssr helpers so SSR + client share the same session.
export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL || "https://placeholder.supabase.co",
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "placeholder-anon-key"
  );
}
