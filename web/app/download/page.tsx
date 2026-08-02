import type { Metadata } from "next";
import DownloadPanel from "@/components/DownloadPanel";
import { getDesktopBuilds } from "@/lib/releases";
import { SITE, absoluteUrl } from "@/lib/site";

export const revalidate = 3600;

export const metadata: Metadata = {
  title: "Install Buzz",
  description: `${SITE.shortDescription} Installs to your home screen in two taps, no app store needed.`,
  alternates: { canonical: absoluteUrl("/download") },
  openGraph: {
    title: "Install Buzz",
    description: "Every college event on your campus, on your home screen in two taps.",
    url: absoluteUrl("/download"),
  },
};

export default async function Download() {
  const builds = await getDesktopBuilds();
  return <DownloadPanel builds={builds} />;
}
