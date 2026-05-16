import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

// Refreshes the Supabase auth session cookie on every request so server components
// always see an accurate `user`. Matches Supabase's Next.js App Router pattern.
export async function middleware(request: NextRequest) {
  let response = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL || "https://placeholder.supabase.co",
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "placeholder-anon-key",
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
          response = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options)
          );
        },
      },
    }
  );

  await supabase.auth.getUser();
  return response;
}

export const config = {
  // Skip the auth refresh on hot, public, signature-gated routes so each request
  // doesn't pay a Supabase `getUser()` cost (Web Audit #11). Cookie-gated routes
  // still match.
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|api/poster/|api/tickets/webhook|api/inbound-email|api/webhook-relay|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};
