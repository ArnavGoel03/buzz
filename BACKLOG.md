# Buzz backlog

Everything from the 12 audit reports that's still code-fixable but didn't ship this session.
Items are grouped by surface and ordered roughly by severity within each section. Tick the
box when shipped. Bullets reference the audit source so a future session can re-open the
full transcript if context is needed (`agent-1` = first-wave Sonnet red-team, `agent-2-N`
= second-wave agents, etc.).

Items requiring external setup (Stripe keys, App Store Team ID, signing keystores, etc.)
live in `SESSION_STATE.md` under "Items deferred — require infrastructure" — not here.

---

## iOS — high

- [ ] **Onboarding flow orphans** — `Features/Onboarding/{InterestsPickerStep,FindFriendsStep}.swift` exist but `OnboardingView` jumps straight from campus picker → `completeOnboarding`. Wire them into a `TabView(selection:)` flow. *(swift-audit #21)*
- [ ] **Accent picker** — Per DEVELOP_RULES §2: `@AppStorage("buzz.accent")` enum with Magenta / Sky / Warm / Neutral; default Neutral. Update `BuzzColor.accent` to resolve via the picker. *(swift-audit #14)*
- [ ] **Raw `Color.white.opacity(...)` in view code (16+ files)** — `PendingInvitesSection:24`, `ShuttleMapView:{196,200,269,298,303,329}`, `GlobalSearchView:67`, `FriendsView:78`, `InviteMembersSheet:95`, `BadgeCollection:44`, `EmergencySOSButton:13`, `BadgeCard:106`, `OnboardingView:70`, `PendingInviteCard:39`, `FilterChip:26`, `InterestsPickerStep:46`, `AffiliationPill:21`, `EventCapacityGauge:40`, `AttendeePill:19`, `EventDetailSheet:96`, `TablingModeView:112`. Replace with `BuzzColor.border` / `BuzzColor.surface` / a new `BuzzColor.chipFill` token. *(swift-audit #16)*
- [ ] **Hardcoded `Font.system(size: N)` in 40+ view sites** — bypasses Dynamic Type. Targets include `ProfileHeader:31`, `EventPosterGenerator:{49,52}`, `InterestsPickerStep:13`, `FindFriendsStep`, `InviteCodeSheet`, `LoadingStateView:{16,38}`, `OrganizationHero`, `FollowButton`. Use `.title2` / `.headline` / `.body` / `.caption` text styles, or `Font.system(.headline, design: .rounded, weight: .semibold)` etc. Poster generation is OK to keep hardcoded (rendering to a fixed-size PNG). *(swift-audit #17, #19; design-audit #12, #13)*
- [ ] **`Buttons` missing `.accessibilityLabel`** — only 7 a11y labels across the whole app per audit. Icon-only buttons: `MapView` map controls, `EmergencySOSButton` chrome, `EventShareButton`, `ReportMenuButton`, all close-X buttons (`TablingModeView:48-53`, `ARLookAroundView:26-31`). *(swift-audit #38)*
- [ ] **SignInSheet Google OAuth + email-OTP** — currently SIWA-only in release; DEBUG path uses the unsafe stubs. Wire `GIDSignIn.sharedInstance.signIn(...)` for Google and the real Supabase email-OTP for email. *(swift-audit #22; ios-audit #02)*

## iOS — med

- [ ] **`MapView` GPS micro-tick reloads** — `.onChange(of: services.location.coordinate.latitude)` fires a full repo round-trip per `LocationService.distanceFilter = 30m` callback. Add a 100m distance threshold (or `Task.sleep` debounce + cancellation). *(swift-audit #31; perf-audit #05; prod-audit #25)*
- [ ] **`PrivacyScreen` only on 2 sheets** — comment in `PrivacyScreen.swift` says "Apply to root AND every sheet's root." Currently `RootView` + `BadgeDetailSheet`. Add `.privacyScreen()` to: `WellnessCheckInSheet`, `AccountDeletionSheet`, `EventDetailSheet`, `BroadcastSheet`, `TicketPurchaseSheet`, `InviteMembersSheet`, `OwnershipTransferSheet`, `CreateEventSheet`, `SafeWalkView`, `MyTicketsView`, `DMInboxView`. *(security-audit #25; ios-audit #16-18; privacy-audit #11)*
- [ ] **Keychain accessibility flag** — `Buzz/Core/Services/KeychainTokenStore.swift` uses `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`. README + Privacy Policy promise `WhenUnlocked`. Switch to `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` and capture `OSStatus` return codes. *(privacy-audit #12; security-audit #34)*
- [ ] **`SupabaseEventRepository.event(id:)` swallows errors with `try?`** — 401 / 5xx renders as "Event not found." Propagate the error so the UI can distinguish 404 from network failure. Same pattern in `MapViewModel`, `OrganizationViewModel`, `ProfileViewModel` (`catch { // MVP: silent }`). Wrap with `Retry.run` from `Core/Utilities/Retry.swift`. *(prod-audit #08, #11, #13-15; android-audit #08)*
- [ ] **AccountDeletionSheet silently swallows RPC failure** — `try? await ... rpc("delete_my_account")` then `auth.signOut()` runs regardless. If RPC fails the user's local session is cleared but the server row is intact. Surface the error and keep the session alive until deletion is confirmed. *(prod-audit #09)*
- [ ] **CreateEventSheet swallows publish failure** — `_ = try? await services.events.createEvent(event)` discards both result and error; sheet dismisses with a success haptic even on RLS / network failure. Use `do/catch` + toast + leave sheet open. *(prod-audit #10)*
- [ ] **`FollowButton` persists locally only** — `OrganizationViewModel.isFollowing` is marked `// local-only toggle for MVP`. Wire to `memberships` table via Supabase. *(prod-audit #26)*
- [ ] **`CalendarService.requestAccess` re-prompts every call** — cache `EKAuthorizationStatus` after first call. *(prod-audit #24)*
- [ ] **SOS doesn't include coordinates** — `Buzz/Features/Safety/EmergencySOSButton.swift` doesn't check `LocationService.authorization` or include lat/lng in the (stub) write. Plus `sos_events` table doesn't exist yet; create migration `0004_sos.sql` defining the table with `FORCE RLS`. *(ios-audit #09; privacy-audit #03)*
- [ ] **`WellnessCheckInSheet.Save` doesn't persist** — toolbar Save dismisses with no Supabase insert. Wire to `wellness_checkins` table. *(ios-audit #08)*
- [ ] **`FriendsView.loadMockFriends()` is empty stub** — view always renders blank. Wire to real friendship + suggestion queries. *(ios-audit #13)*
- [ ] **EventDetailSheet `hideAttendees` not enforced client-side** — `friendsGoing` + `event.rsvpCount` rendered unconditionally. Add `guard event.hideAttendees != true` before rendering `FriendsGoingBadge` + `AttendeePill`. *(ios-audit #04)*
- [ ] **`OrganizationViewModel.membersSorted` doesn't filter hidden** — never filters `isVisible == false`. *(ios-audit #05)*
- [ ] **`AsyncImage` no HTTPS enforcement** — `ProfileAvatar.swift:19-21`, `LostFoundView.swift:71-75`, `EventStoriesRow.swift:41`. Guard `url.scheme == "https"` before passing to `AsyncImage`. *(ios-audit #19-21)*
- [ ] **`DispatchQueue.main.asyncAfter` survivors** — `SplashView.swift:36-38` (nested) and `RSVPButton.swift:16`. Convert to `Task { try? await Task.sleep(...) }` so SwiftUI cancels on view disappear. *(swift-audit #29-30; ios-audit #10)*
- [ ] **`SplashView` unskippable** — add `.onTapGesture { onFinish() }`. *(swift-audit #46)*
- [ ] **`OnboardingView` `Task { }` no cancellation** — fire-and-forget mutates `auth.state` after view dismiss. Use `.task` or store + cancel on `onDisappear`. *(swift-audit #32; ios-audit #22)*
- [ ] **`ARLookAroundView` no `ARWorldTrackingConfiguration.isSupported` guard** — blank screen on iPad 9 / simulator. *(swift-audit #37)*
- [ ] **`InviteMembersSheet` no debounce** — `PeopleSearchSheet` has 300ms debounce; `InviteMembersSheet` doesn't. Mirror the pattern. *(swift-audit #43)*
- [ ] **`EventDetailSheet` rebuilds DateFormatter every redraw** — hoist to `static let` or use `Date.FormatStyle`. *(swift-audit #41)*
- [ ] **`PushNotificationService` no retry** — `try? await URLSession.shared.data(for: req)` swallows 5xx / 401. Wrap with `Retry.run`. *(swift-audit #42; prod-audit #05)*
- [ ] **`ProfileHeader` 260pt initial overflows** — add `.minimumScaleFactor(0.5)` or scale to container width. *(swift-audit #44)*
- [ ] **`Reduce Motion` audit on motion-heavy components** — `ConfettiBurst`, `RevealingText`, `ScrollRevealCard`, `SuccessCelebration` ignore `@Environment(\.accessibilityReduceMotion)`. *(design-audit #09; ios-audit #25)*
- [ ] **`CSVMemberImportSheet:82` `.contains(".edu")` substring match** — `evil@attacker.edu.example.com` passes. Validate full domain suffix against an allow-list. *(ios-audit #25)*
- [ ] **`ARLookAroundView.updateUIView` re-creates anchors every redraw** — `view.scene.anchors.removeAll()` then re-add 10 entities. Diff via a `Coordinator`. *(ios-audit #26)*
- [ ] **`TablingModeView.visitorCount` increments on tap, not on delivery** — wrap `ShareLink` in `UIActivityViewController` completion handler. *(ios-audit #29)*
- [ ] **`SafeWalkView.isWalking` state is local-only** — force-quit / swipe-away leaves buddy with no "session ended" signal. Persist in a service + cancel from `onDisappear`. *(ios-audit #30)*
- [ ] **`MetalGradientBackground` 60fps even when offscreen** — `TimelineView` doesn't pause when SwiftUI scene is `.inactive`. Lower to 30fps on splash + pause on inactive. *(perf-audit #11)*
- [ ] **`LocationService.coordinate` re-renders MapView on every assignment** — split into `latitude` + `longitude` or `@ObservationIgnored` + publish via threshold. *(perf-audit #19)*
- [ ] **`AppServices()` still `@MainActor`** — `Task.detached { await MainActor.run { AppServices() } }` is a no-op hop. Move `LocationService.init`'s synchronous `authorizationStatus` call off main, or accept the cost. *(perf-audit #04)*
- [ ] **`AppClip` uses hardcoded palette** — `BuzzAppClip/AppClipApp.swift` uses raw `Color.black`, `.yellow`, `Color.white.opacity(0.75)`, `.system(size: 17, weight: .bold)`. Should share `BuzzColor`/`BuzzFont` via a shared SPM target. *(swift-audit #28)*
- [ ] **`SettingsView` toggles ephemeral `@State`** — `freeFoodAlerts` / `friendActivityAlerts` / `weeklyDigest` reset on every sheet open. Use `@AppStorage("buzz.notif.…")` and back with a `notification_prefs` server column for cross-device sync. *(swift-audit #35; design-audit #03)*
- [ ] **Sentry SDK initialization** — `SecretsLoader.Key.sentryDSN` declared but `SentrySDK.start` never called. Wire in `BuzzApp.init` once a DSN exists in `Secrets.plist`. *(prod-audit #17)*

## iOS — low

- [ ] **`PushNotificationService.registerWebPushSubscription` still compiled into iOS binary** — never called but reachable. Move inside `#if !os(iOS)`. *(ios-audit #27)*
- [ ] **`Haptics` on macOS** — `RootView.onChange(of: selection) { Haptics.selection() }` fires on Mac too; gate `#if !os(macOS)` or ensure `Haptics` no-ops on Mac. *(swift-audit #45)*
- [ ] **`Settings` legal links open in Safari** — use in-app `SFSafariViewController` (or `SafariView` wrapper) for Privacy / Terms / Support. *(swift-audit #49)*
- [ ] **`MetalGradientBackground` re-seeds `start` on `intensity` change** — Use `@State` instead of `init`-set. *(swift-audit #50)*
- [ ] **`SecretsLoader.value` swallows decoder errors silently** — add a debug `os_log` breadcrumb when plist parse fails. *(swift-audit #47)*
- [ ] **`UUID(uuidString: "...")!` force-unwraps in `MockEventRepository:22` / `MockProfileLoader:28-29`** — add invariance comments or use `static let` + unit test asserting decodability. *(swift-audit #05)*

---

## Android — high

- [ ] **In-app account deletion** — `ui/settings/SettingsScreen.kt:48` currently links to `https://buzz.app/settings#delete`. Build an in-app `DeleteAccountScreen` mirroring iOS `AccountDeletionSheet`, calling `delete_my_account` RPC via Supabase Postgrest. *(design-audit #01)*
- [ ] **FCM push** — add `firebase-messaging-ktx` + Google Services plugin to `app/build.gradle.kts`; drop `google-services.json`; create `BuzzMessagingService` extending `FirebaseMessagingService`; on `onNewToken` POST to `/api/push/token` (Bearer Supabase JWT). Add `POST_NOTIFICATIONS` runtime request. *(parity-gap P0)*
- [ ] **Real map** — swap `MapScreen` placeholder for `com.google.maps.android:maps-compose` (or MapLibre). *(parity-gap P0)*
- [ ] **Friends / DMs / Search / Schedule / Tickets / Report** — each is a separate session. *(parity-gap P1)*
- [ ] **Settings toggles persistence** — `SettingsScreen` toggles are `remember { mutableStateOf }` only. Back with `DataStore Preferences` + sync to a server preference column. *(design-audit #03)*
- [ ] **App Links assetlinks.json** — publish on `buzz.app/.well-known/assetlinks.json` so `autoVerify=true` intent-filter activates.
- [ ] **`AuthGate` `LoadingFromStorage` flash** — explicit arm `is SessionStatus.LoadingFromStorage -> LoadingScreen()` to suppress the sign-in flash on every cold start. *(android-audit #02)*
- [ ] **Sign-in email validation** — `AuthGate.kt:73-75` only checks `isBlank()`. Add `android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()`. *(android-audit #03)*
- [ ] **Deep-link processed before auth gate** — `MainActivity.handleDeepLink(intent)` is called in `onCreate` before Compose composes. Gate deep-link dispatch on `sessionStatus` in a `LaunchedEffect`. *(android-audit #04)*
- [ ] **Manifest intent-filter scope** — `android/app/src/main/AndroidManifest.xml` accepts any `https://buzz.app/*` path. Add explicit `<data android:pathPrefix="/e/">`, `"/o/"`, `"/u/"` data entries. *(android-audit #07)*
- [ ] **`allowBackup=true` exposes Supabase session via `adb backup`** — set `android:allowBackup="false"` or restrict `fullBackupContent` to explicitly exclude `supabase_auth`. *(android-audit #23)*

## Android — med

- [ ] **Repository error propagation** — `SupabaseEventsRepository.event(id)` returns `null` on auth-error / 5xx, surfaces as "Event not found." Return `Result<Event?>` from the interface; differentiate auth vs 404. *(android-audit #08; prod-audit #21)*
- [ ] **RSVP raw exception leak to UI** — `EventDetailViewModel.setRsvp` shows `e.message` directly; could include RLS policy names. Catch `RestException` specifically + sanitize. *(android-audit #09)*
- [ ] **Real `myRsvps()` implementation** — `SupabaseEventsRepository.myRsvps()` is hardcoded to `emptyMap()`. After cold launch all events appear as `NOT_GOING`. Query `my_rsvps` view. *(android-audit #11)*
- [ ] **`EmergencySosButton` accessibility** — uses `detectTapGestures` instead of `Modifier.clickable`; TalkBack can't trigger a press-and-hold. Add `role = Role.Button` + `customActions` with the dial action. *(android-audit #14)*
- [ ] **`EmergencySosButton` race condition** — `LaunchedEffect(pressed)` restarts on rapid press/release. Use `snapshotFlow { pressed }.collectLatest`. *(android-audit #12)*
- [ ] **Cancel-SOS countdown** — pocket-press or child tap triggers 911 silently. Add a 5s "Cancel SOS" countdown after the 3s hold completes. *(android-audit #15)*
- [ ] **SOS uses `ACTION_DIAL` not `ACTION_CALL`** — extra tap cost in emergency. Use `ACTION_CALL` with `CALL_PHONE` runtime permission. *(android-audit #13)*
- [ ] **`EventCategory.tint` `Color` in `@Serializable` data class** — Compose `Color` isn't `@Serializable`; alpha silently dropped on persistence. Move `tint` to a UI-only mapping. *(android-audit #20)*
- [ ] **`TimeFilter.TONIGHT` boundary** — multi-day event ending today registers as "tonight"; midnight-crossing event shows under both. Align with iOS logic + add unit tests. *(android-audit #21)*
- [ ] **`AppServices.resetForAccountSwitch` doesn't reset Supabase session** — old viewmodels can keep firing requests under the new session. Call `Buzz.supabase.auth.signOut()`. *(android-audit #17)*
- [ ] **`ProfileScreen` runs query without ViewModel** — `LaunchedEffect(Unit) { profile = AppServices.shared().profiles.me() }` outlives the Composable. Move to ViewModel + viewModelScope. *(android-audit #19; prod-audit #23)*
- [ ] **`EventDetailViewModel.load(eventId)` no job cancellation** — rapid eventId changes don't cancel the prior in-flight load. Store + cancel the `Job`. *(android-audit #19)*
- [ ] **`hexColor()` silent fallback** — `ProfileScreen.kt:73-83`. Validate `^#[0-9A-Fa-f]{6}$`; log unexpected values; handle 8-digit ARGB explicitly. *(android-audit #25)*
- [ ] **Adopt `BuzzTokens.SpacingMD` / `RadiusLG`** — all Android screens hardcode `16.dp` / `18.dp`. Replace with token references. *(design-audit #16; tokens-audit #16)*
- [ ] **Use `BuzzTokens.CategoryParty` etc. in Compose code** — currently each callsite imports the long `BuzzTokens.CategoryX`; add ergonomic top-level aliases in `Color.kt`. *(tokens-audit #19)*
- [ ] **RSVP buttons `contentDescription`** — `EventDetailScreen.kt:96-110` "Going" / "Interested ✓" — add `Modifier.semantics { contentDescription = "RSVP Going to ${event.title}" }`. *(design-audit #17)*
- [ ] **Coil 3.x upgrade + `AsyncImage` defaults** — bump `coil = "3.0.0"`; establish `placeholder`/`error`/`size` pattern before images ship. *(perf-audit #16)*
- [ ] **`AuthGate` blocks first-frame on session-flow collect** — switch to `collectAsStateWithLifecycle(initialValue = SessionStatus.LoadingFromStorage)` + skeleton frame. *(perf-audit #15)*
- [ ] **Crashlytics / Sentry-Android init** — `BuzzApplication.onCreate()` is empty; no crash reporting at all. *(prod-audit #18)*

## Android — low

- [ ] **`SettingsScreen.openUrl()` accepts arbitrary URL strings** — currently used only with hardcoded literals; harden to reject non-http(s) schemes for future reuse. *(android-audit #24)*

---

## Web — high

- [ ] **`next/dynamic` for heavy globals** — `layout.tsx` mounts `CursorGlow`, `CommandPalette`, `KeyboardShortcuts`, `ScrollProgress`, `PWAInstaller`(removed). Lazy-load with `dynamic({ ssr: false })`; route-gate `ScrollProgress` off `/`. Cuts ~50KB framer + ~mock-data from the critical path. *(web-audit #09; perf-audit #01, #02, #18)*
- [ ] **`CommandPalette` imports `mockEvents` / `mockOrgs`** — every visitor downloads the fixture data set. Lazy-load + fetch real data only when palette opens. *(perf-audit #02)*
- [ ] **`EventMap` dynamic import** — confirm `next/dynamic({ ssr: false })` everywhere it's used (landing/feed/`/e/`). Otherwise MapLibre (~350KB) is in the initial bundle. *(web-audit #18; perf-audit #12)*
- [ ] **`@react-three/fiber` audit** — `three.js` is ~500KB gzipped. Confirm all 3D imports are `dynamic({ ssr: false })`. *(perf-audit #03)*
- [ ] **`sitemap.ts` reads mock data** — query Supabase in `sitemap()`; return `[]` on env miss. *(web-audit #13)*
- [ ] **`/admin/[handle]` real stats** — `Stat` values are hardcoded ("412", "1.2k", "73%"). Query real aggregates server-side. *(design-audit #08)*
- [ ] **Sign-in shader background blocks render** — `app/sign-in/page.tsx:13` `{ ssr: false }` dynamic import leaves `<main>` background-less until ~400KB of R3F+Three lands. Pass a static gradient fallback to `dynamic({ loading })`. *(web-audit #25)*
- [ ] **`/map` title via `useEffect`** — `app/map/page.tsx:18-20` is client-only; split into server `page.tsx` (exports metadata) + client `MapView.tsx`. *(web-audit #27)*
- [ ] **`/u/` redirect uses email local-part** — `app/profile/page.tsx:31` `redirect(\`/u/${user.email?.split("@")[0]}\`)`. Look up `profiles.handle` for `user.id` instead. *(web-audit #29)*
- [ ] **`/share` route or remove `share_target`** — `manifest.webmanifest` removed entirely; verify no stale `share_target` action remains. *(web-audit #28)*
- [ ] **`/o/[handle]` CLS** — 80×80 avatar over a `36vh` hero on mobile + framer `TextReveal` H1 = mid-tier CLS on initial paint. Render avatar with explicit `width`/`height` via `next/image`; reserve hero with `aspect-ratio`. *(web-audit #12)*
- [ ] **Sticky header + `AppBanner` stack incorrectly** — both `sticky top-0` z-index conflict. Explicitly stack: banner first, header `top-[var(--banner-h)]`. *(web-audit #21)*
- [ ] **Vercel Analytics / SpeedInsights scrub URLs** — handles + UUIDs in URLs go to Vercel. Add `beforeSend` to both components replacing dynamic segments with placeholders. *(privacy-audit #07)*
- [ ] **MapLibre tile requests via Vercel proxy** — Carto receives user IPs + viewport bounds. Either proxy via edge function or use self-hosted tiles. *(privacy-audit #15)*
- [ ] **`profile_id` in iOS push body** — `Buzz/Core/Services/PushNotificationService.swift` no longer sends it (this session's fix). But verify other call sites and ensure no client field would resurrect it. *(privacy-audit #22)*
- [ ] **`push_tokens` actual DB insert in `/api/push/token`** — handler validates auth but returns `{ ok: true }` without `INSERT`. Wire the upsert via service-role client. *(privacy-audit #20; prod-audit #12)*
- [ ] **Stripe Connect onboarding** — no `/api/stripe/connect/onboard` route exists. Build OAuth flow that writes `organizations.stripe_connect_account_id` (column added in 0003). *(payments-audit #12)*
- [ ] **JSON-LD geo for non-public events** — `app/e/[id]/page.tsx` emits precise lat/lng for every visibility. Omit `geo` when `event.visibility != 'public'`. *(privacy-audit #19)*
- [ ] **`getEvent()` null `attendee_count` when `hide_attendees`** — `web/lib/data.ts`. *(privacy-audit #04)*
- [ ] **SSRF DNS-rebinding (TOCTOU)** — `assertPublicHttpsUrl` resolves DNS then `fetch` resolves again. Re-resolve at fetch time + pin IP to a `lookup` option, or run fetch through a proxy. *(api-verify-audit #01)*
- [ ] **`assertPublicHttpsUrl` decimal-encoded IPs** — `https://2130706433/` parses with hostname `"2130706433"` (= `127.0.0.1` on Linux libc). Reject `^[0-9]+$` and `0x...` hostnames before lookup. *(api-verify-audit #08)*
- [ ] **`assertPublicHttpsUrl` IPv6 bracket handling** — `url.hostname` for `[fe80::1]` includes brackets, so the `startsWith("fe80:")` check is dead. Strip brackets + zone-IDs before `isPrivateIp`. *(api-verify-audit #09)*
- [ ] **PKCE / state check on auth callback** — no explicit `state` parameter validation; account-fixation risk. Verify Supabase SSR is configured for PKCE; check `state` against a cookie value before `exchangeCodeForSession`. *(api-verify-audit #16)*
- [ ] **Auth callback `next` re-validate via `new URL(next, origin)`** — even with `safeRelativePath`, encoded-backslash + tab variants can survive. Add a `URL()` round-trip + origin compare. *(api-verify-audit #06)*

## Web — med

- [ ] **`getEventsByOrg` no `.limit()`** — `data.ts:73` `.select("*").eq("host_handle", handle).order("starts_at")` — add `.limit(50)` + pagination. *(perf-audit #09)*
- [ ] **`getOrgs` `select("*")`** — enumerate only needed columns. *(perf-audit #10)*
- [ ] **Font axes** — `fonts.ts` loads Fraunces with `axes: ["opsz", "SOFT", "WONK"]`; verify all three are used in CSS. *(perf-audit #14)*
- [ ] **Edge function mock import** — `poster/[id]/route.tsx:3` imports `mockEvents` synchronously into the edge bundle. Switch to real Supabase fetch. *(perf-audit #17)*
- [ ] **Tertiary contrast pass** — globals.css `text-tertiary` lifted to 0.60 this session; verify no remaining `text-text-quaternary` usage on body text. *(web-audit #32)*
- [ ] **`localStorage` wrapped everywhere** — RSVPButton wrapped this session; `AppBanner.tsx:33-36` still bare. *(web-audit #33)*
- [ ] **`campus-domains.ts` lazy-load** — 11,747-line JSON imported synchronously into every route that touches sign-in. Use `await import("@/data/us-universities.json")` inside `resolveCampus`. *(web-audit #34)*
- [ ] **Spacer divs → `pb-20`** — every page repeats `<div className="h-16 md:h-8" />`. Move to `AppShell.tsx` `<main className="pb-20 md:pb-8">`. *(web-audit #14)*
- [ ] **Service worker registration update flow** — N/A (PWA fully removed this session). Delete any lingering reference if found. *(web-audit #26)*
- [ ] **`apple-itunes-app` placeholder** — `app/layout.tsx` `content="app-id=TBD"`. Replace once App Store numeric ID exists. *(design-audit #11)*
- [ ] **`b/e` Event Rich-Results offers** — confirm `offers.price: "0"` survives Google's eligibility check. Re-enrich with real ticket prices when Stripe Checkout flow is live. *(web-audit #17)*
- [ ] **Person JSON-LD on `/u/`** — added this session; verify schema.org `Person` shape (`affiliation`, `alternateName`). *(web-audit #16)*
- [ ] **Inbound-email handle character class** — `app/api/inbound-email/route.ts` already validates `^[a-z0-9-]{1,40}$`; verify all org-handle entry points share that regex. *(api-verify-audit #22)*
- [ ] **`r.ok` after full-body read** — `app/api/calendar-import/route.ts:52` reads `r.arrayBuffer()` before `r.ok` check; 2 MB of attacker data hits memory on error. Check `r.ok` first. *(api-verify-audit #21)*
- [ ] **`waitlist` rate limit upgrade** — current in-memory map is per-instance. Move to Upstash KV or Vercel KV for cross-instance enforcement. *(api-verify-audit #19; prod-audit #19)*
- [ ] **`api/reminders/process` + `api/push/send` `CRON_SECRET` timing-safe** — use `crypto.timingSafeEqual` on the Bearer compare. *(api-verify-audit #23, #24)*
- [ ] **`safeJsonLd` escape `/`** — done this session; verify regression tests prevent future drift. *(api-verify-audit #18)*
- [ ] **Cron comment "every 5 min"** — actual schedule is `0 13 * * *`; fix the comment in `reminders/process/route.ts`. *(perf-audit #20)*
- [ ] **`images.remotePatterns` scope** — `*.supabase.co` is too broad; scope to `<project-ref>.supabase.co/storage/v1/object/public/**`. *(perf-audit #22)*

## Web — low

- [ ] **`app/auth/callback/route.ts` dead branch cleanup** — `email`/`verified`/`campus` columns now exist on `profiles` (added in `0002`); the silent-fail try/catch can be tightened. *(web-audit #38)*
- [ ] **`app/u/[handle]/page.tsx` add `robots: { index: false }` for unverified profiles** — once a "verified" flag exists per profile. *(web-audit #15)*
- [ ] **`app/feed/page.tsx` spacer cleanup** — covered by web-med #14.
- [ ] **`AppShell.tsx:91` "v0.1 · built at UCSD"** — replace with dynamic `VERSION_NAME` like iOS/Android. *(design-audit #24)*
- [ ] **`messages/page.tsx` "AR Look Around" listed without iPhone-only caveat** — qualify the feature copy. *(design-audit #20)*
- [ ] **Search / CommandPalette `focus-visible:ring`** — `outline-none` with no replacement ring on keyboard focus. *(design-audit #19)*

---

## Supabase — DB

- [ ] **`set_event_host_name` on org rename** — trigger fires on event-side changes only. Add `AFTER UPDATE OF name ON organizations` that propagates to all linked event rows. *(migration-verify-audit #10)*
- [ ] **Counted-trigger rate-limit races** — `enforce_broadcast_rate`, `enforce_rsvp_cap`, `enforce_invite_cap` all `select count(*)` then CHECK. Use serializable transactions or a per-org/event counter row with `FOR UPDATE` lock. *(security-audit #26)*
- [ ] **`FORCE RLS` on remaining ~40 tables** — `campus_affiliations`, `organizations`, `memberships`, `events`, `event_check_ins`, `event_photos`, `event_messages`, `event_invites`, `event_co_hosts`, `event_drafts`, `event_reminders`, `event_reels`, `event_playlists`, `event_series`, `campuses`, `campus_ambassadors`, `campus_requests`, `interest_polls`, `interest_poll_votes`, `invite_codes`, `rush_cycles`, `rush_rounds`, `rush_interests`, `ticket_types`, `webhook_endpoints`, `broadcasts`, `friendships`, `professors`, `courses`, `office_hours`, `professor_reviews`, `dining_halls`, `dining_menus`, `shuttle_routes`, `shuttle_stops`, `shuttle_positions`, `profile_interests`, `class_schedules`, `lost_found_posts`, `textbook_listings`, `deals`, `deal_redemptions`, `reports`, `study_session_rsvps`. *(privacy-audit cross-cut)*
- [ ] **`event_live_capacity` + `user_streaks` views — `WITH (security_invoker = true)`** — both bypass underlying RLS today. *(privacy-audit #08)*
- [ ] **`org_analytics` view permissions** — exposes cross-org member counts to any authenticated user. Add `security_invoker = true` or wrap in policy-enforced RPC. *(privacy-audit #17)*
- [ ] **`audit_log` payload scrub for `actor_id`** — `delete_my_account` scrubs `profile_id` but not other keys. Either strip every key containing the user's UUID or set payload to `'{}'` for the actor's own rows. *(privacy-audit #18; migration-verify #03)*
- [ ] **`delete_my_account` wrapped in exception block** — current cascade via `auth.users` delete can fail mid-way leaving partial state. Wrap in `BEGIN/EXCEPTION` or explicit-delete sequence. *(migration-verify #04)*
- [ ] **`em_authed_post` `'officersOnly'` joins** — verify `memberships.organization_id = e.organization_id` matches the actual FK direction in 0000 (event hosts may not always be an org). *(migration-verify #06)*
- [ ] **`pr_author_read` policy** — `professor_reviews` table base-table SELECT now revoked from authenticated, but authors can't see their own review for UPDATE / RETURNING. Add a `pr_author_read for select using (auth.uid() = author_id)` policy. *(migration-verify #11)*
- [ ] **`waitlist_read_admin` policy with `service_role`** — verify the policy actually evaluates `current_user` correctly for Vercel server-role connections. *(migration-verify #15)*
- [ ] **`tickets_insert_from_webhook` `qr_token` generated server-side** — currently the function takes `p_qr_token` as a parameter. Generate inside the function (`encode(gen_random_bytes(32), 'hex')`) so callers can't supply a colliding or guessable token. Add `unique` constraint on `tickets.qr_token`. *(payments-audit #03)*
- [ ] **Retention policies** — `pg_cron` jobs to purge: `push_tokens.updated_at < now() - interval '90d'`, `safe_walks` where `ended_at < now() - interval '30d'`, `wellness_checkins` older than 1y, `event_check_ins` for events ended > 2y ago. *(privacy-audit #10)*
- [ ] **`event_invites` per-target rate limit** — invite spam from bulk orgs. Add per-(profile_id, inviter_id) per-day cap trigger + user-side block-invites-from-org. *(security-audit #32)*
- [ ] **`messages` author can SELECT own message after soft-delete** — verify `msg_member_read` doesn't filter out `deleted_at IS NOT NULL` rows for the author. Add `or author_id = auth.uid()` to the read policy. *(security-audit #31)*
- [ ] **`anonymous review created_at` jitter** — `professor_reviews_public` exposes precise `created_at`; correlate-able with check-in timing. Truncate to day or add ±0–4h jitter. *(privacy-audit #14)*
- [ ] **`ri_chapter_mark` 0000-era policy** — drop explicitly in migration 0002 or 0003 (the 0000 policy is overlapping with the new trigger). *(migration-verify #07)*
- [ ] **`profiles_email` unique constraint or index** — auth-callback uses email as a lookup key in inbound-email; should be `unique` if any code assumes one profile per email. *(impl note)*
- [ ] **`sos_events` table doesn't exist** — migration 0002 (after the patch) no longer references it. When the Safety SOS server write is wired, create the table with `FORCE RLS` in the same migration. *(privacy-audit #03)*
- [ ] **`web/lib/data.ts` joins** — verify the `host_handle` denormalization is being populated when events are inserted; index added in `0003` but if the column is mostly null the index is wasted. *(perf-audit #09)*

---

## CI / build / release

- [ ] **Android release `signingConfig`** — `app/build.gradle.kts` has no signing block; `assembleRelease` is unsigned. *(ci-audit #04)*
- [ ] **Commit Gradle wrapper** — `android/gradle/wrapper/gradle-wrapper.jar` not in repo; CI generates on-the-fly. *(ci-audit #10)*
- [ ] **`Gemfile` + `Gemfile.lock` for fastlane** — `Brewfile` installs fastlane via Homebrew (unpinned). Pin via Bundler. *(ci-audit #11)*
- [ ] **`Brewfile` pinning** — every formula is unpinned (xcodegen, swiftlint, gh, etc.). Use `brew bundle dump` + commit lockfile. *(ci-audit #24)*
- [ ] **`Package.resolved` checked in** — `Buzz.xcodeproj/` is gitignored; SPM resolves latest 2.x at build time. Either pin via `exactVersion` in `project.yml` or add an exception for the resolved file. *(ci-audit #03)*
- [ ] **`supabase/config.toml`** — run `supabase init`; commit `config.toml`; add `supabase db lint` to CI. *(ci-audit #15)*
- [ ] **CI runners pinned** — `ubuntu-latest` → `ubuntu-24.04`; `macos-15` is reasonably specific. *(ci-audit #09)*
- [ ] **Xcode pin** — `xcode-select -s /Applications/Xcode_16.app` is path-fragile; use `maxim-lobanov/setup-xcode` with `xcode-version: '16.x'`. *(ci-audit #13)*
- [ ] **gitleaks scans history** — currently only scans working tree. Add `gitleaks git --redact` step. *(ci-audit #20)*
- [ ] **Branch protection on `main`** — currently any direct push triggers Supabase migration auto-apply. Require review + passing CI. *(ci-audit #22)*
- [ ] **`mac_release` lane scheme** — currently uses iOS scheme which includes BuzzTests (iOS-only); use a `Buzz-macOS` scheme. *(ci-audit #21)*
- [ ] **Rollback lane** — no documented `fastlane rollback` / `vercel rollback` runbook. *(ci-audit #23)*
- [ ] **Android `versionCode` automation** — currently hardcoded `versionCode = 1`; wire to `GITHUB_RUN_NUMBER`. *(ci-audit #18)*
- [ ] **`ENABLE_USER_SCRIPT_SANDBOXING: NO`** — re-enable in `project.yml` + fix any failing script phases. *(ci-audit #19)*
- [ ] **`PrivacyInfo.xcprivacy` Name + OtherUserContent** — declare `NSPrivacyCollectedDataTypeName` (real names in profile) and `OtherUserContent` (event titles, bios). *(ci-audit #07)*
- [ ] **`PrivacyInfo.xcprivacy` boot-time justification** — `35F9.1` declared but no `mach_absolute_time` / `systemUptime` call found; identify which SDK uses it or drop the declaration. *(ci-audit #14)*
- [ ] **Info.plist `NSLocationAlwaysAndWhenInUseUsageDescription` cleanup** — declared + `UIBackgroundModes: location` set but `LocationService` only calls `requestWhenInUseAuthorization`. Either remove the key or implement Always intentionally. *(ci-audit #08)*
- [ ] **`fastlane/Fastfile` `skip_screenshots: true`** — flip to `false` once screenshots exist in `fastlane/screenshots/`. *(ci-audit #05)*
- [ ] **`fastlane/Fastfile` `skip_waiting_for_build_processing: true`** — TestFlight uploads can silently fail without notification. Add a wait step or webhook ping. *(ci-audit #06)*
- [ ] **Web `.env.local` real keys** — re-verify gitignore is preventing the file from staging; rotate keys if they were ever committed. *(ci-audit #01)*
- [ ] **Web `.vercel/.env.development.local` OIDC token on disk** — confirm it's untracked; consider scoping `vercel env pull` so the OIDC token doesn't land on disk at all. *(ci-audit #02)*

---

## Observability

- [ ] **Sentry iOS** — wire `SentrySDK.start` in `BuzzApp.init` with `SecretsLoader.value(.sentryDSN)`. *(prod-audit #17)*
- [ ] **Sentry / Crashlytics Android** — pick one; init in `BuzzApplication.onCreate`. *(prod-audit #18)*
- [ ] **Sentry web** — `app/error.tsx` currently `console.error`s only. Wire `@sentry/nextjs`. *(prod-audit #16)*
- [ ] **Structured error context everywhere** — add `profile_id`, `event_id`, route, action to every breadcrumb so Sentry events are actionable. PII-strip per privacy audit. *(prod-audit #29)*

---

## Cross-platform / honesty

- [ ] **`mockEvents` / `mockOrgs` removed from production paths** — currently iOS `AppServices` defaults to `MockEventRepository`, web `sitemap.ts` reads mock, `app/api/poster/[id]` imports mock. Switch all to real Supabase queries when env vars are present; mock only when `NODE_ENV !== "production"`. *(design-audit cross-cut)*
- [ ] **Cross-platform category enum** — iOS has `arts`, `music`, `study`, `wellness`; web doesn't. Reconcile or document the mapping with fallback. *(tokens-audit #21)*
- [ ] **Tokens generator alpha handling** — `accent_dim: "#22FFD60A"` loses the `22` alpha byte in `hexToSwiftRGB`. Emit `Color(...).opacity(Double(0x22)/255.0)` instead. *(tokens-audit #16, #22)*
- [ ] **Apple IAP §3.1.1 risk for tickets** — physical-event exemption (§3.1.3(b)) requires clear metadata that tickets are for in-person events; consider routing checkout via Safari instead of `ASWebAuthenticationSession`. *(payments-audit #18)*
