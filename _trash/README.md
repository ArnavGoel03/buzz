# _trash

Holding area for files I (Claude) want to remove but haven't gotten explicit
approval to delete yet. Nothing here is referenced from the live codebase —
Next.js, Xcode, Android, and Tauri all ignore this folder.

## How to use

- **Approve a deletion**: `git rm -rf _trash/<path>` and commit. The file is
  finally gone, recoverable only via git history.
- **Revert a relocation**: `git mv _trash/<path> <original-path>` and commit.
  The file returns to its original location.
- **Audit**: `find _trash -type f` to see everything pending approval.

## Current contents

- `web/components/PWAInstaller.tsx` — PWA install prompt (no longer needed
  with native Android shipped).
- `web/lib/web-push.ts` — Web Push helper (PWA-only).
- `web/public/manifest.webmanifest` — PWA manifest.
- `web/public/offline.html` — PWA offline shell.
- `web/public/sw.js` — Service worker.

All five came from the "rip PWA" pass per the request "we don't need the
PWA mechanism anymore since web doesn't do most of the stuff anyway."
