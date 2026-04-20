import { NextRequest } from "next/server";
import { ImageResponse } from "next/og";
import { mockEvent } from "@/lib/supabase";

/**
 * Generates a 1080×1920 Story-format poster for an event. Officer hits the URL,
 * gets a JPEG suitable for Instagram Stories / TikTok / WhatsApp Status.
 *
 *   GET /api/poster/<event-id>
 *
 * Uses Vercel's @vercel/og (re-exported as next/og) for edge-rendered SVG → PNG.
 */
export const runtime = "edge";

export async function GET(
  _req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const event = mockEvent(id);

  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          background: "linear-gradient(135deg, #FFD60A 0%, #FF2D92 50%, #000 100%)",
          display: "flex",
          flexDirection: "column",
          padding: "120px 80px",
          color: "white",
          fontFamily: "system-ui, -apple-system",
        }}
      >
        <div style={{ fontSize: 24, fontWeight: 800, letterSpacing: 4, opacity: 0.85 }}>
          ON BUZZ
        </div>
        <div style={{ flex: 1, display: "flex", alignItems: "center" }}>
          <div style={{ fontSize: 110, fontWeight: 900, lineHeight: 1.05 }}>
            {event.title}
          </div>
        </div>
        <div style={{ display: "flex", flexDirection: "column", gap: 18 }}>
          <Row icon="📅" text={new Date(event.starts_at).toLocaleString()} />
          <Row icon="📍" text={event.location_name} />
          <Row icon="✨" text="Scan to RSVP" />
        </div>
      </div>
    ),
    { width: 1080, height: 1920 }
  );
}

function Row({ icon, text }: { icon: string; text: string }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 16, fontSize: 36, fontWeight: 700 }}>
      <span>{icon}</span>
      <span>{text}</span>
    </div>
  );
}
