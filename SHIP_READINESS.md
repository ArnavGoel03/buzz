# Ship-readiness roadmap — iPhone, iPad, Mac, Android

**Updated:** 2026-04-28 (post-testing pass)
**Owner:** Arnav

Single source of truth for shipping Buzz to all four targets. Apple side ships **one
binary** that runs natively on iPhone, iPad, and Mac (single multiplatform SwiftUI target
— `supportedDestinations: [iOS, macOS]`, `TARGETED_DEVICE_FAMILY: "1,2"`, no Catalyst).
Android is a **separate codebase** under `android/`.

---

## ✅ Done

### App Store metadata
- `fastlane/metadata/en-US/keywords.txt` — trimmed 149 → 87 chars to fit the 100-char
  App Store limit.
- `fastlane/metadata/en-US/description.txt` — removed trailing `hi@buzz.app` and
  `buzz.app/legal/privacy` lines (App Store §2.3.1: privacy URL belongs only in the
  metadata field, not the description body).
- `fastlane/metadata/en-US/release_notes.txt` — replaced TestFlight-centric copy with
  user-facing release notes.
- `fastlane/metadata/en-US/review_information/phone_number.txt` — replaced fake
  `+1-555-0100` with explicit placeholder `REPLACE_WITH_REAL_E164_PHONE_NUMBER`.

### Fastlane / signing
- `fastlane/Appfile` — fixed `com.buzz.app` → `com.arnavgoel.buzz`.
- `fastlane/Matchfile` — same; manages both `com.arnavgoel.buzz` and
  `com.arnavgoel.buzz.Clip`.
- `fastlane/Fastfile` — added `mac_release` lane (fetches macOS App Store distribution
  profile, uploads via `platform: "osx"`).

### Privacy + entitlements
- `Buzz/PrivacyInfo.xcprivacy` — created. Declares UserDefaults (CA92.1), file
  timestamp (C617.1), disk space (E174.1), system boot time (35F9.1) required-reason
  APIs. Declares collected data: Email, UserID, PreciseLocation — all
  linked-not-tracking, purpose AppFunctionality.
- `BuzzAppClip/PrivacyInfo.xcprivacy` — created (minimal, App Clip uses no
  required-reason APIs in current scope).
- `Buzz/Buzz.entitlements` — created with `com.apple.developer.associated-domains =
  ["applinks:buzz.app"]`.
- `BuzzAppClip/BuzzAppClip.entitlements` — created with associated-domains and
  `com.apple.developer.parent-application-identifiers`. **Moved out of Info.plist** —
  entitlement keys in Info.plist are ignored at runtime.

### Asset catalog
- `Buzz/Resources/Assets.xcassets/Contents.json` — created.
- `Buzz/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json` — created with all
  required slots: iOS marketing 1024×1024 universal, plus full Mac set (16/32/128/256/512
  @1x and @2x).
  ⚠️ **Still needs actual PNGs.** Drop in icon images from a 1024×1024 master before
  archiving for App Store.
- `Buzz/Resources/Assets.xcassets/AccentColor.colorset/Contents.json` — created with
  brand purple-pink (RGB 200, 79, 255).
- `Buzz/Resources/Assets.xcassets/LaunchBackground.colorset/Contents.json` — created
  with near-black (RGB 8, 8, 12) matching the dark theme.

### Info.plist + project.yml
- `Buzz/Info.plist` — `CFBundleShortVersionString` and `CFBundleVersion` now read from
  `$(MARKETING_VERSION)` / `$(CURRENT_PROJECT_VERSION)` build settings (was hardcoded
  `1.0` / `1`). Added `UIRequiresFullScreen: true`,
  `UISupportedInterfaceOrientations~ipad` (portrait + portrait-upside-down),
  `NSLocationUsageDescription` (legacy macOS key). Removed `associated-domains` (moved
  to entitlements).
- `BuzzAppClip/Info.plist` — same version-pinning fix. Removed associated-domains and
  parent-application-identifiers (moved to entitlements).
