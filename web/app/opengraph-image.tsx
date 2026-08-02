import { ImageResponse } from "next/og";
import { COLOR } from "@/lib/tokens";
import { SITE, SITE_URL } from "@/lib/site";

/**
 * The card every link to the site root renders as: iMessage, Discord, Slack, WhatsApp,
 * LinkedIn, Google. Colours come from design/tokens.json and copy from lib/site.ts, so
 * a rebrand never leaves a stale preview image behind.
 *
 * Per-event links get a richer card from /api/poster/[id] instead.
 */
export const alt = `${SITE.name}: ${SITE.tagline}`;
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export default async function Image() {
  const host = SITE_URL.replace(/^https?:\/\//, "");

  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          padding: "72px 80px",
          background: COLOR.background,
          color: COLOR.textPrimary,
          fontFamily: "system-ui, -apple-system",
        }}
      >
        {/* Accent bloom, top left, same gesture as the app's hero. */}
        <div
          style={{
            position: "absolute",
            inset: 0,
            display: "flex",
            background: `radial-gradient(circle at 12% 0%, ${COLOR.accentDim}, transparent 55%)`,
          }}
        />

        <div style={{ display: "flex", alignItems: "center", gap: 20 }}>
          <div
            style={{
              width: 76,
              height: 76,
              borderRadius: 22,
              background: COLOR.accent,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
            }}
          >
            <svg width="42" height="42" viewBox="0 0 24 24" fill={COLOR.accentInk}>
              <path d="M13.5 2 4 13.2h6.1L9.4 22 20 10.4h-6.4L13.5 2Z" />
            </svg>
          </div>
          <div style={{ fontSize: 52, fontWeight: 900, letterSpacing: -1 }}>{SITE.name}</div>
        </div>

        <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
          <div
            style={{
              fontSize: 86,
              fontWeight: 900,
              lineHeight: 1.02,
              letterSpacing: -3,
              maxWidth: 940,
            }}
          >
            {SITE.shortDescription}
          </div>
          <div style={{ fontSize: 30, fontWeight: 600, color: COLOR.textSecondary, display: "flex" }}>
            Free, and it installs from the browser. No app store.
          </div>
        </div>

        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 14,
            fontSize: 26,
            fontWeight: 700,
            color: COLOR.accent,
          }}
        >
          <span>{host}</span>
        </div>
      </div>
    ),
    size
  );
}
