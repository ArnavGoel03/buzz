import { redirect } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase-server";

export const metadata = { title: "Your profile" };

/**
 * Authed: redirects to `/u/<handle>` looked up from the `profiles` table.
 * Previously used `user.email?.split("@")[0]` which collides across schools and
 * exposes the email local-part on a public URL. If no profile row exists yet,
 * route to onboarding.
 */
export default async function MyProfile() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return (
      <div className="max-w-md mx-auto px-4 py-16 text-center">
        <h1 className="text-2xl font-black" style={{ fontFamily: "var(--font-display)" }}>
          Sign in to see your profile
        </h1>
        <p className="mt-2 text-sm text-[var(--color-text-secondary)]">
          Track your streak, badges, and events attended.
        </p>
        <Link
          href="/sign-in"
          className="mt-6 inline-flex h-11 px-6 items-center rounded-xl bg-[var(--color-accent)] text-black font-bold"
        >
          Sign in
        </Link>
      </div>
    );
  }

  const { data: profile } = await supabase
    .from("profiles")
    .select("handle")
    .eq("id", user.id)
    .maybeSingle<{ handle: string | null }>();

  if (profile?.handle) {
    redirect(`/u/${profile.handle}`);
  }
  redirect("/onboarding");
}
