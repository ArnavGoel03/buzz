import type { Metadata } from "next";
import { mockOrg } from "@/lib/supabase";

type Params = Promise<{ handle: string }>;

// Minimal page designed for iframe embedding on club websites:
//   <iframe src="https://buzz.app/embed/o/acm-ucsd" width="100%" height="600"
//           style="border:0;border-radius:16px"></iframe>
// Removes site chrome (header / footer), shows just upcoming events for the org,
// and routes clicks back to buzz.app/o/<handle> in a new tab.

export const metadata: Metadata = {
  robots: { index: false, follow: false },
};

export default async function EmbedOrg({ params }: { params: Params }) {
  const { handle } = await params;
  const org = mockOrg(handle);

  // Mock upcoming events. Real impl: query Supabase for events where organization_id
  // matches the org and status='published' and ends_at >= now().
  const upcoming = [
    { id: "1", title: "LeetCode Power Hour", when: "Tonight 7:00 PM", where: "CSE B250" },
    { id: "2", title: "Resume Review Workshop", when: "Thu 6:30 PM", where: "Library Walk" },
    { id: "3", title: "Hack Night ft. Vercel", when: "Fri 8:00 PM", where: "Atkinson Hall" },
  ];

  return (
    <div
      className="min-h-screen p-4"
      style={{ background: "transparent", color: "var(--color-text)" }}
    >
      <div className="flex items-center gap-3 pb-3 border-b border-[var(--color-border)]">
        <div
          className="w-10 h-10 rounded-full flex items-center justify-center font-black"
          style={{ background: org.accent_hex, color: "#000" }}
        >
          {org.name[0]}
        </div>
        <div className="flex-1">
          <div className="font-bold" style={{ fontFamily: "var(--font-display)" }}>
            {org.name}
          </div>
          <div className="text-xs text-[var(--color-text-tertiary)]">Upcoming on Buzz</div>
        </div>
        <a
          href={`https://buzz.app/o/${handle}`}
          target="_blank"
          rel="noopener noreferrer"
          className="text-xs font-semibold px-3 py-1 rounded-full bg-[var(--color-accent)] text-black"
        >
          Open
        </a>
      </div>

      <ul className="mt-3 space-y-2">
        {upcoming.map((e) => (
          <li key={e.id}>
            <a
              href={`https://buzz.app/e/${e.id}`}
              target="_blank"
              rel="noopener noreferrer"
              className="block p-3 rounded-xl bg-[var(--color-surface)] border border-[var(--color-border)] hover:border-[var(--color-accent)] transition-colors"
            >
              <div className="font-bold text-sm">{e.title}</div>
              <div className="text-xs text-[var(--color-text-secondary)] mt-1">
                {e.when} · {e.where}
              </div>
            </a>
          </li>
        ))}
      </ul>

      <div className="mt-4 text-center">
        <a
          href="https://buzz.app"
          target="_blank"
          rel="noopener noreferrer"
          className="text-xs text-[var(--color-text-tertiary)]"
        >
          Powered by Buzz
        </a>
      </div>
    </div>
  );
}
