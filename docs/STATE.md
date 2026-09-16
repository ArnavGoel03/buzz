# Buzz web performance release, 2026-09-17

The active web app is `web/`, deployed from GitHub main to
https://buzzcampus.vercel.app. Native apps are separate release targets.

All map consumers share a near-viewport map gate with the original 360px container,
cleanup and no-IntersectionObserver fallback. Map CSS travels with the lazy
module. This includes map/detail routes so link prefetch cannot eagerly load
MapLibre through another consumer. Organization pages read 25 events plus one lookahead, ordered by exact
timestamp and UUID. Cursor validation preserves database microseconds and rejects
filter injection, malformed IDs and calendar rollover dates. The existing Events
label and numeric links provide navigation through the full chronological list.
Errors propagate instead of pretending the archive is empty.

Verified: typecheck, seven Node tests including 1,051 tied-date events and the
actual query adapter, production build, and a calibrated initial-resource check
that excludes map code/styles while preserving layout height. No lint command is
configured. Node 26 reports an existing module.register deprecation during build.
GitHub browser run 35163988412 passed desktop (1440x700) and phone (390x844)
map deferral, activation, reserved height and marker navigation. Map and event-list
screenshots were inspected; organization headers were captured mid-animation,
so this does not certify that animation. The Carto style was a deterministic
fixture. Real tiles, production Supabase query plans/RLS and native apps remain
unverified. Local browser startup is blocked; public GitHub runners work.
PR #1 merged as 5ac9b5b; the portfolio queue owns live deployment readback.

The portfolio performance IMPLEMENTATION.md records the exact GitHub merge and
live deployment receipt. Earlier native/product obligations remain in
SESSION_STATE.md; this release does not close them.

Browser follow-up: the existing boba and lecture fixture pins overlap at the
default zoom. The performance smoke uses an unobscured marker; clustering or
changing pin selection is a separate product change and remains unimplemented.
