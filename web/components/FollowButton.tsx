"use client";

import { useState } from "react";
import { Check, Plus } from "lucide-react";
import { createClient } from "@/lib/supabase-browser";

export default function FollowButton({ handle }: { handle: string }) {
  const [following, setFollowing] = useState(false);
  const [loading, setLoading] = useState(false);

  async function toggle() {
    setLoading(true);
    const next = !following;
    setFollowing(next);
    try {
      const supabase = createClient();
      const { data: { user } } = await supabase.auth.getUser();
      if (user) {
        if (next) {
          await supabase.from("follows").upsert({ user_id: user.id, org_handle: handle });
        } else {
          await supabase.from("follows").delete().match({ user_id: user.id, org_handle: handle });
        }
      }
    } catch {
      setFollowing(!next);
    } finally {
      setLoading(false);
    }
  }

  return (
    <button
      onClick={toggle}
      disabled={loading}
      className={`h-11 px-6 flex items-center gap-2 rounded-xl font-bold text-sm transition-colors ${
        following
          ? "bg-[var(--color-surface)] border border-[var(--color-border-strong)] text-white"
          : "bg-[var(--color-accent)] text-black hover:brightness-110"
      }`}
    >
      {following ? <Check size={16} /> : <Plus size={16} />}
      {following ? "Following" : "Follow"}
    </button>
  );
}
