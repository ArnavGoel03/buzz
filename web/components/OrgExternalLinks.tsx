import { Globe2 } from "lucide-react";
import type { Organization } from "@/lib/types";

// Inlined Instagram glyph — lucide-react doesn't ship this icon at our version,
// and pulling in a brand-icon package for one SVG isn't worth the bundle cost.
function InstagramGlyph({ size = 14, color }: { size?: number; color?: string }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke={color ?? "currentColor"}
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      <rect x="2" y="2" width="20" height="20" rx="5" />
      <circle cx="12" cy="12" r="4" />
      <circle cx="17.5" cy="6.5" r="1" fill={color ?? "currentColor"} stroke="none" />
    </svg>
  );
}

// Sanitize + canonicalise an Instagram handle so a bad value can't become a phishing URL.
function instagramURL(raw: string | null | undefined): string | null {
  if (!raw) return null;
  const trimmed = raw.trim();
  const stripped = trimmed.startsWith("@") ? trimmed.slice(1) : trimmed;
  if (!stripped) return null;
  if (!/^[A-Za-z0-9._]+$/.test(stripped)) return null;
  return `https://instagram.com/${stripped}`;
}

// Only surface http(s) sites — no javascript:, data:, etc.
function safeWebsiteURL(raw: string | null | undefined): string | null {
  if (!raw) return null;
  try {
    const u = new URL(raw);
    return u.protocol === "https:" || u.protocol === "http:" ? u.toString() : null;
  } catch {
    return null;
  }
}

function shortHost(url: string): string {
  try {
    const host = new URL(url).host.toLowerCase();
    return host.startsWith("www.") ? host.slice(4) : host;
  } catch {
    return url;
  }
}

type Props = {
  org: Pick<Organization, "name" | "instagram_handle" | "website_url" | "accent_hex">;
};

export default function OrgExternalLinks({ org }: Props) {
  const ig = instagramURL(org.instagram_handle);
  const web = safeWebsiteURL(org.website_url);
  if (!ig && !web) return null;

  // The accent rim mirrors the iOS OrgExternalLinksRow pill — same visual language on both surfaces.
  const pillStyle = { borderColor: `${org.accent_hex}38` } as const;
  const handle = org.instagram_handle?.replace(/^@/, "") ?? "";

  return (
    <div className="mt-4 flex flex-wrap items-center gap-2">
      {ig && (
        <a
          href={ig}
          target="_blank"
          rel="noopener noreferrer nofollow external"
          className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-[var(--color-surface)] border hover:bg-[var(--color-surface-elevated)] transition-colors"
          style={pillStyle}
          aria-label={`Open Instagram profile for ${org.name}`}
        >
          <InstagramGlyph size={14} color={org.accent_hex} />
          <span className="flex flex-col leading-tight">
            <span className="text-xs font-semibold text-[var(--color-text-primary)]">@{handle}</span>
            <span className="text-[9px] font-mono tracking-wider text-[var(--color-text-tertiary)]">INSTAGRAM</span>
          </span>
        </a>
      )}
      {web && (
        <a
          href={web}
          target="_blank"
          rel="noopener noreferrer nofollow external"
          className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-[var(--color-surface)] border hover:bg-[var(--color-surface-elevated)] transition-colors"
          style={pillStyle}
          aria-label={`Open website for ${org.name}`}
        >
          <Globe2 size={14} style={{ color: org.accent_hex }} />
          <span className="flex flex-col leading-tight">
            <span className="text-xs font-semibold text-[var(--color-text-primary)]">{shortHost(web)}</span>
            <span className="text-[9px] font-mono tracking-wider text-[var(--color-text-tertiary)]">WEBSITE</span>
          </span>
        </a>
      )}
    </div>
  );
}
