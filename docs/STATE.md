# Poster glyph follow-up, 2026-09-18

The remaining poster dynamic-font HTTP400 is fixed with equivalent triangle
and ring SVG marks. Both actual PNG routes pass signature/dimension checks
(1200x630 and1080x1920), invalid IDs still return400, and both renders were
visually inspected with no runtime font errors. Native typecheck,11 existing
regressions and warning-free build pass. The request-only Playwright poster
regression needs no local browser and passes against production output.
Production remains paused; this does not claim live availability.

# Stack upgrade candidate, 2026-09-18

Next 16.3.5, Tailwind 4.3.3 and native TypeScript 7.0.2 are installed.
React stays on 19.2.8 because React Three Fiber excludes 19.3. The real
TypeScript 6 compatibility package remains for Next and test transpilation;
`pnpm run typecheck` explicitly invokes the native compiler. The Node test
transpiler now explicitly keeps its existing CommonJS interop convention.
The poster route uses Next's supported default Node runtime with unchanged
CDN caching. Native typecheck, all 11 regression tests and the final production
build pass without warnings. Public CI https://github.com/ArnavGoel03/buzz/actions/runs/35268929001
passed native typecheck, 11 tests, build and all four desktop/phone browser
cases at 94e1e7b. All eight screenshot artifacts were visually inspected: map
fixture activation/navigation, organization pagination and failure/retry layouts
remain intact. The screenshots are retained by that run for seven days. Local
HTTP checks also returned both poster PNG dimensions correctly, but existing
glyph font downloads logged HTTP 400; poster font coverage remains an explicit
limitation. Production release remains blocked by the paused host.

# Buzz web performance release, 2026-09-17

## Availability and regression reconciliation, 18 September 2026

https://buzzcampus.vercel.app/ still returns HTTP 503 `DEPLOYMENT_PAUSED`.
GitHub confirms run 35253752112 succeeded. Its repaired web source is unchanged
through current HEAD: organization failure/retry, pagination and lazy-map fixture
acceptance remain valid historical tests. They do not establish live tile delivery,
production Supabase RLS or native-device behavior; these remain open. No browser
suite rerun because neither its application source nor the fixture changed.
Repository visibility is public, verified with GitHub API.

The active web app is `web/`, connected from GitHub main to
https://buzzcampus.vercel.app. Native apps are separate release targets.
Production is currently unavailable: on 2026-09-17 Vercel reports the Buzz project
`paused: true`; the public organization URL returns HTTP 503 `DEPLOYMENT_PAUSED`.
The project API did not expose the reason; the shared team event later
identified the spend-management budget being reached. Do not mistake merged code
or a successful preview for a live release.

All map consumers share a near-viewport map gate with the original 360px container,
cleanup and no-IntersectionObserver fallback. Map CSS travels with the lazy
module. This includes map/detail routes so link prefetch cannot eagerly load
MapLibre through another consumer. Organization pages read 25 events plus one lookahead, ordered by exact
timestamp and UUID. Cursor validation preserves database microseconds and rejects
filter injection, malformed IDs and calendar rollover dates. The existing Events
label and numeric links provide navigation through the full chronological list.
Query errors propagate to the organization page boundary, which retains the
profile and shows the existing load-error and retry text. A failed page never
shows empty-list copy, partial events, or pagination. Retry reloads the same
cursor with dynamic rendering. The query includes past events, so its existing
Events heading remains accurate.

Organization failure repair merged in PR #2 at
`66846ab1f02b617c64090d1add09da705d9878c0`. The actual page tests first reproduced
both Supabase and transport exceptions against the original caller. Final
GitHub run [35253752112](https://github.com/ArnavGoel03/buzz/actions/runs/35253752112)
passed typecheck, all 11 Node tests, production build, and four desktop/phone
browser cases. These cover full pagination, deferred maps and marker navigation,
plus actual production HTTP 200 under a closed local database endpoint and
keyboard retry. Final desktop/phone screenshots were inspected. The new fallback
uses the existing secondary text color, with 7.17:1 contrast on its surface.

No web lint command is configured. Local Node 26 emits an existing
module.register deprecation; its build compiled in 22.6 seconds before reaching
the 30-second process budget during TypeScript. The full CI build passed on Node
24. Real Supabase query plans/RLS and native apps were not verified.

Production deployment `dpl_68DVtTvoc4iPdWUrzV2xpLG15BKM` is BLOCKED before build
because the project is paused. The source fix is verified and merged, not live.
Resume authorization/context and a successful production deployment remain open.
The checkout is main. Earlier native/product obligations remain in
SESSION_STATE.md; this repair does not close them.

Browser follow-up: the existing boba and lecture fixture pins overlap at the
default zoom. The performance smoke uses an unobscured marker; clustering or
changing pin selection is a separate product change and remains unimplemented.
