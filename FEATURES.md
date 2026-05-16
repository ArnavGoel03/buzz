# Buzz feature parity tracker

**The single source of truth for what every Buzz surface can actually do.** Whenever a
feature gains/loses support on a platform, update this file *in the same change set* as
the code. If a session is interrupted mid-port, the next session reads this file first
and resumes from the highest-priority gap.

## How to maintain this file

1. **One row per feature** (not per file — group related screens).
2. **Status legend:**
   - `✅ shipped` — wired to real data + tested
   - `🟢 wired` — implementation calls real backend; not yet exhaustively tested
   - `🟡 scaffold` — UI exists but uses mocks / stubs / no-op writes
   - `🟥 missing` — no implementation
   - `⛔ N/A` — intentionally not on this platform (document the reason)
3. **Update the `last touched` column** to the date of the change.
4. **Update the `notes` column** with anything a future session needs to know — the file:line
   of the entry point, what's still mocked, blocking-dependency keys, etc. Don't be terse;
   detail here saves a future audit.
5. **If you add a new feature**, append a new row. If you remove one, delete the row (don't
   strike-through).
6. **Cross-link to `BACKLOG.md`** for items that haven't shipped yet — use the same wording
   so a `grep` connects the two files.

---

## Discovery + feed

| Feature | iOS / iPad | macOS | Web | Android | App Clip | Last touched | Notes |
|---|---|---|---|---|---|---|---|
| Live tab (events live or starting ≤30 min) | ✅ shipped | ✅ shipped | 🟢 wired | 🟢 wired | ⛔ N/A | 2026-05-16 | iOS: `Features/LiveNow/LiveNowView.swift` + `LiveNowFilter.swift` (extracted pure function with tests). Android: `ui/feed/LiveFeedScreen.kt` + `LiveFeedViewModel.kt`. Web: `/feed` server component. App Clip is a single landing — N/A. |
| Map (live pins + filter chips) | ✅ shipped | ✅ shipped | 🟢 wired (MapLibre) | 🟡 scaffold | ⛔ N/A | 2026-05-16 | iOS: `Features/Map/MapView.swift` + `MapViewModel`. Web: `components/EventMap.tsx` with `react-map-gl` + MapLibre tiles. Android renders the events as a list (`ui/map/MapScreen.kt`) — needs real `maps-compose` or MapLibre integration (see BACKLOG iOS↔Android parity). |
| Clubs grid + category filters + trending rail | ✅ shipped | ✅ shipped | 🟢 wired | 🟢 wired | ⛔ N/A | 2026-05-16 | iOS: `Features/Discovery/ClubsView.swift`. Android: `ui/clubs/ClubsScreen.kt` + 250ms debounce. |
| Global search (events + orgs + people) | 🟡 scaffold | 🟡 scaffold | 🟢 wired | 🟥 missing | ⛔ N/A | 2026-05-16 | iOS `GlobalSearchView.swift` — sequential awaits flagged by audit (#11). Android: not yet built. |
| Daily digest card | 🟡 scaffold | 🟡 scaffold | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | iOS `Features/Digest/DailyDigestCard.swift`. Backed by cron-fed view; cron job exists (`/api/reminders/process`). |
| For You ranked feed | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | iOS `Features/ForYou/ForYouFeed.swift` + `EventRanker.swift`. Ranker weights interests, friend graph, history, proximity. |
| AR Look Around | ✅ iPhone-only | ⛔ N/A | ⛔ N/A | 🟥 missing | ⛔ N/A | 2026-05-16 | `Features/AR/ARLookAroundView.swift` is `#if canImport(ARKit) && os(iOS)`. iPad without world-tracking shows fallback. Android requires ARCore — deferred. |
| "Bored Right Now" (≤10 min walk) | ✅ shipped | ✅ shipped | 🟢 wired | 🟥 missing | ⛔ N/A | 2026-05-16 | Surfaced inside Live tab on iOS/web. |
| Free Food beacon | ✅ shipped | ✅ shipped | 🟢 wired | 🟥 missing | ⛔ N/A | 2026-05-16 | iOS `FreeFoodBeacon.swift` — uses raw RGB literals; BACKLOG iOS-high. |
| Event series | 🟢 wired | 🟢 wired | 🟢 wired | 🟥 missing | ⛔ N/A | 2026-05-16 | iOS `Features/Series/EventSeriesView.swift`. Schema has `event_series` table. |

## Events

| Feature | iOS / iPad | macOS | Web | Android | App Clip | Last touched | Notes |
|---|---|---|---|---|---|---|---|
| One-tap RSVP (optimistic + haptics) | ✅ shipped | ✅ shipped | ✅ shipped | ✅ shipped | ⛔ N/A | 2026-05-16 | Android: rollback on failure landed this session (`EventDetailViewModel.setRsvp`). Web: confetti moved to success branch this session. |
| Auto-add to iOS Calendar on RSVP | ✅ shipped | ✅ shipped | ⛔ N/A | ⛔ N/A | ⛔ N/A | 2026-05-16 | `CalendarService.swift`. BACKLOG iOS-med: re-prompt on every call. |
| Shareable universal links `/e/<id>` | ✅ shipped | ✅ shipped | ✅ shipped | 🟢 wired | ✅ shipped | 2026-05-16 | iOS `BuzzLink.swift`, Android `data/BuzzLink.kt` (regex hardened this session). AASA Team-ID placeholder still blocks Universal Link activation — see SESSION_STATE infrastructure list. |
| Visibility (public / campus / member / officer / invite) | ✅ shipped | ✅ shipped | 🟢 wired | 🟢 wired | ⛔ N/A | 2026-05-16 | Server-side: `events_read` RLS + `em_authed_post` (full visibility check in `0002` after the patch). Client: BACKLOG iOS-med — hide_attendees not always enforced in views. |
| Hide attendees toggle | 🟡 scaffold | 🟡 scaffold | 🟡 scaffold | 🟥 missing | ⛔ N/A | 2026-05-16 | Schema has `hide_attendees`; RPCs respect it; views don't (BACKLOG iOS-med + web-high). |
| Anti-spam: 200 concurrent RSVPs/user | ✅ shipped (server) | ✅ shipped (server) | ✅ shipped (server) | ✅ shipped (server) | ⛔ N/A | 2026-05-16 | DB trigger; counted-trigger race documented in BACKLOG DB. |
| Past-event auto-filter, 14d max duration | ✅ shipped | ✅ shipped | ✅ shipped | ✅ shipped | ⛔ N/A | 2026-05-16 | CHECK constraint in 0000. |
| QR check-in (officer side) | 🟡 DEBUG-only | 🟡 DEBUG-only | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | `CheckInScannerView` now gated `#if DEBUG` (release shows "coming in the next update"). Real HMAC token endpoint not yet built. |
| Live event chat | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | `Features/LiveNow/EventChatView.swift` — `Text(verbatim:)` patch applied this session. |
| Paid tickets (Stripe Connect) | 🟡 DEBUG-only | 🟡 DEBUG-only | 🟢 wired | 🟥 missing | ⛔ N/A | 2026-05-16 | iOS `TicketPurchaseSheet.checkout` gated `#if DEBUG`. Web: real Stripe Checkout session + webhook handler shipped this session. Server: `tickets_insert_pending` / `tickets_mark_refunded` / `tickets_mark_used` RPCs in `0003`. Connect onboarding route still TODO (BACKLOG web-high). |
| Apple Pay (Wallet-style QR) | 🟥 missing | ⛔ N/A | ⛔ N/A | 🟥 missing | ⛔ N/A | 2026-05-16 | Requires `com.apple.developer.in-app-payments` entitlement + merchant ID. |
| Interest polls | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | Schema has `interest_polls` + `interest_poll_votes`. |
| Event reels (15s auto-generated) | ✅ iPhone-only | ⛔ N/A | ⛔ N/A | 🟥 missing | ⛔ N/A | 2026-05-16 | `Features/Creator/EventReelGenerator.swift` uses AVFoundation/Photos — iPhone only by design. |
| Event playlists (Spotify / Apple Music) | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | Schema has `event_playlists`. |
| Event photos / Stories | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | `Features/Stories/EventStoriesRow.swift`. RLS-verified attendees-only upload. BACKLOG iOS-med: AsyncImage HTTPS guard. |

## Social

| Feature | iOS / iPad | macOS | Web | Android | App Clip | Last touched | Notes |
|---|---|---|---|---|---|---|---|
| Friend graph (mutual accept) | 🟡 scaffold | 🟡 scaffold | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | iOS `FriendsView.loadMockFriends()` is empty stub — BACKLOG iOS-med #13. Schema has `friendships` with the symmetry trigger. |
| "5 friends going" badge | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | Server-side via `friends_going_to_event` RPC (added in `0002`). Client surface: `FriendsGoingBadge.swift`. |
| Direct messages (1:1 + group + class) | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | iOS `Features/Messages/DMInboxView.swift` + `MessageThreadView.swift`. Server: `message_threads` + invite-gated `mtm_join_via_invite` policy (`0002`). Soft delete via `messages.deleted_at`. `Text(verbatim:)` patch applied. |
| Streaks (weekly attendance flame) | 🟢 wired | 🟢 wired | 🟢 wired | 🟥 missing | ⛔ N/A | 2026-05-16 | iOS `Features/Streaks/StreakBadge.swift`. View `user_streaks` exists (BACKLOG DB: security_invoker). |

## Organizations

| Feature | iOS / iPad | macOS | Web | Android | App Clip | Last touched | Notes |
|---|---|---|---|---|---|---|---|
| Org profile (hero, members, follow) | ✅ shipped | ✅ shipped | ✅ shipped | 🟢 wired | ⛔ N/A | 2026-05-16 | iOS `Features/Organization/OrganizationView.swift`. Android: `ui/clubs/OrganizationScreen.kt`. `Text(verbatim:)` patch on description. |
| External links (IG + website) | ✅ shipped | ✅ shipped | ✅ shipped | ✅ shipped | ⛔ N/A | 2026-05-16 | Sanitized handles via `safeInstagramUrl` / `safeWebsiteUrl` — mirrored across iOS + Android. JSON-LD `sameAs` on web. |
| Buzzing dot (pulse when live) | ✅ shipped | ✅ shipped | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | iOS-only currently. |
| QR poster (print-ready) | ✅ shipped | ✅ shipped | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | `Features/Tabling/*`. |
| Paper saved counter | ✅ shipped | ✅ shipped | ✅ shipped | 🟥 missing | ⛔ N/A | 2026-05-16 | `Utilities/PaperImpact.swift`. |
| Follow org | 🟡 local-only | 🟡 local-only | 🟢 wired | 🟥 missing | ⛔ N/A | 2026-05-16 | iOS `FollowButton.swift` doesn't persist — BACKLOG iOS-med #26. |

## Club admin

| Feature | iOS / iPad | macOS | Web | Android | App Clip | Last touched | Notes |
|---|---|---|---|---|---|---|---|
| Admin dashboard (web) | ⛔ N/A | ⛔ N/A | ✅ shipped (auth-gated) | ⛔ N/A | ⛔ N/A | 2026-05-16 | `app/admin/[handle]/page.tsx` — session + officer-membership check (this session). Stats still hardcoded (BACKLOG web-high). |
| Inbound email → drafts | ⛔ N/A | ⛔ N/A | 🟢 wired | ⛔ N/A | ⛔ N/A | 2026-05-16 | `api/inbound-email` — Mailgun HMAC + sender-officer check. Real Mailgun MX + signing key needed (infrastructure). |
| Recurring events (RRULE) + templates | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | iOS create-event sheet. |
| Co-hosting | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | Server: `co_host_invites` table + gate on `event_co_hosts` (`0002`). |
| CSV member import | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | `CSVMemberImportSheet.swift`. BACKLOG iOS-med #25: `.edu` substring match. |
| Auto-poster generator | 🟢 wired | 🟢 wired | ✅ shipped | 🟥 missing | ⛔ N/A | 2026-05-16 | Web: `/api/poster/[id]` (cached, ID-validated). iOS: `EventPosterGenerator.swift`. |
| Broadcast (push + email) | 🟢 wired | 🟢 wired | 🟢 wired (auth) | 🟥 missing | ⛔ N/A | 2026-05-16 | iOS `BroadcastSheet.send` now POSTs to `/api/broadcast` with Bearer JWT. Server fan-out wiring (APNs/FCM/Postmark) not yet implemented. |
| Webhook relay (Discord / Slack / generic) | ⛔ N/A | ⛔ N/A | 🟢 wired | ⛔ N/A | ⛔ N/A | 2026-05-16 | `api/webhook-relay` — shared secret + per-kind hostname check + SSRF guard. |
| Calendar import (iCal / Google) | ⛔ N/A | ⛔ N/A | 🟢 wired (officer auth + SSRF) | ⛔ N/A | ⛔ N/A | 2026-05-16 | `api/calendar-import` — events parsed but not yet inserted (BACKLOG web-med). |
| Analytics per-org | 🟢 wired | 🟢 wired | 🟡 hardcoded | 🟥 missing | ⛔ N/A | 2026-05-16 | Web admin shows mock numbers (BACKLOG web-high). View `org_analytics` exists but bypasses RLS (BACKLOG DB). |
| Ownership transfer wizard | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | `OwnershipTransferSheet` now calls real RPC (this session). |
| Invite members flow | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | `InviteListBuilderSheet` + `PeopleSearchSheet` — `InvitesRepository` scaffold added this session (compile-break fix). BACKLOG iOS-med #43: debounce. |
| Check-in scanner (per-event QR) | 🟡 DEBUG-only | 🟡 DEBUG-only | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | See "Events → QR check-in". |

## Academic

| Feature | iOS / iPad | macOS | Web | Android | App Clip | Last touched | Notes |
|---|---|---|---|---|---|---|---|
| Class schedule import | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | `Features/Schedule/ScheduleImportSheet.swift`. Schema: `class_schedules`. |
| Study buddies | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | Schema: `study_sessions` (organizer_id) + `study_session_rsvps`. |
| Professor directory + reviews | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | Server: `professor_reviews_public` view nulls `author_id` when anonymous. BACKLOG DB: `pr_author_read`, `created_at` jitter. |
| Course catalog browse | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | Schema: `courses`, `office_hours`. |

## Dining + transit

| Feature | iOS / iPad | macOS | Web | Android | App Clip | Last touched | Notes |
|---|---|---|---|---|---|---|---|
| Dining hall menus | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | Schema: `dining_halls`, `dining_menus`. |
| "Friends eating here now" | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | Opt-in presence. |
| Live shuttle map | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | `ShuttleMapView.swift` + Supabase Realtime on `shuttle_positions`. |

## Safety

| Feature | iOS / iPad | macOS | Web | Android | App Clip | Last touched | Notes |
|---|---|---|---|---|---|---|---|
| Emergency SOS (3-sec hold) | 🟡 dial-only | 🟡 dial-only | 🟥 missing | 🟡 dial-only | ⛔ N/A | 2026-05-16 | iOS `EmergencySOSButton.swift`, Android `ui/safety/EmergencySosButton.kt` — both open the dialer; no Supabase write yet (`sos_events` table doesn't exist — BACKLOG DB). Android uses `ACTION_DIAL` (one extra tap in emergency — BACKLOG android-med). |
| Safe Walk (buddy tracking) | 🟡 scaffold | 🟡 scaffold | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | `SafeWalkView.swift` — local-only state (BACKLOG iOS-med #30). |
| Campus crime alerts | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | `Features/Safety/CampusAlertsRow.swift`. |

## Greek life

| Feature | iOS / iPad | macOS | Web | Android | App Clip | Last touched | Notes |
|---|---|---|---|---|---|---|---|
| Rush mode (Panhellenic/IFC/NPHC/MGC/Professional) | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | Schema: `rush_cycles`, `rush_rounds`, `rush_interests`. `chapter_mark` is officer-only via trigger (`0002`). |

## Wellness

| Feature | iOS / iPad | macOS | Web | Android | App Clip | Last touched | Notes |
|---|---|---|---|---|---|---|---|
| Mood check-ins (private) | 🟡 scaffold | 🟡 scaffold | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | `WellnessCheckInSheet.swift` save doesn't persist (BACKLOG iOS-med #08). |
| Crisis resources (CAPS / 741741) | ✅ shipped | ✅ shipped | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | Surfaced when mood is `.low` / `.struggling`. |

## Marketplace + lost-and-found

| Feature | iOS / iPad | macOS | Web | Android | App Clip | Last touched | Notes |
|---|---|---|---|---|---|---|---|
| Textbook exchange | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | Schema: `textbook_listings`. |
| Deals (.edu offers) | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | Schema: `deals`, `deal_redemptions`. |
| Lost & Found | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | Schema: `lost_found_posts`. |

## Identity + cold-start

| Feature | iOS / iPad | macOS | Web | Android | App Clip | Last touched | Notes |
|---|---|---|---|---|---|---|---|
| Interests picker (onboarding) | 🟡 orphaned | 🟡 orphaned | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | `InterestsPickerStep.swift` exists but not in flow (BACKLOG iOS-high #21). |
| Per-badge visibility | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | `Features/Badges/`. |
| Tier-aware badges (Member / Officer / Prestige) | ✅ shipped | ✅ shipped | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | Holographic shimmer for Prestige. |
| Invite codes + leaderboard | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | Schema: `invite_codes`. |
| Campus ambassadors | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | Schema: `campus_ambassadors`. |
| Campus waitlist (unsupported schools) | ✅ shipped | ✅ shipped | ✅ shipped | 🟥 missing | ⛔ N/A | 2026-05-16 | iOS `CampusWaitlistView` now POSTs to `/api/waitlist` (this session). Server-side rate limit + `ignoreDuplicates` (this session). |
| iCal seeding | ⛔ N/A | ⛔ N/A | 🟢 wired | ⛔ N/A | ⛔ N/A | 2026-05-16 | `/api/calendar-import` — auth+SSRF; events parsed but not yet inserted. |

## Authentication

| Feature | iOS / iPad | macOS | Web | Android | App Clip | Last touched | Notes |
|---|---|---|---|---|---|---|---|
| Sign in with Apple | 🟡 DEBUG-stub | 🟡 DEBUG-stub | ⛔ N/A | ⛔ N/A | ⛔ N/A | 2026-05-16 | `AuthSession.continueWithApple` now `assertionFailure` + no-op in release. Real Supabase `signInWithIdToken(.apple)` wiring still TODO. |
| Sign in with Google | 🟡 DEBUG-stub | 🟡 DEBUG-stub | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | Same status. |
| Email OTP / magic link | 🟡 DEBUG-stub | 🟡 DEBUG-stub | ✅ shipped | 🟢 wired | ⛔ N/A | 2026-05-16 | Web: `auth/callback/route.ts` (open-redirect closed). Android: `AuthGate.kt` magic-link via `signInWith(Email)`. iOS: stub. |
| Phone OTP | 🟥 missing | 🟥 missing | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | README claims supported; not implemented. |
| `.edu` verified fallback | 🟢 wired | 🟢 wired | 🟢 wired | 🟥 missing | ⛔ N/A | 2026-05-16 | `lib/campus-domains.ts` resolves school. |
| Account deletion | 🟢 wired | 🟢 wired | 🟢 wired (via app) | 🟡 web-redirect | ⛔ N/A | 2026-05-16 | iOS `AccountDeletionSheet` now calls `delete_my_account` RPC. Android currently links out to web — BACKLOG android-high #01. |
| Session revoke everywhere | 🟢 wired | 🟢 wired | ⛔ N/A | 🟥 missing | ⛔ N/A | 2026-05-16 | `revoke_all_sessions()` RPC. |

## Notifications

| Feature | iOS / iPad | macOS | Web | Android | App Clip | Last touched | Notes |
|---|---|---|---|---|---|---|---|
| APNs push | 🟢 wired (Bearer auth) | 🟡 stub | ⛔ N/A | ⛔ N/A | ⛔ N/A | 2026-05-16 | `PushNotificationService.swift` now sends Authorization Bearer + drops client `profile_id`. macOS register branch still TODO. |
| FCM push | ⛔ N/A | ⛔ N/A | ⛔ N/A | 🟥 missing | ⛔ N/A | 2026-05-16 | BACKLOG android-high — needs `google-services.json`. |
| Web push (VAPID) | ⛔ N/A | ⛔ N/A | ⛔ removed | ⛔ N/A | ⛔ N/A | 2026-05-16 | Ripped this session with the PWA. |
| `/api/push/token` server-side insert | ⛔ N/A | ⛔ N/A | 🟡 returns ok but no DB write | ⛔ N/A | ⛔ N/A | 2026-05-16 | BACKLOG web-high — wire service-role upsert. |
| `/api/push/send` fan-out (APNs + FCM) | ⛔ N/A | ⛔ N/A | 🟡 echo | ⛔ N/A | ⛔ N/A | 2026-05-16 | Auth (`CRON_SECRET`) shipped; real APNs/FCM clients still TODO. |
| Event reminders (24h / 1h / 15m) | 🟢 wired (cron) | 🟢 wired (cron) | 🟢 cron | 🟥 missing | ⛔ N/A | 2026-05-16 | Cron schedule actually daily (BACKLOG perf-audit #20). |
| Free-food alerts (opt-in) | 🟢 wired | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | Settings toggle ephemeral (BACKLOG iOS-med #35). |
| Broadcast rate-limit 5/24h/org | ✅ server-enforced | ✅ server-enforced | ✅ server-enforced | ✅ server-enforced | ⛔ N/A | 2026-05-16 | `enforce_broadcast_rate` trigger. Race condition documented in BACKLOG DB. |

## Privacy + abuse prevention

| Feature | iOS / iPad | macOS | Web | Android | App Clip | Last touched | Notes |
|---|---|---|---|---|---|---|---|
| Report flow | 🟢 wired (real insert) | 🟢 wired | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | `ReportSheet.submit` now `INSERT INTO reports`. |
| Block users | 🟡 stub | 🟡 stub | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | Settings → "Blocked users" → `Text("—")` placeholder (BACKLOG iOS-med). |
| Moderation queue + audit log | ⛔ N/A | ⛔ N/A | 🟥 missing (admin tool) | ⛔ N/A | ⛔ N/A | 2026-05-16 | `audit_log` table exists; admin UI not built. |
| GDPR data export | 🟡 stub | 🟡 stub | 🟥 missing | 🟥 missing | ⛔ N/A | 2026-05-16 | Server `export_my_data()` RPC ships (`0002`); UI link goes to `Text("—")` (BACKLOG iOS-med). |
| Privacy screen (app-switcher overlay) | ⚠️ root-only | ⚠️ root-only | ⛔ N/A | 🟥 missing | ⛔ N/A | 2026-05-16 | Only on `RootView` + `BadgeDetailSheet` (BACKLOG iOS-med). |
| Keychain non-iCloud-sync tokens | 🟡 wrong-flag | 🟡 wrong-flag | ⛔ N/A | 🟢 wired | ⛔ N/A | 2026-05-16 | `AfterFirstUnlock` instead of `WhenUnlocked` (BACKLOG iOS-med). |

## Global

| Feature | iOS / iPad | macOS | Web | Android | App Clip | Last touched | Notes |
|---|---|---|---|---|---|---|---|
| 50+ campuses seeded (12 countries) | ✅ shipped | ✅ shipped | ✅ shipped | ✅ shipped | ⛔ N/A | 2026-05-16 | `Closed Campus` registry in `0000`. |
| Per-campus verification strategies | 🟢 wired | 🟢 wired | 🟢 wired | 🟥 missing | ⛔ N/A | 2026-05-16 | Onboarding offers `eduOTP`, `institutionalEmailDomain`, `idCardScan`, `peerAttestation`, `manualReview`. |
| Multi-affiliation profiles | ✅ shipped | ✅ shipped | 🟢 wired | 🟥 missing | ⛔ N/A | 2026-05-16 | `campus_affiliations` table. |

## Web-specific

| Feature | Status | Last touched | Notes |
|---|---|---|---|
| Landing page (marketing) | ✅ shipped | 2026-05-16 | `app/page.tsx`. Fake `aggregateRating` removed this session. |
| Event preview `/e/<id>` (OG + JSON-LD) | ✅ shipped | 2026-05-16 | Person/Event JSON-LD safely escaped this session. |
| Org preview `/o/<handle>` | ✅ shipped | 2026-05-16 | safeJsonLd patch. |
| Profile preview `/u/<handle>` | ✅ shipped | 2026-05-16 | Real Supabase query + Person JSON-LD (this session). |
| Campus landing `/campus/<id>` | ✅ shipped | 2026-05-16 | safeJsonLd patch. |
| Admin dashboard `/admin/<handle>` | ✅ auth-gated | 2026-05-16 | Stats hardcoded — BACKLOG web-high. |
| Embed widget `/embed/o/<handle>` | 🟡 mock | 2026-05-16 | `frame-ancestors *` CSP scoped; real data not yet wired (BACKLOG web-med). |
| AASA universal-link manifest | 🟡 placeholder Team ID | 2026-05-16 | Infrastructure-blocked. |
| PWA install + service worker | ⛔ removed | 2026-05-16 | Native Android replaces this. |

## macOS-specific

| Feature | Status | Last touched | Notes |
|---|---|---|---|
| `Settings { }` scene (⌘,) | ✅ shipped | 2026-05-16 | Per DEVELOP_RULES §3. |
| Menu bar (Buzz / Help command groups) | 🟡 partial | 2026-05-16 | Buzz App + Help groups added this session. View / Window / File still default. BACKLOG iOS-high — full menu bar pass. |
| Single-instance enforcement | ✅ shipped | 2026-05-16 | `NSRunningApplication` check on `init()`. |
| Version footer with gear-to-Settings | ✅ shipped | 2026-05-16 | Sidebar bottom row in `RootView`. |
| ⌘K quick switcher | ✅ shipped | 2026-05-16 | `QuickSwitcherSheet` in `RootView`. |
| ⌘1-⌘4 pane jumps | 🟥 missing | 2026-05-16 | BACKLOG iOS-med. |
| Multi-window | 🟥 disabled | 2026-05-16 | `UIApplicationSupportsMultipleScenes: false`. |

## App Clip-specific

| Feature | Status | Last touched | Notes |
|---|---|---|---|
| AirDrop / QR / NFC handoff | 🟡 stub | 2026-04-28 | `BuzzAppClip/AppClipApp.swift` — minimal landing. Palette is hardcoded (BACKLOG iOS-low #28). |

---

## Desktop distribution (no App Store / no Microsoft Store, $0 fees)

| Surface | Status | How to build | Notes |
|---|---|---|---|
| Mac `.app` / `.zip` / `.dmg` (ad-hoc) | 🟢 scripted + CI | `BUILD_VERSION=1.0.0 scripts/build-mac.sh` (local) or push a `vX.Y.Z` tag | Uses the existing SwiftUI native target. Ad-hoc signed (`codesign --sign -`), no Apple Developer fee. First launch: right-click → Open (Gatekeeper warning, then trusted). CI workflow `.github/workflows/desktop-release.yml` attaches the artifacts to the GitHub Release automatically on tag push. |
| Windows `.msi` / `.exe` (Tauri 2) | 🟢 scaffold + CI | `scripts/build-win.sh` (on Windows) or push a `vX.Y.Z` tag | Tauri 2 wraps the Next.js build in a system WebView2 shell. ~10 MB installer. CI runs on `windows-2022`. No MS Store fee, no signing cert needed. SmartScreen prompts "Run anyway" on first run. |
| Linux `.deb` / `.AppImage` | 🟡 scaffolded | `cargo tauri build` (on Linux) | Same Tauri config emits Linux bundles; not actively maintained. |
| iOS sideload (AltStore / SideStore) | 🟥 not configured | — | Possible without paid Dev account but requires 7-day re-sign cadence. Not set up. |
| `/download` landing page on buzz.app | 🟢 wired | server-rendered | `web/app/download/page.tsx` — links at `https://github.com/ArnavGoel03/buzz/releases/latest/download/Buzz-X.dmg|zip` and `Buzz_X_x64_en-US.msi`. Pulls the `latest/` redirect so the URL stays stable across versions. |

Both desktop targets are designed for **GitHub Releases**: tag a release, attach the
artifacts, point users at the releases page. The in-app updater (when wired) can
poll the GitHub API for the latest tag.

---

## Session log (newest first)

Append a one-line entry when a notable feature lands or status changes. Helps future
sessions catch up without diffing every row.

- **2026-05-16 (late)** — Desktop distribution scaffolded: `scripts/build-mac.sh` for ad-hoc-signed Mac `.app`/`.zip`/`.dmg` (no $99 Apple fee); `win/` Tauri 2 scaffold + `scripts/build-win.sh` for Windows `.msi`/`.exe` (no MS Store fee, SmartScreen warning on first run). Both targeted at GitHub Releases.
- **2026-05-16** — Android nav wired (bottom-nav + deep-link routing + auth gate). iOS macOS Settings scene + ⌘K + single-instance + version footer landed. Web PWA fully ripped. Design tokens unified via `design/tokens.json` + generator. iOS auth stubs no longer grant identity in release. iOS push token Bearer-authed. Account deletion RPC wired iOS. Web Stripe Checkout + webhook real handlers (was stub). Supabase migration `0002_security_hardening.sql` + `0003_indexes_and_payments.sql` shipped. 12 audit reports completed; results captured in `BACKLOG.md`.
