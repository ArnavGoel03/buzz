# Buzz

[![CI](https://github.com/ArnavGoel03/buzz/actions/workflows/ci.yml/badge.svg)](https://github.com/ArnavGoel03/buzz/actions/workflows/ci.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

The all-in-one college companion. Live discovery, social network, club operating system, student marketplace, and safety layer — on iOS, macOS, and the web, backed by one Supabase.

> One profile for your entire college life, anywhere in the world. Handles transfers (incl. international), dual enrollment, study abroad, joint degrees, gap years, alumni, and faculty/staff. Profile creation is one-time; affiliations stack over time.

---

## Platforms

| Surface | Tech | Status |
|---|---|---|
| iOS + iPadOS | SwiftUI, iOS 17+ | ✅ Multiplatform single target |
| macOS | SwiftUI, macOS 14+ | ✅ Native (no Catalyst) |
| Web | Next.js 15, Tailwind 4 | ✅ Landing + link previews + admin dashboard |
| PWA (Android, Chromebook, any browser) | Service worker + manifest | ✅ Installable, push-capable, offline shell |
| App Clip | SwiftUI | ✅ Stubbed, wired for AirDrop/QR/NFC handoff |
| Android native | Jetpack Compose | 🟡 Deferred; PWA covers this until we have capacity |

## Stack

| Layer | Choice |
|---|---|
| Backend | Supabase (Postgres + PostGIS + Realtime + Storage + Auth) |
| Auth | Multi-provider: Apple, Google, email OTP, phone OTP, verified `.edu` as fallback |
| Map | MapKit (native both platforms) |
| Push | APNs + FCM + Web Push (VAPID), one fan-out endpoint |
| Payments | Stripe Connect (platform fee per transaction) |
| Email | Postmark/Mailgun inbound + Resend outbound |
| AR | ARKit + RealityKit (iOS-only gated) |
| CI/CD | GitHub Actions + Fastlane + Vercel |

---

## Feature set

Grouped by what they actually do for a student / club officer / campus.

### 🔍 Discovery
- **Live tab** (default) — events live or starting within 30 min, within walking distance, ranked by friend density + interests + history
- **Map** — color-coded pins by category, pulse on live events, live capacity gauge per event
- **Clubs** — search + category filters + trending rail + grid
- **Global search** — keyword across events, clubs, people
- **Daily digest** — morning briefing card + 8am push with top 3 events
- **For You feed** — personalization ranker weighs interests, friend graph, past check-ins, proximity, time fit
- **AR Look Around** — point phone at buildings, see anchored event pins
- **"Bored Right Now"** — one-tap live events within 10 min walk
- **Free Food beacon** — pinned banner + opt-in push for free food events
- **Event series** — multi-day programs (Homecoming, Orientation, Finals Wellness)

### 📆 Events
- One-tap RSVP with haptics + optimistic updates
- Auto-add to iOS Calendar on RSVP
- Shareable universal links (`buzz.app/e/<id>`)
- **4 visibility levels**: public / campus-only / invite-only / officers-only
- Anti-stalking: hide attendees toggle + anonymous RSVP
- Anti-spam: 200 concurrent RSVPs per user cap
- Past events auto-filtered; max event duration 14 days
- QR check-in at the door (officer side)
- Live event chat ("is the line still long?")
- **Tickets** (paid via Stripe Connect — Apple Pay, Apple Wallet-style QR)
- **Interest polls** — "would you go?" before officers commit to hosting
- **Event reels** — auto-generate 15s Story-format video from photos
- **Event playlists** — Spotify / Apple Music hookup per event
- Event photos / stories (attendees-only upload, RLS-verified)

### 🫂 Social
- **Friend graph** — mutual accept, "5 friends going" on every event card
- **Friend-face social proof** — `FriendsGoingBadge` shows actual friends' avatars + names (not vanity counts); RLS-gated server-side, respects `hide_attendees`
- **Direct messages** — 1:1 DMs, event group chats, auto class-group chats
- **Streaks** — consecutive-week attendance, Snapchat-style flame counter
- **Stories** — photo strip from events; only attendees upload
- **Time-density urgency bar** — 2px color stripe on every event card (LIVE / STARTING / SOON / UPCOMING / PAST), iOS + web in sync

### 🏛 Organizations
- Verified student orgs + **Buzz Official** (CAPS, Athletics, Dining, Safety, etc.)
- Profile with cover, logo, members, upcoming events, follow
- **External links** — sanitized Instagram + website pills on every org profile; schema.org `sameAs` in JSON-LD for cross-surface SEO
- **Buzzing dot** — pulsing accent on Club grid cards when the org has an event currently live or starting within 30 min (Discovery becomes "who's active tonight," not a static directory)
- Print-ready QR poster (replaces paper flyers)
- Per-org "paper saved" counter
- Tabling Mode full-screen display for club fairs

### 🎟 Club admin (force multipliers)
- **Mailto inbound** — forward event emails to `<handle>@events.buzz.app` → AI-parsed draft
- **Recurring events** (RRULE) + **templates** + **duplicate**
- **Co-hosting** (multi-org events)
- **CSV bulk member invite**
- **Auto-poster generator** (9:16 Story format)
- **Broadcast** (push + email blast, 5/24h per org)
- **Webhook relay** (Discord / Slack / generic)
- **Calendar import** (iCal/Google URL → drafts)
- **Analytics** — events, RSVPs, attendance, attend rate, best time to host
- **Ownership transfer wizard** (end-of-year handoff, logged)
- **Invite members flow** with search + role picker
- **Check-in scanner** (per-event QR)

### 🎓 Academic (Round 8)
- Class schedule import (paste or iCal)
- **Study buddies** — per-course ad-hoc sessions ("anyone in CSE 101 want to study tonight?")
- **Professor directory** — ratings, reviews, office-hours lookup
- **Course catalog** browse + description + credits
- In-app anonymous professor reviews (RateMyProfessor replacement)

### 🍽 Dining (Round 3)
- Dining hall menus by meal (breakfast / lunch / dinner / late night)
- Station-grouped items with dietary tags (vegan, gf, halal)
- "Friends eating here now" strip (opt-in presence)

### 🚐 Transit (Round 4)
- **Live shuttle positions** — realtime markers per route
- Route picker, per-stop ETA
- Replaces every janky third-party shuttle app

### 🚨 Safety (Round 2)
- **Emergency SOS** — 3-second hold, alerts campus safety + emergency contact
- **Safe Walk** — buddy tracking, escalates on no-arrival
- **Campus crime alerts** — severity-coded banner (info / caution / warning / emergency), Clery Act compatible

### 🏛 Greek life
- **Rush mode** — Panhellenic / IFC / Multicultural / NPHC / Professional
- Chapter grid, mutual-interest matching, round-by-round schedule
- Locks Buzz in for Greek-heavy campuses (SEC, Midwest)

### 💗 Wellness (Round 9)
- Private mood check-ins (5-point scale, owner-only RLS)
- Crisis resource surfacing when mood is low
- CAPS / 741741 one-tap links
- Resource directory per campus

### 📚 Student marketplace
- **Textbook exchange** — campus-scoped buy/sell by course code
- **Deals** — .edu-verified national + local merchant offers, category filters
- **Lost & Found** — photo-first, Lost/Found segmented

### 🎢 Interests + identity
- Interests picker in onboarding (3+ required) → drives ranker
- Per-badge visibility (students control what shows on profile)
- Tier-aware badges: Member (clean), Officer (emphasized), Prestige (holographic shimmer)
- Pending invite card requires user acceptance (consent-first)

### 🌱 Cold start / expansion (Round 1)
- **Invite codes** — viral share + leaderboard
- **Campus ambassadors** — seed supply per school
- **Campus waitlist** — capture demand on unsupported schools
- **iCal seeding** — pre-load from university event pages

### 🌐 Web / PWA
- Landing page + event/org/profile Open Graph previews
- **Apple App Site Association** (real universal links)
- **PWA install prompt** + offline shell + web push
- **Embed widget** for clubs to drop into their own websites (`<iframe>`)
- **Admin dashboard** for officer bulk ops

### 🛡 Safety + abuse prevention
- Report flow (spam, harassment, hate, dangerous, impersonation, underage, inaccurate, other)
- Moderation queue + audit log (append-only, never client-readable)
- Block users, per-campus broadcast caps, per-user RSVP caps, per-event invite caps
- **110+ red-team findings patched** across 22+ audit rounds
- **GDPR**: data export RPC, cascade-delete via `delete_my_account`
- **Session revoke everywhere** RPC
- App-switcher privacy screen
- Keychain tokens non-iCloud-sync, file-level encryption on offline cache

### 🔔 Notifications
- Push across APNs / FCM / Web Push (one fan-out endpoint)
- Event reminders: 24h / 1h / 15m before auto-seeded on publish
- Friend-going notifications
- Free food alerts (opt-in)
- Broadcast rate-limited 5/24h per org

### 🌎 Global
- 50+ campuses seeded across 12 countries (US, India, UK, Canada, AU, SG, DE, CH, JP, KR, MX, BR)
- Per-campus verification strategies (`eduOTP`, `institutionalEmailDomain`, `idCardScan`, `peerAttestation`, `manualReview`)
- Residential-college / hostel / house sub-campuses
- Multi-affiliation profiles for transfers, dual enrollment, study abroad

### 🌿 Sustainability
- Paper-saved counter on orgs + profile (flyers → sheets → trees)
- QR posters for clubs (one sign instead of stacks of flyers)

---

## Running it

### Prereqs (one time)
```bash
brew install xcodegen vercel-cli supabase/tap/supabase
```

### iOS + Mac
```bash
cd /Users/arnavgoel/Documents/Buzz
cp Buzz/Secrets.plist.example Buzz/Secrets.plist   # fill values (see "Backend setup" below)
xcodegen generate
open Buzz.xcodeproj
```
Pick an iPhone simulator, My Mac (Mac), or any iPad destination → Cmd+R. App boots against `MockEventRepository` by default — it's fully interactive without any backend. Swap `AppServices` init to `SupabaseEventRepository()` when you're ready to point at the live DB.

### Web + PWA
```bash
cd /Users/arnavgoel/Documents/Buzz/web
npm install
vercel link                    # one-time, links local dir to your Vercel project
vercel env pull .env.local     # pulls SUPABASE_* + any other integration-managed vars
npm run dev                    # → http://localhost:3000
```

### Supabase (local emulator for offline dev)
```bash
cd /Users/arnavgoel/Documents/Buzz
supabase start                                    # local Postgres + Auth + Storage + Realtime
psql -h localhost -p 54322 -U postgres -d postgres -f supabase/migrations/0000_initial_schema.sql
psql -h localhost -p 54322 -U postgres -d postgres -f supabase/migrations/0001_campus_waitlist.sql
```
Local emulator is optional — if you already have a dev project on supabase.com it's cheaper to just point at that.

---

## Backend setup (Supabase + Vercel)

The production backend is **one Supabase project** shared by iOS, the App Clip, the web app, and the PWA. RLS is on every table — the clients go direct, no middleman API.

### 1. Create the Supabase project

supabase.com → New Project. Settings that matter:

| Field | Value |
|---|---|
| Organization | `Buzz` |
| Project name | `buzz-prod` |
| Region | Closest to your users (launching at UCSD → **West US (North California)**) |
| Enable Data API | ✅ on (required for `supabase-js` / `supabase-swift`) |
| Auto-expose new tables | ❌ **off** — lock new tables down by default |
| Enable automatic RLS | ✅ **on** — any new table gets RLS enforcement on creation |
| Database password | Generate via dashboard, store in 1Password / keychain |

The project ref is the subdomain in your URL (e.g. `eadedtvmpucpoywbzqff`).

### 2. Apply the schema (via GitHub integration — no CLI login required)

Supabase dashboard → project → **Settings** → **Integrations** → **GitHub Integration** → **Enable**. Point at `ArnavGoel03/buzz` with working directory `.` and production branch `main`. Keep **Deploy to production** on.

Once enabled, Supabase watches `supabase/migrations/*.sql` on `main` and applies any new files on push. First push applies `0000_initial_schema.sql` (~50 tables, RLS policies, triggers, 110+ red-team patches) and `0001_campus_waitlist.sql` automatically.

For later migrations, just:
```bash
supabase migration new add_something      # creates a stamped file in migrations/
# edit the file
git add supabase/migrations/ && git commit -m "..." && git push origin main
```
Supabase auto-applies on push. Skip `supabase login` entirely.

### 3. Link Vercel to Supabase

In the Vercel dashboard → **Integrations** → **Supabase** → **Install**. Pick **"Link Existing Supabase Account"** (not "Create New / Vercel Native" — you want to own the Supabase project independently of your web host). Scope to just your `web` project. Complete OAuth.

Vercel auto-injects into your web env (Production + Preview + Development):
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`

Pull them locally so dev matches prod:
```bash
cd web
vercel env pull .env.local
```

**Security line**: `SUPABASE_SERVICE_ROLE_KEY` lives **only** in Vercel server env + your local `.env.local`. Never in iOS, never prefixed with `NEXT_PUBLIC_*`, never in a browser bundle. Server routes under `web/app/api/` (push fan-out, Stripe webhooks, inbound email) are the only consumers.

### 4. iOS / macOS credentials

The iOS app reads secrets from `Buzz/Secrets.plist` (gitignored) via `SecretsLoader.swift`. Two values needed:

```xml
<key>SUPABASE_URL</key>
<string>https://your-ref.supabase.co</string>
<key>SUPABASE_ANON_KEY</key>
<string>eyJhbGc...</string>
```

Grab both from Supabase dashboard → Settings → API. The anon key is safe to ship in the app binary — all privilege checks happen via RLS server-side.

Or, with the CLI:
```bash
supabase projects api-keys --project-ref <your-project-ref>
```

### 5. Other Vercel integrations (recommended order)

| Integration | When to enable |
|---|---|
| **Supabase** | Day one (above) — your backend |
| **Vercel Cron** (native, `vercel.json`) | Day one — runs `/api/reminders/process` + daily digest |
| **Stripe** | The day you flip ticketed events on |
| **Sentry** | TestFlight launch — unified iOS + web error visibility |
| **Upstash Redis** | When rate-limit load shows up in Postgres perf |
| **Resend** | Already in the stack for outbound email |

Skip Vercel AI, Neon (you're on Supabase Postgres — don't split), and Edge Config until you hit a specific need.

---

## Project layout

```
Buzz/                        # iOS + macOS app (multiplatform SwiftUI)
  Core/
    DesignSystem/            # Colors, Typography, Spacing, Haptics, PlatformModifiers
    Models/                  # Event, Organization, Profile, CampusAffiliation, Ticket, RushCycle, EventSeries, ...
    Services/                # Repositories (protocol + mock), AuthSession, PushNotificationService, CalendarService, EventRanker, ...
    Components/              # LoadingStateView, OfflineBanner, PrivacyScreen
    Utilities/               # BuzzLink, QRCode, PaperImpact, LoadingState, Retry
    Extensions/
  Features/
    Map, LiveNow, Clubs, EventDetail, Filters, Badges, Profile, Organization
    CreateEvent, Tabling, Auth, Onboarding, Friends, Streaks, Stories, Schedule
    Reporting, Membership, AdminTools, Tickets, Rush, AR
    Search, Series, Textbooks, StudyBuddies, Digest, LostFound
    ColdStart, Safety, Dining, Transit, ForYou, Messages, Deals, Academic, Wellness, Creator
  Resources/                 # mock*.json, en.lproj
BuzzAppClip/                 # iOS App Clip (instant-try, upsells full app)
BuzzTests/                   # XCTest unit tests
web/                         # Next.js 15 marketing site + PWA + admin dashboard
  app/                       # landing, /e/[id], /o/[handle], /u/[handle], /embed/o/[handle], /admin/[handle]
  app/api/                   # inbound-email, push/send, push/token, tickets/checkout, tickets/webhook,
                             #   calendar-import, broadcast, webhook-relay, poster/[id], reminders/process
  public/                    # sw.js, offline.html, manifest.webmanifest, .well-known/apple-app-site-association
  components/                # PWAInstaller
  lib/                       # supabase, parse-event-email, web-push
supabase/
  migrations/
    0000_initial_schema.sql  # ~50 tables/views/triggers, RLS-locked end-to-end (GitHub integration applies on push)
    0001_campus_waitlist.sql # waitlist table for unsupported campuses
```

---

## Roadmap (next moves)

**Ship TestFlight at UCSD** → first 100 users → iterate based on real engagement data. Everything else is already built; this is a "wire credentials + ship it" exercise.

- [x] Supabase project provisioned (`buzz-prod`, us-west-1, automatic RLS on, auto-expose off)
- [x] Vercel ↔ Supabase integration linked to the `web` project
- [x] Supabase ↔ GitHub integration enabled (auto-applies `migrations/*.sql` on push to `main`)
- [x] `SupabaseEventRepository` scaffold parallel to `MockEventRepository`
- [x] `Buzz/Secrets.plist` populated with `SUPABASE_URL` + anon key (gitignored)
- [ ] First push lands `0000_initial_schema.sql` + `0001_campus_waitlist.sql` against `buzz-prod`
- [ ] Vercel Root Directory set to `web` (dashboard → Settings → Build and Deployment)
- [ ] Flip `AppServices` init to `SupabaseEventRepository()` for staging builds
- [ ] Replace SIWA / Google / email OTP stubs with real Supabase Auth calls
- [ ] APNs p8 + FCM service account env vars
- [ ] Stripe test-mode keys + Connect onboarding for first 3 paid-event orgs
- [ ] Mailgun MX record for `events.buzz.app` → inbound-email route
- [ ] VAPID keypair generation + env vars for web push
- [ ] `buzz.app` DNS → Vercel
- [ ] App Store + Mac App Store submissions
- [ ] First ambassador at UCSD seeds 20 events for launch week

**File count: ~315** across iOS/Mac app + Next.js web + AppClip + Supabase schema. Single backend. Five surfaces. One product.
