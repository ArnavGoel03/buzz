import { NextRequest } from "next/server";
import { ImageResponse } from "next/og";
import { mockEvents } from "@/lib/mock-data";
import { CATEGORIES, categoryColor, categoryLabel, type EventCategory } from "@/lib/categories";
import { COLOR } from "@/lib/tokens";
import { SITE } from "@/lib/site";

/**
 * Dynamic event poster. Two formats via `?format=`:
 *   - `og` (default, 1200×630): used by <meta> OpenGraph/Twitter; rendered by iMessage,
 *     Discord, Slack, Google's event card, etc.
 *   - `story` (1080×1920): downloadable Story format for officers.
 *
 * Falls back to a generic branded card on miss so every share preview stays branded.
 * Returns long Cache-Control because the underlying event title rarely changes after
 * publish; cache busts naturally on a new deploy because the URL includes the BUILD_ID.
 */

// Accept event UUIDs (e.g. `8c4d…`) plus handle-style fallbacks (a-z/0-9/_- up to 64).
// Bounds the attack surface so we don't render a poster for arbitrary ID shapes.
const ID_RE = /^[a-zA-Z0-9_-]{1,64}$/;

/**
 * Poster gradients are computed, not written down: brand accent on one end, the
 * category hue in the middle, page background at the far end. Adding a category to
 * lib/categories.ts gives it a poster for free.
 */
function palette(cat: string) {
  const key = (cat in CATEGORIES ? cat : "other") as EventCategory;
  return {
    from: COLOR.accent,
    via: categoryColor(key).color,
    to: COLOR.background,
    label: key === "other" ? `ON ${SITE.name.toUpperCase()}` : categoryLabel(key).toUpperCase(),
  };
}

const DEFAULT_FALLBACK = {
  title: `An event on ${SITE.name}`,
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
  if (!ID_RE.test(id)) {
    return new Response("invalid_id", { status: 400 });
  }

  const { searchParams } = new URL(req.url);
  const format = searchParams.get("format") === "story" ? "story" : "og";

  const event = mockEvents.find((e) => e.id === id) ?? { ...DEFAULT_FALLBACK, id };

  const theme = palette(event.category);
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
          background: `linear-gradient(135deg, ${theme.from} 0%, ${theme.via} 45%, ${theme.to} 100%)`,
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          padding: isStory ? "120px 80px" : "64px 72px",
          color: COLOR.textPrimary,
          fontFamily: "system-ui, -apple-system",
        }}
      >
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
              fontSize: isStory ? 28 : 22, fontWeight: 900, letterSpacing: 4,
              padding: "8px 16px", background: "rgba(0,0,0,0.35)",
              borderRadius: 999, display: "flex",
            }}
          >
            {theme.label}
          </div>
          <div style={{ fontSize: isStory ? 26 : 20, fontWeight: 700, opacity: 0.9, display: "flex" }}>
            on {SITE.name}
          </div>
        </div>

        <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
          <div
            style={{
              fontSize: isStory ? 110 : 76, fontWeight: 900, lineHeight: 1.02,
              letterSpacing: -2, maxWidth: isStory ? 900 : 1000,
              textShadow: "0 4px 32px rgba(0,0,0,0.3)",
            }}
          >
            {event.title}
          </div>

          <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
            <Row icon="time" text={startLabel} size={isStory ? 36 : 26} />
            <Row icon="location" text={event.location_name} size={isStory ? 36 : 26} />
          </div>
        </div>
      </div>
    ),
    {
      width, height,
      headers: {
        // Edge CDN holds the rendered card for 1h, serves stale for up to 1d while
        // refreshing. Cuts re-render cost on viral share links to ~0.
        "Cache-Control": "public, s-maxage=3600, stale-while-revalidate=86400",
      },
    }
  );
}

function Row({ icon, text, size }: { icon: "time" | "location"; text: string; size: number }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 14, fontSize: size, fontWeight: 700, opacity: 0.96 }}>
      <svg width={size} height={size} viewBox="0 0 24 24" fill={COLOR.accent}>
        {icon === "time" ? (
          <path d="M7 4 19 12 7 20Z" />
        ) : (
          <g>
            <circle cx="12" cy="12" r="9" fill="none" stroke={COLOR.accent} strokeWidth="2" />
            <circle cx="12" cy="12" r="5" />
          </g>
        )}
      </svg>
      <span>{text}</span>
    </div>
  );
}
