# Buzz web performance release, 2026-09-17

The active web app is `web/`, deployed from GitHub main to
https://buzzcampus.vercel.app. Native apps are separate release targets.

Home/feed share a near-viewport map gate with the original 360px container,
cleanup and no-IntersectionObserver fallback. Map CSS travels with the lazy
module. Organization pages read 25 events plus one lookahead, ordered by exact
timestamp and UUID. Cursor validation preserves database microseconds and rejects
filter injection, malformed IDs and calendar rollover dates. The existing Events
label and numeric links provide navigation through the full chronological list.
Errors propagate instead of pretending the archive is empty.

Verified: typecheck, seven Node tests including 1,051 tied-date events and the
actual query adapter, production build, and a calibrated initial-resource check
that excludes map code/styles while preserving layout height. No lint command is
configured. Node 26 reports an existing module.register deprecation during build.
Rendered layout, map marker interaction, real Supabase query plans/RLS and native
apps were not verified. Local browser startup is blocked. The public GitHub runner is available;
a focused Playwright workflow is now verifying desktop/phone map deferral and
marker navigation with a deterministic Carto style fixture. Screenshots are
retained as run artifacts.

The portfolio performance IMPLEMENTATION.md records the exact GitHub merge and
live deployment receipt. Earlier native/product obligations remain in
SESSION_STATE.md; this release does not close them.
