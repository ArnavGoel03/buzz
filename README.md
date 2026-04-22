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
- **Direct messages** — 1:1 DMs, event group chats, auto class-group chats
- **Streaks** — consecutive-week attendance, Snapchat-style flame counter
- **Stories** — photo strip from events; only attendees upload

### 🏛 Organizations
- Verified student orgs + **Buzz Official** (CAPS, Athletics, Dining, Safety, etc.)
- Profile with cover, logo, members, upcoming events, follow
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

### iOS + Mac
```bash
brew install xcodegen
cd /Users/arnavgoel/Documents/Buzz
xcodegen generate
open Buzz.xcodeproj
```
Pick an iPhone simulator, My Mac (Mac), or any iPad destination → Cmd+R.

### Web + PWA
```bash
cd /Users/arnavgoel/Documents/Buzz/web
npm install
npm run dev   # → http://localhost:3000
```

### Supabase
```bash
cd /Users/arnavgoel/Documents/Buzz
supabase init
supabase start
psql -h localhost -p 54322 -U postgres -d postgres -f supabase/schema.sql
```

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
  schema.sql                 # ~50 tables/views/triggers, RLS-locked end-to-end
```

---

## Roadmap (next moves)

**Ship TestFlight at UCSD** → first 100 users → iterate based on real engagement data. Everything else is already built; this is a "wire credentials + ship it" exercise.

1. Wire real Supabase project (SUPABASE_URL + anon key)
2. Replace SIWA / Google / email OTP stubs with real Supabase Auth calls
3. APNs p8 + FCM service account env vars
4. Stripe test-mode keys + Connect onboarding for first 3 paid-event orgs
5. Mailgun MX record for `events.buzz.app` → inbound-email route
6. VAPID keypair generation + env vars for web push
7. Deploy `web/` to Vercel, point `buzz.app` DNS
8. App Store + Mac App Store submissions
9. First ambassador at UCSD seeds 20 events for launch week

**File count: ~310** across iOS/Mac app + Next.js web + AppClip + Supabase schema. Single backend. Five surfaces. One product.
