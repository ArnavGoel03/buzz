import { REPO } from "./site";

export type DesktopBuild = {
  label: string;
  url: string;
  version: string;
  size: string;
};

/**
 * Desktop installers are read from the GitHub release rather than hardcoded, so a
 * button can never point at a file that was never uploaded. Today the latest release
 * has no assets, which means this returns an empty list and /download renders no
 * desktop section at all. Publish a .dmg and it appears on the next revalidate.
 */
const PATTERNS: { match: RegExp; label: string }[] = [
  { match: /\.dmg$/i, label: "macOS" },
  { match: /\.(msi|exe)$/i, label: "Windows" },
  { match: /\.(AppImage|deb)$/i, label: "Linux" },
];

type GitHubAsset = { name: string; browser_download_url: string; size: number };
type GitHubRelease = { tag_name?: string; assets?: GitHubAsset[] };

function humanSize(bytes: number): string {
  const mb = bytes / 1024 / 1024;
  return mb >= 1 ? `${mb.toFixed(1)} MB` : `${Math.max(1, Math.round(bytes / 1024))} KB`;
}

export async function getDesktopBuilds(): Promise<DesktopBuild[]> {
  try {
    const res = await fetch(REPO.apiLatestRelease, {
      headers: { accept: "application/vnd.github+json" },
      // Hourly is plenty for a release feed, and it keeps the page static between checks.
      next: { revalidate: 3600 },
    });
    if (!res.ok) return [];

    const release = (await res.json()) as GitHubRelease;
    const version = release.tag_name ?? "latest";

    return (release.assets ?? []).flatMap((asset) => {
      const hit = PATTERNS.find((p) => p.match.test(asset.name));
      if (!hit) return [];
      return [
        {
          label: hit.label,
          url: asset.browser_download_url,
          version,
          size: humanSize(asset.size),
        },
      ];
    });
  } catch {
    // A GitHub outage must not take the install page down with it.
    return [];
  }
}
