# Changelog

All notable changes to Buzz. This project follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- Live event map (MapKit) with time + category filters, animated pins, live-pulse for in-progress events
- Dual-tier RSVP with haptics and optimistic updates
- Clubs discovery tab: search, category chips, trending rail, grid of org cards
- Organization profiles with hero, stats row, follow button, member list, upcoming events
- Student profiles with badge grid, per-badge visibility toggle, affiliation pills
- Tier-aware badge system: Member (clean) / Officer (emphasized) / Prestige (holographic shimmer)
- Multi-affiliation profile model supporting transfers (incl. international), dual enrollment,
  study abroad, joint degrees, gap years, alumni, faculty/staff, consortium cross-registration
- Closed Campus registry with 50+ seeded institutions across 12 countries, foreign-key enforced
- Multi-provider auth model (Apple + Google + email OTP + phone OTP) — no platform lock-in
- Supabase schema: PostGIS, RLS policies, audit log, validation triggers, membership role enforcement
- Secrets loader + Keychain token store for secure credential handling
- CI/CD via GitHub Actions: build, lint, format, secret scan, test
- SwiftLint + SwiftFormat configs; EditorConfig; Brewfile; Makefile
- Fastlane beta/release lanes; gitleaks secret scanning
- Unit tests covering model invariants and view model filtering
- Localization scaffold (en base)
