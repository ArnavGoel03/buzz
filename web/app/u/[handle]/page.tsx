import type { Metadata } from "next";

type Params = Promise<{ handle: string }>;

export async function generateMetadata({ params }: { params: Params }): Promise<Metadata> {
  const { handle } = await params;
  return {
    title: `@${handle} · Buzz`,
    description: `${handle}'s profile on Buzz`,
    openGraph: {
      title: `@${handle}`,
      description: "On Buzz",
      type: "profile",
      url: `https://buzz.app/u/${handle}`,
    },
  };
}

export default async function ProfilePreview({ params }: { params: Params }) {
  const { handle } = await params;
  return (
    <main className="min-h-screen px-6 py-16 max-w-2xl mx-auto text-center">
      <div className="w-24 h-24 mx-auto rounded-full bg-[var(--color-accent)] flex items-center justify-center text-4xl font-black text-black">
        {handle[0]?.toUpperCase()}
      </div>
      <h1
        className="mt-6 text-3xl font-black"
        style={{ fontFamily: "var(--font-display)" }}
      >
        @{handle}
      </h1>
      <p className="mt-2 text-[var(--color-text-secondary)]">
        Profile previews are private by default. Open in the app to see badges and
        affiliations the user chose to share.
      </p>
      <a
        href={`buzz://u/${handle}`}
        className="mt-10 inline-block px-6 py-4 rounded-2xl bg-[var(--color-accent)] text-black font-bold"
      >
        Open in Buzz
      </a>
    </main>
  );
}
