import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase-server";
import { resolveCampus } from "@/lib/campus-domains";

// Magic-link handler. After exchanging the code for a session, we attach the
// user's verified campus (derived from their school email domain) to their
// profile row. First-time users get a profile created with `verified: true`.
export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get("code");
  const next = searchParams.get("next") ?? "/profile";

  if (!code) {
    return NextResponse.redirect(`${origin}/sign-in?error=no_code`);
  }

  const supabase = await createClient();
  const { data, error } = await supabase.auth.exchangeCodeForSession(code);
  if (error || !data.user) {
    return NextResponse.redirect(`${origin}/sign-in?error=exchange_failed`);
  }

  const email = data.user.email ?? "";
  const campus = resolveCampus(email);
  if (campus) {
    try {
      await supabase
        .from("profiles")
        .upsert(
          {
            id: data.user.id,
            email,
            campus: campus.campusId,
            verified: true,
          },
          { onConflict: "id" }
        );
      await supabase.from("campus_affiliations").upsert(
        {
          profile_id: data.user.id,
          campus: campus.campusId,
          status: "active",
          verified_via: "school_email",
          verified_at: new Date().toISOString(),
        },
        { onConflict: "profile_id,campus" }
      );
    } catch {
      // Profile stamping is best-effort — don't block sign-in on write failure.
    }
  }
  return NextResponse.redirect(`${origin}${next}`);
}
