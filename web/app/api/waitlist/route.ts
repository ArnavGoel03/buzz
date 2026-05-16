import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase-server";
import { isAcademicEmail, resolveCampus } from "@/lib/campus-domains";

// In-memory IP rate limiter — module-level so it survives across requests in the
// same Vercel function instance. Not perfect across cold starts / regions, but
// blocks the basic flooding case until an Upstash/KV layer is wired.
const HITS = new Map<string, { count: number; resetAt: number }>();
const WINDOW_MS = 60_000;
const MAX_PER_WINDOW = 5;

function ipFrom(req: Request): string {
  return req.headers.get("x-forwarded-for")?.split(",")[0]?.trim()
      ?? req.headers.get("x-real-ip")
      ?? "unknown";
}

function rateLimited(ip: string): boolean {
  const now = Date.now();
  const slot = HITS.get(ip);
  if (!slot || slot.resetAt < now) {
    HITS.set(ip, { count: 1, resetAt: now + WINDOW_MS });
    return false;
  }
  slot.count += 1;
  return slot.count > MAX_PER_WINDOW;
}

/**
 * POST /api/waitlist — capture email for campuses not yet live.
 *
 * Rate-limited (5/min per IP). Uses `on conflict do nothing` so the response shape
 * doesn't leak whether an email was already in the list (would otherwise be an
 * enumeration oracle for targeted phishing).
 */
export async function POST(req: Request) {
  if (rateLimited(ipFrom(req))) {
    return NextResponse.json({ ok: false, error: "rate_limited" }, { status: 429 });
  }
  try {
    const { email } = (await req.json()) as { email?: string };
    if (!email || !isAcademicEmail(email)) {
      return NextResponse.json({ error: "bad_email" }, { status: 400 });
    }
    const campus = resolveCampus(email);
    if (campus) {
      return NextResponse.json({ ok: true, already_live: true });
    }

    const domain = email.split("@")[1]?.toLowerCase() ?? "";
    const supabase = await createClient();
    // upsert with ignoreDuplicates so the response is identical whether or not the
    // row existed — closes the existence-oracle gap.
    await supabase.from("campus_waitlist").upsert(
      { email, domain },
      { onConflict: "email", ignoreDuplicates: true }
    );
    return NextResponse.json({ ok: true });
  } catch {
    return NextResponse.json({ ok: true });
  }
}