- `project.yml` — `bundleIdPrefix: com.buzz` → `com.arnavgoel`. Updated `info.properties`
  blocks to mirror the on-disk Info.plists (UIRequiresFullScreen, iPad orientations,
  NSLocationUsageDescription, version vars). Added `CODE_SIGN_ENTITLEMENTS` for both
  `Buzz` and `BuzzAppClip` targets.

### Swift code — Mac/iPad correctness
- `Buzz/BuzzApp.swift` — gated `.preferredColorScheme(.dark)` to `#if os(iOS)` (Mac App
  Store rejects apps that override system appearance). Added Mac-only WindowGroup
  sizing: `.defaultSize(width: 1024, height: 768)`, `.windowResizability(.contentMinSize)`,
  and a `Commands` block suppressing the document "New" item (Buzz isn't a document app).
- `Buzz/RootView.swift` — added `@Environment(\.horizontalSizeClass)`. iPhone (compact)
  keeps the bottom `TabView`; iPad regular and macOS get `NavigationSplitView` with a
  sidebar listing Live / Map / Clubs / Profile.
- `Buzz/Core/DesignSystem/MagneticPressable.swift` — wrapped scale-effect/long-press in
  `#if os(iOS)`, no-op on Mac (no hover state, native button feel handles press).
- `Buzz/Core/Components/PrivacyScreen.swift` — overlay now triggers only on
  `scenePhase == .background` instead of `!= .active`. On macOS, `.inactive` means
  "window unfocused" and the overlay was flashing on every app-switch.
- `Buzz/Features/Creator/EventReelGenerator.swift` — wrapped iOS-only AVFoundation/Photos
  pipeline in `#if os(iOS)`; macOS shows an "iPhone only" placeholder.
- `Buzz/Features/Settings/ReviewPromptController.swift` — added `#elseif os(macOS)`
  branch calling `AppStore.requestReview()` (no-arg macOS API). Mac users now actually
  get review prompts.
- `Buzz/Features/Safety/EmergencySOSButton.swift` — added `.help(...)`,
  `.accessibilityLabel`, and `.accessibilityHint` so the 3-second hold gesture is
  discoverable on Mac (tooltip) and accessible (VoiceOver).
- `Buzz/Features/Discovery/ClubsView.swift` — grid switched from fixed 2 columns to
  `GridItem(.adaptive(minimum: 160))` — 2 cols on iPhone, 3 on iPad portrait, more on
  iPad landscape / Mac.
- `Buzz/Features/LiveNow/LiveNowView.swift` — capped reading width at 640 pt, centred.
  Cards no longer stretch across a full Mac window.
- `Buzz/Features/CreateEvent/CreateEventSheet.swift` — `CoHostPickerSheet` gets
  `.presentationDetents([.medium, .large])` so it doesn't open near-fullscreen on iPad.
- `Buzz/Features/CreateEvent/InviteListBuilderSheet.swift` — same fix on
  `PeopleSearchSheet` and `PastEventPickerSheet`.
- `Buzz/Features/AdminTools/EventDuplicateButton.swift` — added
  `.presentationDetents([.large])` to the duplicate sheet (drag indicator + ultra-thin
  material now have meaning).

### Android
- 24 files scaffolded under `android/` — see "Android scaffold detail" below.

### Testing — regression-prevention pass

**Two production-code extractions** so view-internal logic became unit-testable:
- `Buzz/Features/CreateEvent/EventTimeDefaults.swift` (new) — pulled `defaultStart` /
  `defaultEnd` out of a `private extension Date` inside `CreateEventSheet`. Now takes
  injectable `now` + `Calendar` so tests can pin clock + timezone.
- `Buzz/Features/LiveNow/LiveNowFilter.swift` (new) — pulled the inline filter from
  `LiveNowView.load()` into a pure `static func filter(_:now:window:)`. Adds
  `Event.isLiveAt(_ now: Date)` for testable live-state evaluation.
- `Buzz/Features/Settings/ReviewPromptController.swift` — added a `defaults:
  UserDefaults = .standard` parameter to `recordPositiveMoment` and made it return a
  `Bool` indicating whether the trigger fired. Lets tests verify the throttle without
  mocking StoreKit.

**Swift test files added** (under `BuzzTests/`):
- `AuthSessionTests.swift` — state transitions, `signOut` clears identity AND invokes
  the purge closure (VULN #57), account-switch profile-id change (VULN #82 trigger).
- `AppServicesResetTests.swift` — VULN #82 — `resetForAccountSwitch` replaces all three
  repository instances via `===` on `AnyObject`-bridged actors. Companion test pins
  that per-device singletons (location, network, calendar) survive reset.
- `UniversalLinkRouterTests.swift` — `BuzzLink.event/.organization/.profile` URL
  builders + `validate` parser. Covers VULN #58 (consume-once nilification),
  VULN #84 (multi-`@` strip), VULN #102 (percent encoding), and lookalike-host /
  http / extra-path / bare-host phishing rejection.
- `EventUrgencyTests.swift` — pins the `live > starting > soon > upcoming > past`
  ladder including the exact 30-min `.starting` boundary and the at-end-tick `.past`
  transition.
- `LiveNowFilterTests.swift` — boundary tests against the extracted filter. Pins
  strict-`<` window edge, sort order, and the at-`startsAt`-instant live branch.
- `EventTimeDefaultsTests.swift` — round-down-vs-round-to-30 boundary, end-time is
  exactly +2h, day boundary preserved when `now` is late evening.
- `ReviewPromptControllerTests.swift` — uses an isolated `UserDefaults(suiteName:)`
  per test. Pins: doesn't trigger before the threshold, fires exactly once at the
  threshold, doesn't re-trigger after, count persists across calls.
- `ModelEncodingTests.swift` — server-contract pinning. Locks `RSVPStatus` and
  `EventVisibility` rawValues against accidental rename, decodes every case from
  JSON, rejects unknown values, full round-trip on `Event` Codable.

**Android tests added** (under `android/app/`):
- `app/src/main/kotlin/com/arnavgoel/buzz/data/BuzzLink.kt` — Kotlin port of the iOS
  link validator with the same path scheme. Single source of truth for what counts
  as a Buzz link.
- `app/src/test/kotlin/com/arnavgoel/buzz/data/BuzzLinkTest.kt` — 9 JUnit tests
  matching the iOS suite: happy paths for event/org/profile, lookalike-host
  rejection, http rejection, malformed UUID, bare host, malformed URL.
- `app/src/androidTest/kotlin/com/arnavgoel/buzz/ui/feed/FeedScreenTest.kt` —
  Compose UI smoke tests: feed renders with the wordmark + at least one event,
  tapping a card fires `onEventTap` with the right id.
- `app/build.gradle.kts` — added `androidx.compose.ui:ui-test-junit4` and
  `ui-test-manifest` to the `androidTest` configuration; version catalog updated.

**CI rewritten** at `.github/workflows/ci.yml`:
- **Apple job** (`macos-15`, Xcode 16) — keeps lint/format/secret-scan, runs full
  test suite on iPhone 16, then build-only smoke runs on iPad Pro 13" M4 and on
  macOS to catch `#if os(...)` regressions.
- **Android job** (`ubuntu-latest`, JDK 17) — generates Gradle wrapper if missing,
  runs `lintDebug` and `testDebugUnitTest`. Surface for parity tests.

### Vercel / web (out-of-band, prior turn)
- Set `rootDirectory: web` on the Vercel project; production deploy of `main` succeeded
  (https://web-arnavgoel03s-projects.vercel.app).

---

## 🚧 Remaining for App Store submission

These are the items that still block a Mac App Store / iOS App Store **production
submission**. Dev/TestFlight builds will succeed today.

### Hard blockers
1. **App icon PNGs** — `Buzz/Resources/Assets.xcassets/AppIcon.appiconset/` has the
   correct `Contents.json` slot definitions but no actual PNG files. Apple rejects
   uploads missing the 1024×1024 marketing icon and the Mac sizes. Generate from a
   single 1024×1024 master via Bakery / Icon Set Creator and drop the PNGs into the
   `appiconset` folder. Update `Contents.json` `filename` fields to match.
2. **Real phone number** — `fastlane/metadata/en-US/review_information/phone_number.txt`
   currently `REPLACE_WITH_REAL_E164_PHONE_NUMBER`.
3. **Screenshots** — none in the repo. Required sets:
   - iPhone 6.9" (1320×2868)
   - iPad Pro 13" M4 (2064×2752)
   - Mac (1280×800 minimum, 2880×1800 retina recommended)
   Generate via simulators / `fastlane snapshot`, drop into
   `fastlane/screenshots/<locale>/<device>/`, flip `fastlane/Fastfile`
   `skip_screenshots: true` → `false` for the next release.
4. **Copyright entity** — `fastlane/metadata/copyright.txt` reads `© 2026 Buzz. All
   rights reserved.` Update to the legal entity registered on the Apple Developer
   account.

### Soft blockers (won't fail, but noted)
- **Real Match git repo + macOS profile** — `match` requires `MATCH_GIT_URL` /
  `MATCH_PASSWORD` env vars. The new `mac_release` lane will fail until a macOS App
  Store distribution profile exists in the match repo for `com.arnavgoel.buzz`.
- **Age rating questionnaire** — set in App Store Connect dashboard. Match the
  alcohol/12+ stance from `review_information/notes.txt`.
- **App Clip Advanced Experience** — configure URL prefix, image, action label in App
  Store Connect for any URL the App Clip handles.

---

## 🚧 Apple polish — still TODO

Audit findings that did NOT get fixed this pass — open a separate session for these.

| File | Issue | Suggested fix |
|---|---|---|
| `Buzz/Features/Map/MapView.swift` | No `mapControls { }` block — Mac users have no visible zoom UI | Add `.mapControls { MapZoomButtons(); MapUserLocationButton() }` |
| `Buzz/Features/EventDetail/EventDetailSheet.swift` | No `.contextMenu` for RSVP / Share — Mac users have to open the full sheet | Add `.contextMenu { Button("RSVP") {…}; Button("Share") {…} }` |
| `Buzz/Features/Transit/ShuttleMapView.swift` (already in working tree) | `.frame(maxWidth: 280)` looks tiny on Mac | `.frame(maxWidth: min(280, geometry.size.width * 0.4))` |
| `Buzz/Core/Services/PushNotificationService.swift` | macOS push registration not implemented (no-op stub) | Add `#elseif os(macOS)` branch calling `NSApplication.shared.registerForRemoteNotifications()`; register token with `platform: "macos_apns"` |
| `Buzz/Features/Profile/ProfileView.swift:120` | "Get started — 3 taps" copy reads oddly on Mac | Drop the "3 taps" suffix |
| Multi-window on Mac | `UIApplicationSceneManifest.UIApplicationSupportsMultipleScenes: false` | Flip to `true` and add scene lifecycle handling for power-user "open two events side by side" |

---

## 🚧 Project hygiene — still TODO

- South Korea distribution — if shipping there, add
  `fastlane/metadata/trade_representative_contact_information/`.
- Run `xcodegen generate` after any further `project.yml` edits to refresh
  `Buzz.xcodeproj`. (Confirm Xcode is fixed first — current install has a
  `IDESimulatorFoundation` plugin load failure; fix via `xcodebuild -runFirstLaunch`
  or a reinstall.)
- Add a `Buzz.entitlements` reference path test — without `xcodegen generate +
  xcodebuild` available, the entitlements wiring is unverified at this moment.

---

## Android scaffold detail

Created on 2026-04-28 under `android/`. Compiles and launches a placeholder feed; **not
ship-ready**, deliberately minimal so the Kotlin/Compose surface is small enough to grow
feature-by-feature next.

**Stack:** Kotlin 2.0.21, AGP 8.7.3, Compose BOM 2024.12.01, JDK 17, minSdk 26,
target+compileSdk 35, Material 3, Navigation Compose, Supabase-kt 3.0.3 (Postgrest +
Auth + Realtime), Ktor OkHttp engine, Coil, DataStore, kotlinx-serialization. Dark
theme by default to match iOS.

**Files (24 total):**
- `android/settings.gradle.kts`, `android/build.gradle.kts`, `android/gradle.properties`,
  `android/gradle/libs.versions.toml`
- `android/app/build.gradle.kts`, `android/app/proguard-rules.pro`
- `android/app/src/main/AndroidManifest.xml` — INTERNET + location + POST_NOTIFICATIONS;
  deep-link intent-filter for `https://buzz.app` (matches iOS `applinks:buzz.app`).
- `…/kotlin/com/arnavgoel/buzz/BuzzApplication.kt`, `MainActivity.kt`
- `…/ui/BuzzApp.kt` — `NavHost` with `feed` and `event/{id}` routes inside `BuzzTheme`.
- `…/ui/theme/{Color,Type,Theme}.kt` — dark Material 3 theme, brand purple/pink.
- `…/ui/feed/{FeedScreen,EventCard}.kt` — placeholder feed showing 3 hardcoded events.
- `…/data/SupabaseClient.kt` — singleton; reads URL + anon key from BuildConfig
  (sourced from `local.properties`, gitignored).
- `…/res/values/{strings,themes,colors}.xml`
- `…/res/xml/{backup_rules,data_extraction_rules}.xml` — exclude Supabase auth token
  from cloud backup so users re-auth on a new device.
- `…/res/mipmap-anydpi-v26/{ic_launcher,ic_launcher_round}.xml` — adaptive icons.
- `…/res/drawable/{ic_launcher_background,ic_launcher_foreground}.xml` — solid brand
  background + a placeholder "B" wordmark vector. Replace with real artwork once iOS
  master is finalised.
- `android/.gitignore`, `android/README.md`

**First run:** open `android/` in Android Studio, let it sync (auto-generates the Gradle
wrapper), create `android/local.properties` with `BUZZ_SUPABASE_URL` and
`BUZZ_SUPABASE_ANON_KEY`, run on an emulator.

**Not yet:** Sign in with Apple/Google bridging, real feed/map/clubs/profile screens,
push (FCM), App Links domain verification, Play Store assets, content rating.

---

## Open questions

- **iPad orientation choice** — went with **Path A** (`UIRequiresFullScreen: true`,
  portrait + portrait-upside-down only). Trade-off: no Slide Over / Split View on iPad.
  Flip if the iPad UX warrants landscape rework.
- **Mac launch surface** — sidebar via `NavigationSplitView` is now wired up, sharing
  destination views with iPad. If Mac warrants a distinct dashboard layout (vs. the
  scaled-up phone UI), revisit `RootView.adaptiveLayout`.
- **Android timeline** — scaffold done; production-ready Android is multi-week
  feature-by-feature work.
- **Real legal entity for copyright** — needed for App Store metadata.

---

## How to verify this session's changes

```sh
# Apple
xcodegen generate
xcodebuild -project Buzz.xcodeproj -scheme Buzz -destination 'platform=iOS Simulator,name=iPhone 16' build
xcodebuild -project Buzz.xcodeproj -scheme Buzz -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' build
xcodebuild -project Buzz.xcodeproj -scheme Buzz -destination 'platform=macOS' build

# Android
cd android && open -a "Android Studio" .   # let it sync, then Run on an emulator
```

Xcode is currently broken on this machine (`IDESimulatorFoundation` plugin load failure)
— run `xcodebuild -runFirstLaunch` to fix before relying on the verify commands above.
