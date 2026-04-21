"use client";

import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase-browser";

export default function SignOutButton() {
  const router = useRouter();
  async function handleSignOut() {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.push("/");
    router.refresh();
  }
  return (
    <button
      onClick={handleSignOut}
      className="w-full p-4 text-left text-sm font-semibold text-[var(--color-live)]"
    >
      Sign out
    </button>
  );
}
