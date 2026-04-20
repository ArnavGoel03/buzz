# Security Policy

## Reporting a vulnerability

Please email **security@buzz.app** (or open a private advisory on GitHub) with:

- A description of the issue
- Steps to reproduce
- Potential impact
- Whether you'd like to be credited in the fix release

We aim to respond within 48 hours and ship a fix within 14 days for critical issues.

**Please do not** open public issues or PRs for vulnerabilities.

## What's in scope

- The iOS app (Buzz)
- The Android app (when shipped)
- The Supabase backend (RLS policies, schema, triggers, edge functions)
- Any official Buzz infrastructure

Out of scope: social engineering, physical access attacks, DoS of the live service.

## Security practices (internal)

- All secrets live in `Secrets.plist` (gitignored) and CI secrets; never in source.
- Auth tokens stored in iOS Keychain with `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`; no iCloud sync.
- Every Supabase table has row-level security. Transfer history (`campus_affiliations`) is owner-only.
- Membership writes are restricted to org Presidents/Founders via RLS; every change is recorded in an append-only audit log.
- Campus references are foreign-key-enforced against a closed registry — no user-input variants.
- gitleaks runs on every PR.
- Sub-campus values validated by DB trigger against the parent campus's registered list.
