# Map acceptance qualification, 18 September 2026

The failed phone map assertion in run35272624001 was traced to the /feed map
still inside React's hidden streaming container DIV#S:0 when the harness
measured boundingBox. The map subsequently activated and navigated successfully
in that same run. PR #5 waits for visible committed layout instead of attachment.
Its below-fold distance, no-early-request, 360px height, activation and marker
navigation assertions are unchanged. No application code changed.

Hosted run [35285961597](https://github.com/ArnavGoel03/buzz/actions/runs/35285961597)
passed at `298f01559a062f273706c7fc60ca376f6a625f48`: native TypeScript 7,
all 11 Node regressions, production build and all five browser cases. All eight
desktop/phone captures and both poster PNGs were visually inspected. Artifact
`10522954922` retains those captures for seven days. The build has no compiler
warnings; fresh-run cache and existing artifact-action Node deprecation notices
remain CI infrastructure notices. No lint command is configured.

Fresh provider readback still identifies canonical https://buzzcampus.vercel.app/
as READY deployment `dpl_HwMjwW2sEP3np1cYERQVAADgfLNK`, source
`5ac9b5b01fb55816722b538b2cdd93078e706ceb`. The project is not paused. Homepage,
/feed and /o/acm-ucsd return HTTP 200 with Buzz HTML; both poster formats return
valid PNGs at 1200x630 and 1080x1920, and invalid poster ID returns 400. These
checks prove the old production is available, not that the upgrade is live.

Deployment remains held: the shared Vercel team returned HTTP 402
`api-deployments-free-per-day` for Portfolio and Watch, total 100, remaining 0,
with reset September 19 around 04:42 IST. No redundant Buzz deployment POST,
budget change or paid resource was attempted. After reset, requeue the exact
verified GitHub source and verify canonical alias/source plus production HTTP.
Real map tile delivery, production Supabase RLS and native-device acceptance
remain separate pre-existing obligations. The matching successful run above
closes the earlier harness failure; historical receipts below do not override
this current qualification and release boundary.

# Current production restoration, 18 September 2026

At 2026-09-17T21:01:24 UTC, provider readback confirmed `paused: false`
and READY production deployment `dpl_HwMjwW2sEP3np1cYERQVAADgfLNK` at source
`5ac9b5b01fb55816722b538b2cdd93078e706ceb`. Canonical https://buzzcampus.vercel.app/
returned HTTP 200 after the supported project resume operation.
The existing Hobby plan and spending limits were unchanged; no upgrade,
budget reset or payment was made. This restored the existing deployment,
without a new build or Git merge.

The canonical homepage returns the expected title. Latest merged candidate
`2fe2d18` is not live: the restored source predates the web performance repair,
stack upgrade and poster SVG fix. Hosted run
[35272624001](https://github.com/ArnavGoel03/buzz/actions/runs/35272624001)
at `cd7b1c1` passed four of five browser cases. The phone map case failed at
`performance.spec.ts:21` because `box?.y` was undefined after `map.boundingBox()`. The earlier
four-case success does not close this latest failure; diagnose it and obtain
matching successful browser acceptance before another candidate deployment.
Live map tile delivery, production Supabase RLS and native-device obligations
remain unverified. No runtime repair or deployment retry occurred in this
records-only follow-up.

Evidence: project GET, production deployment identity and live HTTP/content
readback from the restoration pass. The dated receipts below remain historical
and do not override this current availability or close the remaining holds.

## Earlier status and verification receipts

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
