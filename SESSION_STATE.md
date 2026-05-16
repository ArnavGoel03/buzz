# Session state — 2026-05-16

## Audits completed this session (12 total)

### First wave (4)
1. Security/red-team (38 findings, 7 Crit / 14 High)
2. Swift vs DEVELOP_RULES (50 findings, 8 Crit / 21 High)
3. Web/PWA quality (35 findings, 12 High)
4. iOS↔Android parity gap (feature table)

### Second wave (6 Sonnet agents in parallel)
5. Android security/correctness (25 findings)
6. Supabase migration 0002 verification (19 findings — uncovered 3 Crit column-name bugs)
7. Web API patch verification (27 findings — Mailgun shape, Stripe sig multi-v1, DNS-rebinding)
8. iOS deep audit (30 findings — markdown-injection sites, stub paths, hide_attendees client gap)
9. Privacy + GDPR (25 findings — push tokens in export, FORCE RLS gaps, Carto IP leak)
10. Design + a11y + UX honesty (25 findings — dark patterns, missing tokens use)

### Third wave (6 more Sonnet agents)
11. Production readiness (30 findings — silent error swallowing, no retries, Sentry not wired)
12. Performance + cost (25 findings — missing indexes, bundle bloat, GPS micro-tick reloads)
13. CI/CD + release (25 findings — unsigned Android release, unpinned SPM, fastlane gaps)
14. Tokens drift verification (25 findings — category color mismatches, Spacing vs Tokens skew)
15. Payments + tickets (20 findings — checkout was stub, webhook didn't process events, no overselling guard)
16. Migration 0002 re-verification (15 findings post-first-patch)

## Fixes applied this session

### iOS — production safety + DEVELOP_RULES compliance
- **Compile-break**: created `Buzz/Core/Services/InvitesRepository.swift` (mock impl) + wired into `AppServices` so `InviteListBuilderSheet` + `PeopleSearchSheet` compile.
- **§1 Crash discipline**: `preconditionFailure` removed from `SecretsLoader.require` and `BuzzSupabase.shared` (graceful fallback + assertion); `.first!` in `OfflineCache` → `temporaryDirectory` fallback; URL force-unwraps in `BuzzLink`, `SettingsView`, `WellnessCheckInSheet` → optional/invariance-commented; `BuzzApp.swift` services init moved off main via `.task {}`.
- **§3 Architecture**: macOS `Settings { }` scene; App / Help command groups; **single-instance enforcement** via `NSRunningApplication` check on launch; **⌘K quick switcher sheet** in `RootView`; **always-visible version footer** with gear-to-Settings in the sidebar; ⌘K keyboard shortcut wired.
- **§8 Accessibility**: `MetalGradientBackground` now honors `accessibilityReduceMotion`, `accessibilityReduceTransparency`, and `isLowPowerModeEnabled` — collapses to flat fill.
- **Auth security**: `AuthSession.continueWithApple/Google/Email` stubs now `assertionFailure` + no-op in release (was unconditionally granting authenticated state).
- **Push token security**: `PushNotificationService.postToken` now sends Authorization Bearer (Supabase JWT); removed client-supplied `profile_id` from body; removed dead web-push platform.
- **Markdown injection**: `Text(verbatim:)` on `MessageThreadView`, `EventChatView`, `EventDetailSheet.summary`, `OrganizationView.description`.
- **Account deletion**: `AccountDeletionSheet.runDelete` actually calls `delete_my_account` RPC (was sleep + signOut).
- **Stub gating**: `CheckInScannerView` QR `DEV_STUB` token gated `#if DEBUG`; `TicketPurchaseSheet.checkout` gated `#if DEBUG`; `SignInSheet` "more options coming soon" copy removed from release; `ReportSheet.submit` now writes to `public.reports`; `BroadcastSheet.send` now POSTs to `/api/broadcast` with Bearer JWT; `OwnershipTransferSheet.confirmTransfer` calls `transfer_org_ownership` RPC; `CampusWaitlistView` actually POSTs to `/api/waitlist`.
- **Service hygiene**: `LocationService` `deinit { removeObserver }`; `NetworkMonitor` already has `[weak self]`.

### Android — auth + parity
- Bottom-nav `Scaffold` wired (Live / Map / Clubs / Profile); routes for `event/{id}`, `org/{handle}`, `settings`.
- `MainActivity` deep-link handler validates `https://buzz.app/...` via `BuzzLink.validate`; routes accordingly.
- `AuthGate` — magic-link sign-in; release builds without Supabase force sign-in (debug-only passthrough).
- `BuzzLink.validate` handle regex tightened to `[A-Za-z0-9_\\-]{1,40}` blocking nav-route injection.
- `EventDetailViewModel.setRsvp` captures previous state and rolls back on failure.
- Brand accent switched purple → amber to match iOS + web; theme + Color.kt + Tokens.kt delegate to `BuzzTokens`.

### Web — security + product surfaces
- New `web/lib/security.ts` — `safeRelativePath` (control-char + percent-encode block), `safeJsonLd` (escapes `<`, `>`, `&`, `/`, U+2028, U+2029), `verifyMailgunSignature`, `verifySharedSecret` (timing-safe, Bearer fallback dropped), `assertPublicHttpsUrl` (SSRF guard with DNS lookup + RFC1918 / link-local / IPv6 ULA block).
- Patched routes: `auth/callback` (open-redirect closed), `api/push/token` (session-bound), `api/push/send` (CRON_SECRET required, web-push dropped), `api/calendar-import` (officer auth + SSRF + 5s timeout + 2MB cap), `api/inbound-email` (Mailgun multipart form parse + HMAC verify + sender-officer check via `memberships`+`organizations`), `api/webhook-relay` (shared-secret + per-kind hostname check + SSRF guard), `api/tickets/webhook` (real Stripe v1 signature with multi-`v1=` tolerance + idempotency via `stripe_events_seen` + real `checkout.session.completed` + `charge.refunded` handlers), `api/tickets/checkout` (auth + real Stripe Checkout call via fetch + service-role pending-ticket insert; refuses mock URL in production), `api/broadcast` (officer auth via `memberships`), `api/reminders/process` (unconditional CRON_SECRET), `api/waitlist` (IP rate limit + `ignoreDuplicates` to close email-enumeration oracle), `app/admin/[handle]` (server-side session + officer gate; handle regex).
- JSON-LD XSS escape applied to `/e/`, `/o/`, `/campus/`.
- `/u/[handle]` now actually queries Supabase; emits Person JSON-LD; `notFound()` on miss.
- `/e/[id]` JSON-LD enriched with `image`, `offers`, `address`, `performer` for Google Event Rich Results.
- `/api/poster/[id]` — ID sanitized (`[a-zA-Z0-9_-]{1,64}`); long Cache-Control (`s-maxage=3600, stale-while-revalidate=86400`).
- `next.config.ts` — HSTS, `X-Content-Type-Options: nosniff`, `Referrer-Policy`, `X-Frame-Options: DENY` (overridden to `frame-ancestors *` for `/embed/:path*`), `Permissions-Policy`; `images.remotePatterns`; `BUILD_ID`.
- `globals.css` — WCAG-AA text contrast (tertiary 0.42 → 0.60); skip-to-content link styles; `prefers-reduced-motion` collapses every animation; `_tokens.css` imported.
- `layout.tsx` — skip-to-content link added; heavy-component imports remain (would benefit from `next/dynamic` follow-up).
- `app/page.tsx` — fake `aggregateRating: 4.9 from 1` removed from MobileApplication JSON-LD.
- `components/RSVPButton` — confetti moved to success branch (was firing before network resolved); `localStorage` wrapped in try/catch for Safari Private Mode.
- `components/MapFilterChips` + `lib/categories.ts` + `lib/urgency.ts` — colors aligned with `design/tokens.json` (sports green, academic Buzz blue, club purple, free-food amber; urgency colors use CSS vars).
- `middleware.ts` matcher excludes signature-gated routes (`api/poster`, `api/tickets/webhook`, `api/inbound-email`, `api/webhook-relay`) from the Supabase session refresh.

### PWA — fully ripped
- Deleted: `public/manifest.webmanifest`, `public/sw.js`, `public/offline.html`, `components/PWAInstaller.tsx`, `lib/web-push.ts`.
- `app/layout.tsx`: removed manifest meta + appleWebApp + PWAInstaller mount.
- `next.config.ts`: removed SW BUILD_ID note.
- README: PWA row replaced with Android native row.
- `app/api/push/{token,send}`: dropped `web_push` platform.
- `middleware.ts`: removed `manifest.webmanifest` exclusion.

### Design tokens — single source of truth
- New `design/tokens.json` — brand, surface, border, text, status, category, radius, spacing.
- New `scripts/sync-tokens.mjs` — zero-dep Node generator. Run after editing tokens.json.
- Generated files: `Buzz/Core/DesignSystem/Tokens.swift`, `android/.../ui/theme/Tokens.kt`, `web/app/_tokens.css`.
- Existing palettes (`Colors.swift`, Android `Color.kt`, web `globals.css`) all delegate.
- iOS `BuzzSpacing` aligned with `BuzzTokens` (md 12→16, cornerMedium 16→14, cornerLarge 22→18 to match cross-platform).
- iOS `EventCategory.tint` now sources from `BuzzTokens` (was raw RGB literals).

### Supabase migrations
- `0002_security_hardening.sql` — 19+ fixes incorporating both Crit findings and the re-verification round:
  - Column-name corrections (`old.organization_id`, `professor_reviews.text`, `course_id`, `r.user_id`, `s.organizer_id`).
  - `mtm_self` split (invite-gated insert + self-read + self-leave + self-mute); `thread_invites` self-invite blocked.
  - `tickets` direct INSERT revoked; `tickets_insert_from_webhook` SECURITY DEFINER RPC; `buyer_id ON DELETE SET NULL`.
  - `export_my_data` RPC (`push_tokens` redacted to platform+updated_at only).
  - `friends_going_to_event` RPC with server-side `hide_attendees` enforcement.
  - Rush `chapter_mark` officer-only via `guard_rush_chapter_mark` trigger (SECURITY DEFINER + pinned `search_path`).
  - `professor_reviews_public` view with corrected columns (`text`, `course_id`); base table revoked from authenticated + anon.
  - `co_host_invites` table + gate on `event_co_hosts`.
  - `webhook_endpoints_url_check` regex with IPv6 literal block.
  - `lock_affiliation_core` allows `service_role` to reactivate (gap-year case).
  - `guard_friendship_accept` blocks initiator self-accept.
  - `em_authed_post` full visibility check (campus / officersOnly / inviteOnly / host paths; values match 0000 enum).
  - `verify_affiliation` signature corrected for `ALTER FUNCTION ... SET search_path`.
  - `set_event_host_name` derives from org / profile; trigger only on `organization_id` / `host_id` changes.
  - `FORCE RLS` added on `profiles`, `rsvps`, `campus_waitlist`, `event_check_ins`, `study_sessions`, plus the original PII tables.
  - `profiles.email`, `.campus` (FK SET NULL), `.verified` columns added for auth callback compatibility.
  - `campus_waitlist`: SELECT policy restricted to `service_role` / `supabase_admin` / `postgres`.
  - `delete_my_account`: nukes waitlist rows, scrubs `audit_log.payload.profile_id`, deletes `auth.users`.
  - `messages.deleted_at` column + soft-delete policy.
  - `events_insert` officer-only when `organization_id` is set.
  - `broadcasts.sent_by` pinned via trigger.
- **New `0003_indexes_and_payments.sql`** — perf indexes (`rsvps.user_id`, `fr_a`, `pr_professor`, `events.host_handle`, `bc_org_time`, partial GiST `events_geo_published`), `stripe_events_seen` table for webhook idempotency, `organizations.stripe_connect_account_id` column, ticket overselling trigger, `tickets_insert_pending` / `tickets_mark_refunded` / `tickets_mark_used` SECURITY DEFINER RPCs.

### Empty Features/ dirs deleted
- `Alumni`, `Careers`, `Hivemind`, `Housing`, `Itinerary`, `Recaps`, `StudyRooms`, `Syllabus`, `Wrapped` — all removed (Swift audit #20).

## Items deferred — require infrastructure I can't supply in code

These are not fixable without external secrets, account setup, or significant new code surfaces beyond the audit scope. Each requires real-world action.

### Apple / App Store
- **AASA Team ID + App Store numeric ID** — `public/.well-known/apple-app-site-association` still has `TEAMID.com.buzz.app`; `app/layout.tsx` has `apple-itunes-app content="app-id=TBD"`. Replace with real values from App Store Connect.
- **Real phone number** in `fastlane/metadata/en-US/review_information/phone_number.txt`.
- **Screenshots** in `fastlane/screenshots/`; flip `fastlane/Fastfile` `skip_screenshots: true → false`.
- **Copyright entity** in `fastlane/metadata/copyright.txt`.
- **Match git repo + macOS App Store profile** for `com.arnavgoel.buzz`.
- **App icon PNGs** in `Buzz/Resources/Assets.xcassets/AppIcon.appiconset/`.

### Android / Play Store
- **Release `signingConfig`** in `app/build.gradle.kts` reading from `local.properties` (gitignored).
- **`google-services.json`** for FCM + Firebase project setup.
- **Play Store upload key** documentation.
- **`assetlinks.json`** published on `buzz.app` for the App-Links `autoVerify=true` intent filter.

### Backend / SaaS
- **Stripe**: real `STRIPE_SECRET_KEY` + `STRIPE_WEBHOOK_SECRET`; Stripe Connect onboarding route (not yet built).
- **Mailgun**: `MAILGUN_SIGNING_KEY` + MX for `events.buzz.app`.
- **Supabase webhook secret** (`SUPABASE_WEBHOOK_SECRET`) for the relay shared-secret.
- **CRON_SECRET** for `/api/push/send` + `/api/reminders/process` callers.
- **Sentry DSN** for iOS / web crash reporting; **Firebase Crashlytics** equivalent for Android.

### Future code follow-ups (audit-flagged, not done this session)
- iOS Crit: Onboarding orphans (`InterestsPickerStep`, `FindFriendsStep` exist but not wired into the flow).
- iOS High: accent-picker (`@AppStorage("buzz.accent")` with Magenta/Sky/Warm/Neutral options).
- iOS High: raw `Color.white.opacity(...)` in 16+ view files (palette tokens exist; need find-replace pass).
- iOS High: hardcoded `Font.system(size: N)` in 40+ sites; migrate to Dynamic Type variants.
- iOS High: `Buttons` missing `.accessibilityLabel` (icon-only sites in MapView, EventShareButton, ReportMenuButton, sheet close-X).
- iOS Med: `MapView` GPS micro-tick reload — needs 100m distance threshold.
- iOS Med: `FollowButton` persists locally only; wire to memberships table.
- iOS Med: `CalendarService.requestAccess` re-prompts every call; cache `EKAuthorizationStatus`.
- iOS Med: `PrivacyScreen` only on `RootView` + `BadgeDetailSheet`; ~18 other sheets unprotected (Wellness, Tickets, AccountDeletion, etc.).
- iOS Med: Repository error swallowing in `SupabaseEventRepository.event(id:)` — needs propagation.
- iOS Low: AppClip uses hardcoded palette instead of `BuzzColor` / `BuzzTokens`.
- Android: FCM scaffold (deps + service); real map (Google Maps Compose / MapLibre); onboarding; friends / DMs / search / schedule / tickets; in-app account-deletion sheet; persistent settings via DataStore Preferences.
- Web: `next/dynamic` for `CursorGlow` / `CommandPalette` / `KeyboardShortcuts` / `EventMap` to cut critical bundle; `sitemap.ts` real Supabase query; `share_target` route or remove from manifest (already removed).
- DB Med: `set_event_host_name` doesn't propagate on org rename — needs a separate `AFTER UPDATE OF name ON organizations` trigger.
- DB Med: Counted rate-limit triggers race (broadcasts / RSVP cap / invite cap) — need locking.
- DB Med: ~40 tables still lack FORCE RLS (the migration covers the highest-PII set).
- CI Med: Gemfile/Bundler for fastlane; pin Brewfile; commit `Package.resolved`; commit Gradle wrapper; `supabase/config.toml`; gitleaks scan history (`--log-opts`); branch protection on `main`.

## Files changed this session

Counts: 50+ files modified, 12 new files, 9 directories deleted. Highlights:
- iOS: `BuzzApp.swift`, `RootView.swift`, `AppServices.swift`, `Core/Services/{InvitesRepository,SecretsLoader,SupabaseEventRepository,OfflineCache,LocationService,PushNotificationService,AuthSession}.swift`, `Core/Utilities/BuzzLink.swift`, `Core/DesignSystem/{Colors,Spacing,MetalGradientBackground,Tokens}.swift`, `Core/Models/EventCategory.swift`, `Features/Settings/{SettingsView,AccountDeletionSheet}.swift`, `Features/Auth/SignInSheet.swift`, `Features/EventDetail/EventDetailSheet.swift`, `Features/Organization/OrganizationView.swift`, `Features/Messages/MessageThreadView.swift`, `Features/LiveNow/EventChatView.swift`, `Features/Wellness/WellnessCheckInSheet.swift`, `Features/AdminTools/{CheckInScannerView,BroadcastSheet,OwnershipTransferSheet}.swift`, `Features/Tickets/TicketPurchaseSheet.swift`, `Features/Reporting/ReportSheet.swift`, `Features/ColdStart/CampusWaitlistView.swift`.
- Android: 20+ files in `android/app/src/main/kotlin/com/arnavgoel/buzz/` (models, repos, screens, theme).
- Web: `lib/security.ts` (NEW), `lib/categories.ts`, `lib/urgency.ts`, `next.config.ts`, `middleware.ts`, `app/globals.css`, `app/layout.tsx`, `app/page.tsx`, `app/admin/[handle]/page.tsx`, `app/u/[handle]/page.tsx`, `app/e/[id]/page.tsx`, `app/o/[handle]/page.tsx`, `app/campus/[id]/page.tsx`, `app/auth/callback/route.ts`, every route under `app/api/{push,calendar-import,inbound-email,webhook-relay,broadcast,reminders,tickets,waitlist,poster}`, `components/{RSVPButton,MapFilterChips}.tsx`.
- Supabase: `migrations/0002_security_hardening.sql` (extensive), `migrations/0003_indexes_and_payments.sql` (NEW).
- Design: `design/tokens.json` (NEW), `scripts/sync-tokens.mjs` (NEW).
- README.md, SHIP_READINESS.md, SESSION_STATE.md.
