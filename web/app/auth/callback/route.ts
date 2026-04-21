import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase-server";

// Magic-link handler. Supabase redirects here with `?code=...` — we exchange it
// for a session cookie, then bounce to /profile (or wherever the user was headed).
export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get("code");
  const next = searchParams.get("next") ?? "/profile";

  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error) return NextResponse.redirect(`${origin}${next}`);
  }
  return NextResponse.redirect(`${origin}/sign-in?error=callback`);
}
