import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase-server";
import { isAcademicEmail, resolveCampus } from "@/lib/campus-domains";

// POST /api/waitlist — capture email for campuses not yet live. Stores to
// `campus_waitlist` so we can prioritize launch order by demand.
export async function POST(req: Request) {
  try {
    const { email } = (await req.json()) as { email?: string };
    if (!email || !isAcademicEmail(email)) {
      return NextResponse.json({ error: "bad_email" }, { status: 400 });
    }
    const campus = resolveCampus(email);
    if (campus) {
      // They resolved to a real campus — they should have gotten a magic link
      // instead. Treat this as a no-op to avoid double-processing.
      return NextResponse.json({ ok: true, already_live: true });
    }

    const domain = email.split("@")[1]?.toLowerCase() ?? "";
    const supabase = await createClient();
    await supabase.from("campus_waitlist").insert({ email, domain });
    return NextResponse.json({ ok: true });
  } catch {
    // Soft-fail — we don't want the UI to panic over a waitlist log.
    return NextResponse.json({ ok: true });
  }
}
