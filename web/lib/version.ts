// GENERATED from /VERSION — do not edit by hand.
// Run `node scripts/sync-version.mjs` after editing /VERSION.
export const VERSION = "1.0.0";
export const BUILD_ID =
  process.env.NEXT_PUBLIC_BUILD_ID ??
  process.env.VERCEL_GIT_COMMIT_SHA?.slice(0, 7) ??
  "dev";
