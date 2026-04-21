import { NextRequest } from "next/server";
import { ImageResponse } from "next/og";
import { mockEvents } from "@/lib/mock-data";

/**
 * Dynamic event poster — two formats via `?format=`:
 *   - `og` (default, 1200×630): used by <meta> OpenGraph/Twitter; shown in iMessage,
 *     Discord, Slack, and as a fallback when someone shares the event link.
 *   - `story` (1080×1920): downloadable Story-format for officers to post to
 *     Instagram / TikTok.
 *
 * Falls back to a generic "Buzz — event on campus" card if the ID doesn't match
 * anything, so shared links always render a branded card instead of 404ing.
 */
export const runtime = "edge";

const CATEGORY_PALETTES: Record<string, { from: string; via: string; to: string; label: string }> = {
  party:    { from: "#FFD60A", via: "#FF2D92", to: "#0a0a10", label: "PARTY" },
  free_food:{ from: "#FFD60A", via: "#34C759", to: "#0a0a10", label: "FREE FOOD" },
  greek:    { from: "#BF5AF2", via: "#6F4BE8", to: "#0a0a10", label: "GREEK" },
  sports:   { from: "#FF9500", via: "#FF4059", to: "#0a0a10", label: "SPORTS" },
  academic: { from: "#5AC8FA", via: "#0A84FF", to: "#0a0a10", label: "ACADEMIC" },
  career:   { from: "#0A84FF", via: "#5AC8FA", to: "#0a0a10", label: "CAREER" },
  club:     { from: "#FFD60A", via: "#FF9500", to: "#0a0a10", label: "CLUB" },
  other:    { from: "#FFD60A", via: "#FF2D92", to: "#0a0a10", label: "ON BUZZ" },
};

const DEFAULT_FALLBACK = {
  title: "An event on Buzz",
  summary: "Live discovery for college events.",
  location_name: "Your campus",
  starts_at: new Date().toISOString(),
  category: "other" as const,
};

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const { searchParams } = new URL(req.url);
  const format = searchParams.get("format") === "story" ? "story" : "og";

  // Resolve the event: real mock-data match, else graceful fallback
  const event =
    mockEvents.find((e) => e.id === id) ??
    { ...DEFAULT_FALLBACK, id };

  const palette = CATEGORY_PALETTES[event.category] ?? CATEGORY_PALETTES.other;
  const startLabel = new Date(event.starts_at).toLocaleDateString("en-US", {
    weekday: "short", month: "short", day: "numeric", hour: "numeric", minute: "2-digit",
  });

  const isStory = format === "story";
  const width = isStory ? 1080 : 1200;
  const height = isStory ? 1920 : 630;

  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          background: `linear-gradient(135deg, ${palette.from} 0%, ${palette.via} 45%, ${palette.to} 100%)`,
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          padding: isStory ? "120px 80px" : "64px 72px",
          color: "white",
          fontFamily: "system-ui, -apple-system",
        }}
      >
        {/* Grain layer */}
        <div
          style={{
            position: "absolute", inset: 0,
            background:
              "radial-gradient(circle at 22% 18%, rgba(255,255,255,0.14), transparent 40%)",
            display: "flex",
          }}
        />
        <div style={{ display: "flex", alignItems: "center", gap: 18 }}>
          <div
            style={{
              fontSize: isStory ? 28 : 22,
              fontWeight: 900,
              letterSpacing: 4,
              padding: "8px 16px",
              background: "rgba(0,0,0,0.35)",
              borderRadius: 999,
              display: "flex",
            }}
          >
            {palette.label}
          </div>
          <div style={{ fontSize: isStory ? 26 : 20, fontWeight: 700, opacity: 0.9, display: "flex" }}>
            on Buzz
          </div>
        </div>

        <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
          <div
            style={{
              fontSize: isStory ? 110 : 76,
              fontWeight: 900,
              lineHeight: 1.02,
              letterSpacing: -2,
              maxWidth: isStory ? 900 : 1000,
              textShadow: "0 4px 32px rgba(0,0,0,0.3)",
            }}
          >
            {event.title}
          </div>

          <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
            <Row icon="▸" text={startLabel} size={isStory ? 36 : 26} />
            <Row icon="◉" text={event.location_name} size={isStory ? 36 : 26} />
          </div>
        </div>
      </div>
    ),
    { width, height }
  );
}

function Row({ icon, text, size }: { icon: string; text: string; size: number }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 14, fontSize: size, fontWeight: 700, opacity: 0.96 }}>
      <span style={{ color: "#FFD60A" }}>{icon}</span>
      <span>{text}</span>
    </div>
  );
}
