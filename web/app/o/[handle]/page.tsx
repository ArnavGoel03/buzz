import type { Metadata } from "next";
import { mockOrg } from "@/lib/supabase";

type Params = Promise<{ handle: string }>;

export async function generateMetadata({ params }: { params: Params }): Promise<Metadata> {
  const { handle } = await params;
  const org = mockOrg(handle);
  return {
    title: `${org.name} · Buzz`,
    description: org.tagline,
    openGraph: {
      title: org.name,
      description: org.tagline,
      type: "profile",
      siteName: "Buzz",
      url: `https://buzz.app/o/${handle}`,
    },
  };
}

export default async function OrgPreview({ params }: { params: Params }) {
  const { handle } = await params;
  const org = mockOrg(handle);
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "Organization",
    name: org.name,
    description: org.tagline,
    url: `https://buzz.app/o/${handle}`,
  };
  return (
    <main className="min-h-screen">
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />
      <div
        className="h-40"
        style={{ background: `linear-gradient(135deg, ${org.accent_hex}55, transparent 70%)` }}
      />
      <div className="px-6 -mt-12 max-w-2xl mx-auto">
        <div
          className="w-24 h-24 rounded-full flex items-center justify-center text-4xl font-black border-4 border-black"
          style={{ background: org.accent_hex, color: "#000" }}
        >
          {org.name[0]}
        </div>
        <h1
          className="mt-4 text-3xl font-black tracking-tight"
          style={{ fontFamily: "var(--font-display)" }}
        >
          {org.name}
        </h1>
        <p className="text-[var(--color-text-secondary)]">{org.tagline}</p>
        <p className="mt-6 text-sm">{org.description}</p>
        <a
          href={`buzz://o/${handle}`}
          className="mt-10 block text-center px-6 py-4 rounded-2xl bg-[var(--color-accent)] text-black font-bold"
        >
          Follow on Buzz
        </a>
      </div>
    </main>
  );
}
