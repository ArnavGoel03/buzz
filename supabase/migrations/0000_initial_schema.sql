-- Initial schema — moved from supabase/schema.sql so the Supabase GitHub
-- integration picks it up on first push. Everything below was the monolithic
-- schema file; the campus_waitlist block at the old line 545-550 was removed
-- because migration 0001_campus_waitlist.sql owns the authoritative shape.

-- Buzz — Supabase schema
-- Postgres + PostGIS. Run after `supabase init && supabase start`.

create extension if not exists postgis;

-- ─── Campuses (seeded from IPEDS at production) ──────────────────────────────
create type public.campus_kind as enum (
  'communityCollege','fourYear','research','liberalArts','technical',
  'hbcu','hsi','tribal','religious','military','graduateOnly','onlineOnly'
);

create table if not exists public.campuses (
  id            text primary key,           -- slug, e.g. "ucsd"
  display_name  text not null,
  short_name    text not null,
  state         text not null,
  city          text not null,
  kind          public.campus_kind not null,
  domains       text[] not null default '{}',   -- .edu domains for OTP verification
  sub_campuses  jsonb not null default '[]',    -- array of {id, displayName}
  latitude      double precision,
  longitude     double precision,
  created_at    timestamptz not null default now()
);

create index if not exists campuses_domains on public.campuses using gin (domains);

-- ─── Profiles ─────────────────────────────────────────────────────────────────
create table if not exists public.profiles (
  id             uuid primary key references auth.users(id) on delete cascade,
  display_name   text not null,
  handle         text unique not null,
  pronouns       text,
  bio            text,
  avatar_url     text,
  accent_hex     text not null default '#FFD60A',
  primary_affiliation_id uuid,              -- fk set later via trigger
  created_at     timestamptz not null default now()
);

-- ─── Campus Affiliations ──────────────────────────────────────────────────────
-- Models transfers, dual enrollment, study abroad, joint degrees, faculty, alumni.
create type public.affiliation_role   as enum ('student','alumni','faculty','staff','visiting','exchange');
create type public.program_kind       as enum (
  'undergraduate','graduate','professional','doctoral','certificate',
  'continuingEd','dualEnrollment','studyAbroad','exchange','online'
);
create type public.affiliation_status as enum ('active','onLeave','paused','graduated','transferred','withdrawn');
create type public.academic_year      as enum ('freshman','sophomore','junior','senior','graduate','alumni');

create table if not exists public.campus_affiliations (
  id            uuid primary key default gen_random_uuid(),
  profile_id    uuid not null references public.profiles(id) on delete cascade,
  campus        text not null,
  sub_campus    text,
  role          public.affiliation_role not null,
  program       public.program_kind not null,
  status        public.affiliation_status not null,
  year          public.academic_year,
  major         text,
  minors        text[] not null default '{}',
  verified_at   timestamptz,
  start_date    date,
  end_date      date,
  created_at    timestamptz not null default now()
);

create index if not exists aff_profile on public.campus_affiliations (profile_id);
create index if not exists aff_campus  on public.campus_affiliations (campus);

alter table public.profiles
  add constraint profiles_primary_aff_fk
  foreign key (primary_affiliation_id) references public.campus_affiliations(id) on delete set null
  deferrable initially deferred;

-- ─── Organizations ────────────────────────────────────────────────────────────
create type public.org_category as enum (
  'academic','greek','cultural','professional','service','sports','arts',
  'religious','political','honor','interest'
);

create table if not exists public.organizations (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  handle        text unique not null,
  tagline       text not null default '',
  description   text not null default '',
  category      public.org_category not null,
  campus        text not null,
  founded_year  int,
  member_count  int not null default 0,
  logo_url      text,
  cover_url     text,
  accent_hex    text not null default '#FFD60A',
  is_verified   boolean not null default false,
  created_at    timestamptz not null default now()
);

create index if not exists orgs_campus on public.organizations (campus);

-- ─── Memberships (the badge assignments) ──────────────────────────────────────
create type public.membership_role as enum (
  'founder','president','captain',
  'vicePresident','treasurer','secretary','officer','lead',
  'member','alumni'
);

create type public.membership_status as enum (
  'pending','active','declined','revoked','resigned'
);

create table if not exists public.memberships (
  id              uuid primary key default gen_random_uuid(),
  profile_id      uuid not null references public.profiles(id) on delete cascade,
  organization_id uuid not null references public.organizations(id) on delete cascade,
  role            public.membership_role not null,
  status          public.membership_status not null default 'pending',  -- consent-first
  since           timestamptz not null default now(),
  ended_at        timestamptz,                  -- null while active
  is_visible      boolean not null default true,
  invited_by      uuid references public.profiles(id) on delete set null,
  unique (profile_id, organization_id, since),
  -- VULN #96 patch: pending invites must record who sent the invite.
  constraint mem_pending_has_inviter check (status <> 'pending' or invited_by is not null)
);

create index if not exists mem_profile on public.memberships (profile_id);
create index if not exists mem_org     on public.memberships (organization_id);

-- VULN #31 patch: only one open (pending or active) membership per (profile, org).
-- Stops invite-loop spam that fills audit log.
create unique index if not exists mem_one_open_per_org
  on public.memberships (profile_id, organization_id)
  where status in ('pending','active');

-- ─── Events ───────────────────────────────────────────────────────────────────
create type public.event_category as enum (
  'party','academic','sports','food','club','arts','music','study','wellness'
);

create table if not exists public.events (
  id              uuid primary key default gen_random_uuid(),
  title           text not null,
  summary         text not null default '',
  category        public.event_category not null,
  starts_at       timestamptz not null,
  ends_at         timestamptz not null,
  geo             geography(Point, 4326) not null,
  location_name   text not null,
  address         text,
  organization_id uuid references public.organizations(id) on delete set null,
  host_id         uuid references public.profiles(id) on delete set null,
  host_name       text not null,
  campus          text not null,
  sub_campus      text,                         -- "warren", "muir" — for residential college systems
  capacity        int,
  rsvp_count      int not null default 0,
  image_url       text,
  tags            text[] not null default '{}',
  is_official     boolean not null default false,
  created_at      timestamptz not null default now()
);

create index if not exists events_geo_idx    on public.events using gist (geo);
create index if not exists events_starts_at  on public.events (starts_at);
create index if not exists events_campus     on public.events (campus);
create index if not exists events_sub_campus on public.events (sub_campus);
create index if not exists events_org        on public.events (organization_id);

-- ─── RSVPs ────────────────────────────────────────────────────────────────────
create type public.rsvp_status as enum ('notGoing','interested','going');

create table if not exists public.rsvps (
  user_id    uuid not null references public.profiles(id) on delete cascade,
  event_id   uuid not null references public.events(id) on delete cascade,
  status     public.rsvp_status not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, event_id)
);

create index if not exists rsvps_event on public.rsvps (event_id);

-- ─── Triggers: keep counts in sync ────────────────────────────────────────────
create or replace function public.refresh_rsvp_count() returns trigger
language plpgsql as $$
begin
  update public.events set rsvp_count = (
    select count(*) from public.rsvps
    where event_id = coalesce(new.event_id, old.event_id) and status = 'going'
  ) where id = coalesce(new.event_id, old.event_id);
  return null;
end $$;

drop trigger if exists trg_refresh_rsvp_count on public.rsvps;
create trigger trg_refresh_rsvp_count
after insert or update or delete on public.rsvps
for each row execute function public.refresh_rsvp_count();

-- VULN #32 patch: only ACTIVE memberships count toward an org's public member count.
-- Pending invites should never inflate the displayed total.
create or replace function public.refresh_member_count() returns trigger
language plpgsql as $$
begin
  update public.organizations set member_count = (
    select count(*) from public.memberships
    where organization_id = coalesce(new.organization_id, old.organization_id)
      and status = 'active' and ended_at is null
  ) where id = coalesce(new.organization_id, old.organization_id);
  return null;
end $$;

drop trigger if exists trg_refresh_member_count on public.memberships;
create trigger trg_refresh_member_count
after insert or update or delete on public.memberships
for each row execute function public.refresh_member_count();

-- ─── Geo query helper ─────────────────────────────────────────────────────────
-- VULN #56 patch: clamp `radius_m` to 50km. A bad client passing 5e7 would otherwise
-- trigger a global table scan against PostGIS — both DoS and unintended over-disclosure.
create or replace function public.events_near(
  lat double precision, lng double precision, radius_m double precision
) returns setof public.events language sql stable as $$
  select * from public.events
  where st_dwithin(
          geo,
          st_makepoint(lng, lat)::geography,
          least(coalesce(radius_m, 5000), 50000)
        )
    and ends_at >= now()
  order by starts_at asc
  limit 500;
$$;

-- ─── Campus reference integrity (closed registry, no free-form entries) ──────
-- Every campus reference must point at a row in the campuses registry. This prevents
-- users from typing "UCSD" vs "UC San Diego" vs "ucsd" and ending up with three
-- competing variants. Missing colleges go through an admin review queue (see
-- public.campus_requests), never user input.
alter table public.campus_affiliations
  add constraint affil_campus_fk
  foreign key (campus) references public.campuses(id) on delete restrict;

alter table public.organizations
  add constraint orgs_campus_fk
  foreign key (campus) references public.campuses(id) on delete restrict;

alter table public.events
  add constraint events_campus_fk
  foreign key (campus) references public.campuses(id) on delete restrict;

-- Validate sub_campus is one of the campus's registered sub_campuses (residential
-- colleges, hostels, houses). Free strings rejected.
-- VULN #70 patch: previously, if the campus had NO defined sub_campuses (like UCLA, MIT,
-- Stanford), the trigger short-circuited and allowed ANY non-null sub_campus value. Now
-- we explicitly reject sub_campus on campuses that don't define any.
create or replace function public.validate_sub_campus() returns trigger
language plpgsql as $$
declare valid_subs jsonb;
begin
  if new.sub_campus is null then return new; end if;
  select sub_campuses into valid_subs from public.campuses where id = new.campus;
  if valid_subs is null or jsonb_array_length(valid_subs) = 0 then
    raise exception 'campus "%" has no sub_campuses; sub_campus must be null', new.campus;
  end if;
  if not exists (select 1 from jsonb_array_elements(valid_subs) e where e->>'id' = new.sub_campus) then
    raise exception 'sub_campus "%" is not registered for campus "%"', new.sub_campus, new.campus;
  end if;
  return new;
end $$;

drop trigger if exists trg_validate_sub_campus_aff on public.campus_affiliations;
create trigger trg_validate_sub_campus_aff
before insert or update on public.campus_affiliations
for each row execute function public.validate_sub_campus();

drop trigger if exists trg_validate_sub_campus_evt on public.events;
create trigger trg_validate_sub_campus_evt
before insert or update on public.events
for each row execute function public.validate_sub_campus();

-- Request queue for missing colleges. Users submit; admins review + insert into campuses.
create table if not exists public.campus_requests (
  id              uuid primary key default gen_random_uuid(),
  requester_id    uuid references public.profiles(id) on delete set null,
  proposed_name   text not null,
  proposed_country text not null,
  evidence_url    text,                        -- link to campus website / accreditation page
  status          text not null default 'pending',  -- 'pending' | 'approved' | 'rejected'
  reviewed_at     timestamptz,
  created_at      timestamptz not null default now()
);

-- ─── Auth identities (multi-provider, no platform lock-in) ────────────────────
-- A profile can link many providers (Apple, Google, email OTP, phone). Switching from
-- iPhone to Samsung means signing in with Google or email — same profile, same badges.
-- Verified `.edu` addresses from `campus_affiliations` are also accepted as fallback
-- email-OTP identities, so losing every OAuth provider still leaves a path back in.
create type public.auth_method as enum ('apple','google','emailOTP','phoneOTP');

create table if not exists public.auth_identities (
  id               uuid primary key default gen_random_uuid(),
  profile_id       uuid not null references public.profiles(id) on delete cascade,
  method           public.auth_method not null,
  provider_subject text not null,                -- Apple user id, Google sub, email, phone
  display_label    text,
  linked_at        timestamptz not null default now(),
  last_used_at     timestamptz,
  unique (method, provider_subject)
);

create index if not exists auth_identities_profile on public.auth_identities (profile_id);

-- ─── Club-admin force multipliers ────────────────────────────────────────────
-- These tables make life easier for the people creating events / running orgs.
-- Clubs are the supply side: if they can post events in 10 seconds instead of 2 minutes,
-- students get more to discover, more often.

-- Co-hosting: a single event can be attributed to multiple orgs (joint mixers,
-- multi-club fests). Each co-host's officers can edit. Appears in each org's feed.
create table if not exists public.event_co_hosts (
  event_id        uuid not null references public.events(id) on delete cascade,
  organization_id uuid not null references public.organizations(id) on delete cascade,
  added_by        uuid references public.profiles(id) on delete set null,
  added_at        timestamptz not null default now(),
  primary key (event_id, organization_id)
);
create index if not exists ech_org on public.event_co_hosts (organization_id);

alter table public.event_co_hosts enable row level security;
create policy "ech_read" on public.event_co_hosts for select using (auth.role() = 'authenticated');
create policy "ech_write" on public.event_co_hosts for all using (
  exists (
    select 1 from public.memberships m
    where m.organization_id = event_co_hosts.organization_id
      and m.profile_id = auth.uid()
      and m.role in ('president','founder','vicePresident','officer')
      and m.status = 'active' and m.ended_at is null
  )
);

-- Check-ins: who actually showed up vs who RSVP'd. Officers scan a per-event QR at the
-- door (or the member presents their personal QR — both flows hit this table).
create table if not exists public.event_check_ins (
  event_id       uuid not null references public.events(id) on delete cascade,
  profile_id     uuid not null references public.profiles(id) on delete cascade,
  checked_in_at  timestamptz not null default now(),
  checked_in_by  uuid references public.profiles(id) on delete set null,
  method         text not null default 'qr',
  primary key (event_id, profile_id)
);
create index if not exists ci_event on public.event_check_ins (event_id);

alter table public.event_check_ins enable row level security;
create policy "ci_self_or_officer" on public.event_check_ins for select using (
  profile_id = auth.uid()
  or exists (
    select 1 from public.events e
    join public.memberships m on m.organization_id = e.organization_id
    where e.id = event_check_ins.event_id
      and m.profile_id = auth.uid()
      and m.role in ('president','founder','vicePresident','officer')
      and m.status = 'active' and m.ended_at is null
  )
);
create policy "ci_officer_write" on public.event_check_ins for insert with check (
  exists (
    select 1 from public.events e
    join public.memberships m on m.organization_id = e.organization_id
    where e.id = event_check_ins.event_id
      and m.profile_id = auth.uid()
      and m.role in ('president','founder','vicePresident','officer')
      and m.status = 'active' and m.ended_at is null
  )
);

-- Recurrence + templating: clubs duplicate events ("boba night" template) and automate
-- weekly meetings via RFC 5545 RRULE strings.
alter table public.events
  add column if not exists template_of_event_id uuid references public.events(id) on delete set null,
  add column if not exists recurrence_rule text,
  add column if not exists status text not null default 'published';

create index if not exists events_template on public.events (template_of_event_id);
create index if not exists events_status on public.events (status);

-- ═══ GROWTH ENGINE ════════════════════════════════════════════════════════════
-- The features below turn Buzz from "useful tool" into "daily-use network."

-- ─── Friend graph (mutual-follow) ────────────────────────────────────────────
-- Powers "5 friends going" social proof — the single biggest US college RSVP driver.
create table if not exists public.friendships (
  user_a       uuid not null references public.profiles(id) on delete cascade,
  user_b       uuid not null references public.profiles(id) on delete cascade,
  status       text not null default 'pending',  -- 'pending' | 'accepted' | 'blocked'
  initiated_by uuid not null references public.profiles(id) on delete cascade,
  created_at   timestamptz not null default now(),
  primary key (user_a, user_b),
  check (user_a < user_b)
);
create index if not exists fr_b on public.friendships (user_b);

alter table public.friendships enable row level security;
create policy "fr_visible_to_either" on public.friendships for select using (
  user_a = auth.uid() or user_b = auth.uid()
);
create policy "fr_initiate" on public.friendships for insert with check (
  initiated_by = auth.uid() and (user_a = auth.uid() or user_b = auth.uid())
);
create policy "fr_respond" on public.friendships for update using (
  user_a = auth.uid() or user_b = auth.uid()
);
create policy "fr_unfriend" on public.friendships for delete using (
  user_a = auth.uid() or user_b = auth.uid()
);

-- ─── Free food beacons (organic-growth driver) ───────────────────────────────
alter table public.events
  add column if not exists is_free_food boolean not null default false;
alter table public.profiles
  add column if not exists wants_free_food_alerts boolean not null default true;
create index if not exists profiles_free_food_alerts on public.profiles (wants_free_food_alerts);

-- ─── Stories / event photos ──────────────────────────────────────────────────
create table if not exists public.event_photos (
  id          uuid primary key default gen_random_uuid(),
  event_id    uuid not null references public.events(id) on delete cascade,
  uploader_id uuid not null references public.profiles(id) on delete cascade,
  storage_key text not null,
  caption     text check (caption is null or length(caption) <= 200),
  created_at  timestamptz not null default now()
);
create index if not exists ph_event on public.event_photos (event_id, created_at desc);

alter table public.event_photos enable row level security;
create policy "ph_visible_with_event" on public.event_photos for select using (
  exists (select 1 from public.events e where e.id = event_photos.event_id)
);
-- Only attendees can post (verified via check-in record). Stops randos.
create policy "ph_attendees_only" on public.event_photos for insert with check (
  uploader_id = auth.uid()
  and exists (
    select 1 from public.event_check_ins ci
    where ci.event_id = event_photos.event_id and ci.profile_id = auth.uid()
  )
);
create policy "ph_uploader_delete" on public.event_photos for delete using (uploader_id = auth.uid());

-- ─── Streaks (habit-formation gamification) ──────────────────────────────────
-- Counts consecutive ISO weeks with ≥1 check-in. Reset if you skip a week.
create or replace view public.user_streaks as
with weeks as (
  select profile_id, date_trunc('week', checked_in_at) as week
  from public.event_check_ins
  group by profile_id, date_trunc('week', checked_in_at)
),
ordered as (
  select profile_id, week,
         row_number() over (partition by profile_id order by week desc) as rn,
         week + (row_number() over (partition by profile_id order by week desc) || ' weeks')::interval as anchor
  from weeks
)
select profile_id, count(*) as current_streak
from ordered
group by profile_id, anchor
order by 1, 2 desc;

-- ─── Class schedule integration ──────────────────────────────────────────────
create table if not exists public.class_schedules (
  id          uuid primary key default gen_random_uuid(),
  profile_id  uuid not null references public.profiles(id) on delete cascade,
  course_code text not null,
  starts_at   timestamptz not null,
  ends_at     timestamptz not null,
  rrule       text,
  location    text,
  created_at  timestamptz not null default now()
);
create index if not exists cs_owner on public.class_schedules (profile_id);

alter table public.class_schedules enable row level security;
create policy "cs_owner_all" on public.class_schedules for all
  using (auth.uid() = profile_id) with check (auth.uid() = profile_id);

-- ─── Interest polls ──────────────────────────────────────────────────────────
create table if not exists public.interest_polls (
  id              uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  question        text not null check (length(question) between 5 and 200),
  proposed_at     timestamptz,
  proposed_loc    text,
  created_by      uuid not null references public.profiles(id) on delete cascade,
  created_at      timestamptz not null default now(),
  closes_at       timestamptz not null,
  yes_count       int not null default 0,
  no_count        int not null default 0,
  maybe_count     int not null default 0
);

create table if not exists public.interest_poll_votes (
  poll_id    uuid not null references public.interest_polls(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  vote       text not null check (vote in ('yes','no','maybe')),
  voted_at   timestamptz not null default now(),
  primary key (poll_id, profile_id)
);

alter table public.interest_polls       enable row level security;
alter table public.interest_poll_votes  enable row level security;
create policy "ip_read_authed" on public.interest_polls for select using (auth.role() = 'authenticated');
create policy "ip_create_officer" on public.interest_polls for insert with check (
  exists (
    select 1 from public.memberships m
    where m.organization_id = interest_polls.organization_id
      and m.profile_id = auth.uid()
      and m.role in ('president','founder','vicePresident','officer')
      and m.status = 'active' and m.ended_at is null
  )
);
create policy "ipv_self" on public.interest_poll_votes for all
  using (auth.uid() = profile_id) with check (auth.uid() = profile_id);

-- ═══ ROUND 1: COLD START ══════════════════════════════════════════════════════
create table if not exists public.invite_codes (
  code       text primary key check (length(code) between 4 and 16 and code ~ '^[a-z0-9]+$'),
  campus     text not null references public.campuses(id),
  created_by uuid references public.profiles(id) on delete set null,
  max_uses   int not null default 10 check (max_uses between 1 and 1000),
  uses       int not null default 0,
  expires_at timestamptz,
  created_at timestamptz not null default now()
);
alter table public.invite_codes enable row level security;
create policy "ic_read_authed" on public.invite_codes for select using (auth.role() = 'authenticated');
create policy "ic_create_self" on public.invite_codes for insert with check (auth.uid() = created_by);

create table if not exists public.campus_ambassadors (
  campus       text not null references public.campuses(id),
  profile_id   uuid not null references public.profiles(id) on delete cascade,
  appointed_at timestamptz not null default now(),
  primary key (campus, profile_id)
);
alter table public.campus_ambassadors enable row level security;
create policy "ca_read_authed" on public.campus_ambassadors for select using (auth.role() = 'authenticated');


-- ═══ ROUND 2: SAFETY ══════════════════════════════════════════════════════════
create table if not exists public.emergency_contacts (
  id         uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  name       text not null check (length(name) between 1 and 80),
  phone      text not null,
  relation   text,
  is_primary boolean not null default false
);
alter table public.emergency_contacts enable row level security;
create policy "ec_owner_all" on public.emergency_contacts for all
  using (auth.uid() = profile_id) with check (auth.uid() = profile_id);

create table if not exists public.safe_walks (
  id          uuid primary key default gen_random_uuid(),
  walker_id   uuid not null references public.profiles(id) on delete cascade,
  buddy_id    uuid references public.profiles(id) on delete set null,
  origin      geography(Point, 4326) not null,
  destination geography(Point, 4326) not null,
  status      text not null default 'active' check (status in ('active','arrived','sos','cancelled')),
  started_at  timestamptz not null default now(),
  ended_at    timestamptz
);
create index if not exists sw_walker on public.safe_walks (walker_id);
alter table public.safe_walks enable row level security;
create policy "sw_walker_or_buddy" on public.safe_walks for select using (
  auth.uid() = walker_id or auth.uid() = buddy_id
);
create policy "sw_walker_write" on public.safe_walks for all
  using (auth.uid() = walker_id) with check (auth.uid() = walker_id);

create table if not exists public.campus_safety_alerts (
  id         uuid primary key default gen_random_uuid(),
  campus     text not null references public.campuses(id),
  severity   text not null check (severity in ('info','caution','warning','emergency')),
  headline   text not null check (length(headline) between 5 and 200),
  body       text check (body is null or length(body) <= 2000),
  geo        geography(Point, 4326),
  source     text,
  expires_at timestamptz,
  created_at timestamptz not null default now()
);
create index if not exists csa_campus_time on public.campus_safety_alerts (campus, created_at desc);
alter table public.campus_safety_alerts enable row level security;
create policy "csa_read_campus" on public.campus_safety_alerts for select using (
  exists (select 1 from public.campus_affiliations a
          where a.profile_id = auth.uid() and a.campus = campus_safety_alerts.campus and a.status = 'active')
);

-- ═══ ROUND 3: DINING ══════════════════════════════════════════════════════════
create table if not exists public.dining_halls (
  id                 uuid primary key default gen_random_uuid(),
  campus             text not null references public.campuses(id),
  name               text not null,
  geo                geography(Point, 4326),
  hours              jsonb not null default '{}',
  meal_plan_accepted boolean not null default true
);
create table if not exists public.dining_menus (
  id             uuid primary key default gen_random_uuid(),
  dining_hall_id uuid not null references public.dining_halls(id) on delete cascade,
  served_on      date not null,
  meal           text not null check (meal in ('breakfast','lunch','dinner','latenight')),
  items          jsonb not null,
  unique (dining_hall_id, served_on, meal)
);
alter table public.dining_halls enable row level security;
alter table public.dining_menus enable row level security;
create policy "dh_read" on public.dining_halls for select using (auth.role() = 'authenticated');
create policy "dm_read" on public.dining_menus for select using (auth.role() = 'authenticated');

-- ═══ ROUND 4: TRANSIT ═════════════════════════════════════════════════════════
create table if not exists public.shuttle_routes (
  id        uuid primary key default gen_random_uuid(),
  campus    text not null references public.campuses(id),
  name      text not null,
  color_hex text not null default '#FFD60A' check (color_hex ~ '^#[0-9A-Fa-f]{6}$'),
  is_active boolean not null default true
);
create table if not exists public.shuttle_stops (
  id         uuid primary key default gen_random_uuid(),
  route_id   uuid not null references public.shuttle_routes(id) on delete cascade,
  name       text not null,
  geo        geography(Point, 4326) not null,
  stop_order int not null
);
create table if not exists public.shuttle_positions (
  vehicle_id text primary key,
  route_id   uuid references public.shuttle_routes(id) on delete set null,
  geo        geography(Point, 4326) not null,
  heading    real,
  updated_at timestamptz not null default now()
);
alter table public.shuttle_routes    enable row level security;
alter table public.shuttle_stops     enable row level security;
alter table public.shuttle_positions enable row level security;
create policy "sr_read" on public.shuttle_routes for select using (auth.role() = 'authenticated');
create policy "ss_stops_read" on public.shuttle_stops for select using (auth.role() = 'authenticated');
create policy "sp_read" on public.shuttle_positions for select using (auth.role() = 'authenticated');

-- ═══ ROUND 6: MESSAGES ════════════════════════════════════════════════════════
create table if not exists public.message_threads (
  id          uuid primary key default gen_random_uuid(),
  kind        text not null check (kind in ('dm','event_group','class_group')),
  event_id    uuid references public.events(id) on delete cascade,
  course_code text,
  campus      text references public.campuses(id),
  created_at  timestamptz not null default now()
);
create table if not exists public.message_thread_members (
  thread_id  uuid not null references public.message_threads(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  joined_at  timestamptz not null default now(),
  muted      boolean not null default false,
  primary key (thread_id, profile_id)
);
create table if not exists public.messages (
  id         uuid primary key default gen_random_uuid(),
  thread_id  uuid not null references public.message_threads(id) on delete cascade,
  author_id  uuid not null references public.profiles(id) on delete cascade,
  text       text not null check (length(text) between 1 and 2000),
  created_at timestamptz not null default now()
);
create index if not exists msg_thread_time on public.messages (thread_id, created_at desc);
alter table public.message_threads        enable row level security;
alter table public.message_thread_members enable row level security;
alter table public.messages               enable row level security;
create policy "mt_member_read" on public.message_threads for select using (
  exists (select 1 from public.message_thread_members mtm
          where mtm.thread_id = message_threads.id and mtm.profile_id = auth.uid())
);
create policy "mtm_self" on public.message_thread_members for all
  using (auth.uid() = profile_id) with check (auth.uid() = profile_id);
create policy "msg_member_read" on public.messages for select using (
  exists (select 1 from public.message_thread_members mtm
          where mtm.thread_id = messages.thread_id and mtm.profile_id = auth.uid())
);
create policy "msg_member_write" on public.messages for insert with check (
  auth.uid() = author_id
  and exists (select 1 from public.message_thread_members mtm
              where mtm.thread_id = messages.thread_id and mtm.profile_id = auth.uid())
);

-- ═══ ROUND 7: DEALS ═══════════════════════════════════════════════════════════
create table if not exists public.deals (
  id                uuid primary key default gen_random_uuid(),
  campus            text references public.campuses(id),
  merchant_name     text not null check (length(merchant_name) between 1 and 120),
  headline          text not null check (length(headline) between 3 and 120),
  body              text check (body is null or length(body) <= 1000),
  code              text,
  redeem_url        text,
  logo_url          text,
  starts_at         timestamptz,
  expires_at        timestamptz,
  category          text not null default 'food' check (category in ('food','apparel','software','entertainment','fitness','travel','other')),
  max_redemptions   int,
  total_redemptions int not null default 0
);
create table if not exists public.deal_redemptions (
  deal_id     uuid not null references public.deals(id) on delete cascade,
  profile_id  uuid not null references public.profiles(id) on delete cascade,
  redeemed_at timestamptz not null default now(),
  primary key (deal_id, profile_id)
);
alter table public.deals enable row level security;
alter table public.deal_redemptions enable row level security;
create policy "dl_read_authed" on public.deals for select using (auth.role() = 'authenticated');
create policy "dr_owner" on public.deal_redemptions for all
  using (auth.uid() = profile_id) with check (auth.uid() = profile_id);

-- ═══ ROUND 8: ACADEMIC ════════════════════════════════════════════════════════
create table if not exists public.professors (
  id         uuid primary key default gen_random_uuid(),
  campus     text not null references public.campuses(id),
  name       text not null check (length(name) between 2 and 120),
  department text,
  email      text,
  avatar_url text
);
create table if not exists public.courses (
  id          uuid primary key default gen_random_uuid(),
  campus      text not null references public.campuses(id),
  code        text not null,
  title       text not null,
  description text,
  credits     real,
  unique (campus, code)
);
create table if not exists public.office_hours (
  id           uuid primary key default gen_random_uuid(),
  professor_id uuid not null references public.professors(id) on delete cascade,
  course_id    uuid references public.courses(id) on delete set null,
  starts_at    timestamptz not null,
  ends_at      timestamptz not null,
  location     text,
  rrule        text
);
create table if not exists public.professor_reviews (
  id           uuid primary key default gen_random_uuid(),
  professor_id uuid not null references public.professors(id) on delete cascade,
  course_id    uuid references public.courses(id) on delete set null,
  author_id    uuid not null references public.profiles(id) on delete cascade,
  rating       int not null check (rating between 1 and 5),
  difficulty   int check (difficulty is null or difficulty between 1 and 5),
  text         text not null check (length(text) between 10 and 2000),
  is_anonymous boolean not null default true,
  created_at   timestamptz not null default now()
);
alter table public.professors        enable row level security;
alter table public.courses           enable row level security;
alter table public.office_hours      enable row level security;
alter table public.professor_reviews enable row level security;
create policy "prof_read" on public.professors for select using (auth.role() = 'authenticated');
create policy "course_read" on public.courses for select using (auth.role() = 'authenticated');
create policy "oh_read" on public.office_hours for select using (auth.role() = 'authenticated');
create policy "pr_read" on public.professor_reviews for select using (auth.role() = 'authenticated');
create policy "pr_author_write" on public.professor_reviews for all
  using (auth.uid() = author_id) with check (auth.uid() = author_id);

-- ═══ ROUND 9: WELLNESS ════════════════════════════════════════════════════════
create table if not exists public.wellness_checkins (
  id         uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  mood       text not null check (mood in ('great','good','ok','low','struggling')),
  note       text check (note is null or length(note) <= 500),
  created_at timestamptz not null default now()
);
alter table public.wellness_checkins enable row level security;
create policy "wc_owner" on public.wellness_checkins for all
  using (auth.uid() = profile_id) with check (auth.uid() = profile_id);

-- ═══ ROUND 10: CREATOR ════════════════════════════════════════════════════════
create table if not exists public.event_reels (
  id            uuid primary key default gen_random_uuid(),
  event_id      uuid not null references public.events(id) on delete cascade,
  creator_id    uuid not null references public.profiles(id) on delete cascade,
  video_key     text,
  thumbnail_key text,
  duration_sec  real,
  view_count    int not null default 0,
  created_at    timestamptz not null default now()
);
alter table public.event_reels enable row level security;
create policy "er_read" on public.event_reels for select using (auth.role() = 'authenticated');
create policy "er_creator_write" on public.event_reels for all
  using (auth.uid() = creator_id) with check (auth.uid() = creator_id);

create table if not exists public.event_playlists (
  id             uuid primary key default gen_random_uuid(),
  event_id       uuid not null references public.events(id) on delete cascade,
  spotify_id     text,
  apple_music_id text,
  name           text not null
);
alter table public.event_playlists enable row level security;
create policy "ep_read" on public.event_playlists for select using (auth.role() = 'authenticated');

-- ─── Interests (for personalization) ─────────────────────────────────────────
create table if not exists public.profile_interests (
  profile_id uuid not null references public.profiles(id) on delete cascade,
  category   public.event_category not null,
  weight     real not null default 1.0 check (weight >= 0 and weight <= 5.0),
  primary key (profile_id, category)
);
alter table public.profile_interests enable row level security;
create policy "pi_owner_all" on public.profile_interests for all
  using (auth.uid() = profile_id) with check (auth.uid() = profile_id);

-- ─── Event series (Orientation Week, Homecoming, Finals Wellness) ────────────
create table if not exists public.event_series (
  id          uuid primary key default gen_random_uuid(),
  campus      text not null references public.campuses(id),
  name        text not null check (length(name) between 3 and 80),
  description text check (description is null or length(description) <= 2000),
  cover_url   text,
  accent_hex  text not null default '#FFD60A' check (accent_hex ~ '^#[0-9A-Fa-f]{6}$'),
  starts_on   date not null,
  ends_on     date not null,
  organized_by_org uuid references public.organizations(id) on delete set null
);
create index if not exists es_campus on public.event_series (campus);
alter table public.events add column if not exists series_id uuid references public.event_series(id) on delete set null;
create index if not exists events_series on public.events (series_id);

alter table public.event_series enable row level security;
create policy "es_read_authed" on public.event_series for select using (auth.role() = 'authenticated');

-- ─── Textbook exchange ──────────────────────────────────────────────────────
create type public.textbook_condition as enum ('new','like_new','good','acceptable','annotated');

create table if not exists public.textbook_listings (
  id           uuid primary key default gen_random_uuid(),
  seller_id    uuid not null references public.profiles(id) on delete cascade,
  campus       text not null references public.campuses(id),
  isbn         text check (isbn is null or isbn ~ '^[0-9Xx\-]+$'),
  title        text not null check (length(title) between 2 and 200),
  author       text,
  edition      text,
  course_code  text,
  price_cents  int not null check (price_cents >= 0),
  condition    public.textbook_condition not null,
  photo_keys   text[] not null default '{}',
  status       text not null default 'available',
  created_at   timestamptz not null default now()
);
create index if not exists tb_campus_status on public.textbook_listings (campus, status);
create index if not exists tb_seller on public.textbook_listings (seller_id);
create index if not exists tb_course on public.textbook_listings (course_code);

alter table public.textbook_listings enable row level security;
create policy "tb_read_campus" on public.textbook_listings for select using (
  status <> 'sold'
  and exists (
    select 1 from public.campus_affiliations a
    where a.profile_id = auth.uid() and a.campus = textbook_listings.campus and a.status = 'active'
  )
);
create policy "tb_seller_write" on public.textbook_listings for all
  using (auth.uid() = seller_id) with check (auth.uid() = seller_id);

-- ─── Study buddies (per-course ad-hoc sessions) ──────────────────────────────
create table if not exists public.study_sessions (
  id           uuid primary key default gen_random_uuid(),
  organizer_id uuid not null references public.profiles(id) on delete cascade,
  course_code  text not null check (length(course_code) between 2 and 20),
  campus       text not null references public.campuses(id),
  starts_at    timestamptz not null,
  ends_at      timestamptz not null,
  location     text check (location is null or length(location) <= 120),
  max_people   int check (max_people is null or max_people between 2 and 50),
  notes        text check (notes is null or length(notes) <= 500),
  created_at   timestamptz not null default now()
);
create index if not exists ss_course on public.study_sessions (course_code, starts_at);

create table if not exists public.study_session_rsvps (
  session_id uuid not null references public.study_sessions(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  joined_at  timestamptz not null default now(),
  primary key (session_id, profile_id)
);

alter table public.study_sessions      enable row level security;
alter table public.study_session_rsvps enable row level security;
create policy "ss_read_campus" on public.study_sessions for select using (
  exists (
    select 1 from public.campus_affiliations a
    where a.profile_id = auth.uid() and a.campus = study_sessions.campus and a.status = 'active'
  )
);
create policy "ss_organizer_write" on public.study_sessions for all
  using (auth.uid() = organizer_id) with check (auth.uid() = organizer_id);
create policy "ssr_owner" on public.study_session_rsvps for all
  using (auth.uid() = profile_id) with check (auth.uid() = profile_id);

-- ─── Lost & Found ────────────────────────────────────────────────────────────
create type public.lost_found_kind as enum ('lost','found');

create table if not exists public.lost_found_posts (
  id                 uuid primary key default gen_random_uuid(),
  poster_id          uuid not null references public.profiles(id) on delete cascade,
  campus             text not null references public.campuses(id),
  kind               public.lost_found_kind not null,
  title              text not null check (length(title) between 3 and 120),
  description        text check (description is null or length(description) <= 1000),
  last_seen_location text,
  photo_key          text,
  is_resolved        boolean not null default false,
  created_at         timestamptz not null default now(),
  resolved_at        timestamptz
);
create index if not exists lf_campus_status on public.lost_found_posts (campus, is_resolved);

alter table public.lost_found_posts enable row level security;
create policy "lf_read_campus" on public.lost_found_posts for select using (
  exists (
    select 1 from public.campus_affiliations a
    where a.profile_id = auth.uid() and a.campus = lost_found_posts.campus and a.status = 'active'
  )
);
create policy "lf_poster_write" on public.lost_found_posts for all
  using (auth.uid() = poster_id) with check (auth.uid() = poster_id);

-- ─── Verified campus official accounts ───────────────────────────────────────
alter table public.organizations
  add column if not exists official_kind text
    check (official_kind is null or official_kind in (
      'department','athletics','dining','safety','housing','library','caps','admin'
    ));

-- ─── Real-time capacity view ─────────────────────────────────────────────────
create or replace view public.event_live_capacity as
select
  e.id                              as event_id,
  e.capacity                        as capacity,
  count(distinct ci.profile_id)     as checked_in_count,
  case when e.capacity is null then null
       else round(100.0 * count(distinct ci.profile_id) / nullif(e.capacity, 0), 0)
  end                               as fill_pct
from public.events e
left join public.event_check_ins ci on ci.event_id = e.id
group by e.id;

-- ─── Push notification tokens ───────────────────────────────────────────────
create type public.push_platform as enum ('ios_apns','android_fcm','web_push');

create table if not exists public.push_tokens (
  id          uuid primary key default gen_random_uuid(),
  profile_id  uuid not null references public.profiles(id) on delete cascade,
  platform    public.push_platform not null,
  token       text not null,
  bundle_id   text,
  updated_at  timestamptz not null default now(),
  unique (profile_id, platform, token)
);
create index if not exists pt_profile on public.push_tokens (profile_id);

alter table public.push_tokens enable row level security;
create policy "pt_owner_all" on public.push_tokens for all
  using (auth.uid() = profile_id) with check (auth.uid() = profile_id);

-- ─── Greek-life rush cycles ──────────────────────────────────────────────────
-- US sororities and fraternities run structured multi-round recruitment each semester.
-- Owning this flow locks Buzz in for Greek-heavy schools (Alabama, SEC generally, most
-- of the Midwest/South).
create table if not exists public.rush_cycles (
  id        uuid primary key default gen_random_uuid(),
  campus    text not null references public.campuses(id),
  name      text not null,
  starts_on date not null,
  ends_on   date not null,
  kind      text not null check (kind in ('panhellenic','ifc','multicultural','nphc','pro'))
);

create table if not exists public.rush_rounds (
  id        uuid primary key default gen_random_uuid(),
  cycle_id  uuid not null references public.rush_cycles(id) on delete cascade,
  name      text not null,
  ordinal   int not null,
  starts_on date not null,
  ends_on   date not null,
  unique (cycle_id, ordinal)
);

create table if not exists public.rush_interests (
  cycle_id        uuid not null references public.rush_cycles(id) on delete cascade,
  profile_id      uuid not null references public.profiles(id) on delete cascade,
  organization_id uuid not null references public.organizations(id) on delete cascade,
  rushee_rank     int,
  chapter_mark    text check (chapter_mark in ('interested','invited','bid','passed')),
  updated_at      timestamptz not null default now(),
  primary key (cycle_id, profile_id, organization_id)
);
create index if not exists ri_org on public.rush_interests (organization_id);

alter table public.rush_cycles    enable row level security;
alter table public.rush_rounds    enable row level security;
alter table public.rush_interests enable row level security;
create policy "rc_read_authed" on public.rush_cycles for select using (auth.role() = 'authenticated');
create policy "rr_read_authed" on public.rush_rounds for select using (auth.role() = 'authenticated');
create policy "ri_rushee_read" on public.rush_interests for select using (auth.uid() = profile_id);
create policy "ri_chapter_read" on public.rush_interests for select using (
  exists (
    select 1 from public.memberships m
    where m.organization_id = rush_interests.organization_id
      and m.profile_id = auth.uid()
      and m.role in ('president','founder','vicePresident','officer')
      and m.status = 'active' and m.ended_at is null
  )
);
create policy "ri_rushee_write" on public.rush_interests for insert with check (auth.uid() = profile_id);
create policy "ri_rushee_update" on public.rush_interests for update using (auth.uid() = profile_id);
create policy "ri_chapter_mark" on public.rush_interests for update using (
  exists (
    select 1 from public.memberships m
    where m.organization_id = rush_interests.organization_id
      and m.profile_id = auth.uid()
      and m.role in ('president','founder','vicePresident','officer')
      and m.status = 'active' and m.ended_at is null
  )
);

-- ─── Tickets (paid ticketing via Stripe Connect) ─────────────────────────────
create table if not exists public.ticket_types (
  id             uuid primary key default gen_random_uuid(),
  event_id       uuid not null references public.events(id) on delete cascade,
  name           text not null check (length(name) between 1 and 60),
  price_cents    int not null check (price_cents >= 0),
  currency       text not null default 'USD',
  quantity_total int,
  sales_open_at  timestamptz,
  sales_close_at timestamptz,
  description    text check (description is null or length(description) <= 500)
);
create index if not exists tt_event on public.ticket_types (event_id);

create table if not exists public.tickets (
  id                uuid primary key default gen_random_uuid(),
  ticket_type_id    uuid not null references public.ticket_types(id) on delete restrict,
  buyer_id          uuid not null references public.profiles(id) on delete restrict,
  stripe_session_id text unique,
  price_cents_paid  int not null,
  status            text not null default 'pending',
  qr_token          text not null,
  purchased_at      timestamptz not null default now(),
  used_at           timestamptz
);
create index if not exists tk_buyer on public.tickets (buyer_id);
create index if not exists tk_type on public.tickets (ticket_type_id);

alter table public.ticket_types enable row level security;
alter table public.tickets      enable row level security;
create policy "tt_read_authed" on public.ticket_types for select using (auth.role() = 'authenticated');
create policy "tt_admin_write" on public.ticket_types for all using (
  exists (
    select 1 from public.events e
    join public.memberships m on m.organization_id = e.organization_id
    where e.id = ticket_types.event_id
      and m.profile_id = auth.uid()
      and m.role in ('president','founder','vicePresident','officer')
      and m.status = 'active' and m.ended_at is null
  )
);
create policy "tk_self" on public.tickets for select using (auth.uid() = buyer_id);
create policy "tk_officers" on public.tickets for select using (
  exists (
    select 1 from public.ticket_types tt
    join public.events e       on e.id = tt.event_id
    join public.memberships m  on m.organization_id = e.organization_id
    where tt.id = tickets.ticket_type_id
      and m.profile_id = auth.uid()
      and m.role in ('president','founder','vicePresident','officer')
      and m.status = 'active' and m.ended_at is null
  )
);
create policy "tk_buyer_insert" on public.tickets for insert with check (auth.uid() = buyer_id);

-- ─── Live event chat ─────────────────────────────────────────────────────────
create table if not exists public.event_messages (
  id          uuid primary key default gen_random_uuid(),
  event_id    uuid not null references public.events(id) on delete cascade,
  author_id   uuid not null references public.profiles(id) on delete cascade,
  text        text not null check (length(text) between 1 and 500),
  created_at  timestamptz not null default now()
);
create index if not exists em_event_time on public.event_messages (event_id, created_at desc);

alter table public.event_messages enable row level security;
create policy "em_visible_with_event" on public.event_messages for select using (
  exists (select 1 from public.events e where e.id = event_messages.event_id)
);
create policy "em_authed_post" on public.event_messages for insert with check (auth.uid() = author_id);
create policy "em_author_delete" on public.event_messages for delete using (auth.uid() = author_id);

-- ─── Webhooks (Discord / Slack / generic) ───────────────────────────────────
-- Orgs register webhook URLs; when a published event is created, the relay POSTs to
-- each endpoint with a JSON payload Discord/Slack render natively.
create type public.webhook_kind as enum ('discord','slack','generic');

create table if not exists public.webhook_endpoints (
  id              uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  kind            public.webhook_kind not null,
  url             text not null,
  is_active       boolean not null default true,
  created_by      uuid references public.profiles(id) on delete set null,
  created_at      timestamptz not null default now()
);
create index if not exists wh_org on public.webhook_endpoints (organization_id);

alter table public.webhook_endpoints enable row level security;
create policy "wh_officer_all" on public.webhook_endpoints for all using (
  exists (
    select 1 from public.memberships m
    where m.organization_id = webhook_endpoints.organization_id
      and m.profile_id = auth.uid()
      and m.role in ('president','founder','vicePresident','officer')
      and m.status = 'active' and m.ended_at is null
  )
);

-- ─── Broadcasts (push / email blasts to org members) ─────────────────────────
create type public.broadcast_channel as enum ('push','email','both');

create table if not exists public.broadcasts (
  id              uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  event_id        uuid references public.events(id) on delete set null,
  channel         public.broadcast_channel not null,
  subject         text not null check (length(subject) between 1 and 120),
  body            text not null check (length(body) <= 2000),
  sent_by         uuid references public.profiles(id) on delete set null,
  sent_at         timestamptz not null default now(),
  recipient_count int not null default 0
);
create index if not exists bc_org on public.broadcasts (organization_id);

alter table public.broadcasts enable row level security;
create policy "bc_officer_all" on public.broadcasts for all using (
  exists (
    select 1 from public.memberships m
    where m.organization_id = broadcasts.organization_id
      and m.profile_id = auth.uid()
      and m.role in ('president','founder','vicePresident','officer')
      and m.status = 'active' and m.ended_at is null
  )
);

-- Per-org rate limit: 5 broadcasts per day. Spam protection.
create or replace function public.enforce_broadcast_rate() returns trigger
language plpgsql as $$
declare cnt int;
begin
  select count(*) into cnt from public.broadcasts
   where organization_id = new.organization_id
     and sent_at >= now() - interval '24 hours';
  if cnt >= 5 then
    raise exception 'broadcast rate limit reached (5 per 24h per org)';
  end if;
  return new;
end $$;
drop trigger if exists trg_broadcast_rate on public.broadcasts;
create trigger trg_broadcast_rate
before insert on public.broadcasts
for each row execute function public.enforce_broadcast_rate();

-- ─── Auto-reminders (day-of comms) ───────────────────────────────────────────
-- A scheduled job (Vercel cron / Supabase pg_cron) runs every 5 min, finds events with
-- starts_at within the next reminder window, sends pushes to RSVPs.
create table if not exists public.event_reminders (
  event_id      uuid not null references public.events(id) on delete cascade,
  fires_at      timestamptz not null,
  reminder_kind text not null,                   -- '24h' | '1h' | '15m' | 'custom'
  fired         boolean not null default false,
  primary key (event_id, fires_at)
);
create index if not exists er_pending on public.event_reminders (fires_at) where fired = false;

-- Auto-create the standard reminder set when an event is published.
create or replace function public.seed_event_reminders() returns trigger
language plpgsql as $$
begin
  if new.status = 'published' and (old.status is null or old.status <> 'published') then
    insert into public.event_reminders (event_id, fires_at, reminder_kind) values
      (new.id, new.starts_at - interval '24 hours', '24h'),
      (new.id, new.starts_at - interval '1 hour',  '1h'),
      (new.id, new.starts_at - interval '15 minutes', '15m')
    on conflict do nothing;
  end if;
  return new;
end $$;
drop trigger if exists trg_seed_reminders on public.events;
create trigger trg_seed_reminders
after insert or update of status on public.events
for each row execute function public.seed_event_reminders();

-- ─── Org analytics view ──────────────────────────────────────────────────────
create or replace view public.org_analytics as
select
  o.id            as organization_id,
  o.name          as org_name,
  count(distinct e.id) filter (where e.status = 'published')           as published_events,
  coalesce(sum(e.rsvp_count), 0)                                       as total_rsvps,
  count(distinct ci.profile_id)                                        as total_attendees,
  count(distinct m.profile_id) filter (where m.status = 'active' and m.ended_at is null) as active_members,
  -- conversion: how many RSVPs actually showed up?
  case when sum(e.rsvp_count) > 0
       then round(100.0 * count(distinct ci.profile_id) / nullif(sum(e.rsvp_count), 0), 1)
       else null end                                                   as attendance_rate_pct
from public.organizations o
left join public.events e        on e.organization_id = o.id
left join public.event_check_ins ci on ci.event_id = e.id
left join public.memberships m   on m.organization_id = o.id
group by o.id, o.name;

-- Inbound-email drafts: forwarded events arrive as status='draft' with an audit trail.
create table if not exists public.event_drafts (
  id              uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  source          text not null,                 -- 'email' | 'manual' | 'csv' | 'calendar_import'
  source_address  text,                          -- the email it was forwarded from
  raw_payload     jsonb not null,                -- normalized email body, etc.
  parsed          jsonb not null,                -- DraftEvent JSON
  confidence      text not null,                 -- 'high' | 'medium' | 'low'
  reviewed_by     uuid references public.profiles(id) on delete set null,
  reviewed_at     timestamptz,
  created_at      timestamptz not null default now()
);
create index if not exists drafts_org on public.event_drafts (organization_id);

alter table public.event_drafts enable row level security;
create policy "drafts_officers" on public.event_drafts for all using (
  exists (
    select 1 from public.memberships m
    where m.organization_id = event_drafts.organization_id
      and m.profile_id = auth.uid()
      and m.role in ('president','founder','vicePresident','officer')
      and m.status = 'active' and m.ended_at is null
  )
);

-- ─── Reports (moderation queue) ──────────────────────────────────────────────
-- VULN #15 patch: ReportSheet now has a backing table.
create type public.report_target_kind as enum ('event','organization','profile');
create type public.report_reason as enum (
  'spam','harassment','hateSpeech','dangerous','impersonation','underage','inaccurate','other'
);
create type public.report_status as enum ('pending','actioned','dismissed');

create table if not exists public.reports (
  id           uuid primary key default gen_random_uuid(),
  reporter_id  uuid not null references public.profiles(id) on delete cascade,
  target_kind  public.report_target_kind not null,
  target_id    uuid not null,
  reason       public.report_reason not null,
  notes        text check (length(notes) <= 1000),
  status       public.report_status not null default 'pending',
  created_at   timestamptz not null default now(),
  reviewed_at  timestamptz
);
create index if not exists reports_target  on public.reports (target_kind, target_id);
create index if not exists reports_status  on public.reports (status);

alter table public.reports enable row level security;
create policy "reports_create" on public.reports for insert with check (auth.uid() = reporter_id);
create policy "reports_read_own" on public.reports for select using (auth.uid() = reporter_id);
-- (Admin moderation reads/writes via service role only.)

-- ─── Event invitations (VULN #14 patch) ──────────────────────────────────────
-- Previously, `events_read` policy let any user read an `inviteOnly` event if they had
-- inserted an RSVP for it (and rsvp insert was unrestricted). Fix: separate explicit
-- invitations table; events_read consults this list, not rsvps.
create table if not exists public.event_invites (
  event_id    uuid not null references public.events(id) on delete cascade,
  profile_id  uuid not null references public.profiles(id) on delete cascade,
  invited_by  uuid references public.profiles(id) on delete set null,
  invited_at  timestamptz not null default now(),
  primary key (event_id, profile_id)
);

-- VULN #101 patch: cap invites per event so a host can't bulk-spam thousands of strangers.
create or replace function public.enforce_invite_cap() returns trigger language plpgsql as $$
declare cnt int;
begin
  select count(*) into cnt from public.event_invites where event_id = new.event_id;
  if cnt >= 5000 then
    raise exception 'invite cap reached for this event (5000)';
  end if;
  return new;
end $$;
drop trigger if exists trg_invite_cap on public.event_invites;
create trigger trg_invite_cap
before insert on public.event_invites
for each row execute function public.enforce_invite_cap();
alter table public.event_invites enable row level security;
create policy "invites_read"  on public.event_invites for select using (
  profile_id = auth.uid()
  or invited_by = auth.uid()
);
create policy "invites_write" on public.event_invites for all using (
  exists (
    select 1 from public.events e
    where e.id = event_invites.event_id and e.host_id = auth.uid()
  )
  or exists (
    select 1 from public.events e
    join public.memberships m on m.organization_id = e.organization_id
    where e.id = event_invites.event_id
      and m.profile_id = auth.uid()
      and m.role in ('president','founder','vicePresident','officer')
      and m.status = 'active' and m.ended_at is null
  )
);

-- ─── Length caps on free-form text (VULN #16 patch) ──────────────────────────
alter table public.profiles add constraint profiles_bio_len check (bio is null or length(bio) <= 500);
alter table public.profiles add constraint profiles_name_len check (length(display_name) between 1 and 80);
alter table public.profiles add constraint profiles_handle_len check (length(handle) between 2 and 30);
-- VULN #62 + #98 patch: handle is URL-routed; case-insensitive charset check (the
-- lowercase_handles trigger runs BEFORE this CHECK, but in a multi-trigger ordering quirk
-- we want the constraint robust even if input arrives uppercase momentarily.)
alter table public.profiles add constraint profiles_handle_charset check (handle ~* '^[a-z0-9_]+$');
-- VULN #63 patch: same for organization handles.
alter table public.organizations add constraint orgs_handle_charset check (handle ~ '^[a-z0-9-]+$');
alter table public.organizations add constraint orgs_handle_len check (length(handle) between 2 and 40);

-- VULN #66 patch: handles are case-folded on write so @yashgoel and @YashGoel don't both exist.
create or replace function public.lowercase_handles() returns trigger language plpgsql as $$
begin
  new.handle := lower(new.handle);
  return new;
end $$;
drop trigger if exists trg_lower_profile_handle on public.profiles;
create trigger trg_lower_profile_handle
before insert or update of handle on public.profiles
for each row execute function public.lowercase_handles();
drop trigger if exists trg_lower_org_handle on public.organizations;
create trigger trg_lower_org_handle
before insert or update of handle on public.organizations
for each row execute function public.lowercase_handles();

-- VULN #65 patch: insert can never directly mint a prestige role. The first president of
-- a brand-new org is created via `create_organization(...)` RPC (admin); subsequent
-- transitions go through `transfer_org_ownership(...)`.
create or replace function public.guard_prestige_insert() returns trigger language plpgsql as $$
begin
  if new.role in ('founder','president','captain')
     and current_setting('buzz.transfer_in_progress', true) is distinct from 'true'
     and current_setting('buzz.org_create_in_progress', true) is distinct from 'true' then
    raise exception 'prestige roles can only be assigned via create_organization or transfer_org_ownership';
  end if;
  return new;
end $$;
drop trigger if exists trg_guard_prestige_insert on public.memberships;
create trigger trg_guard_prestige_insert
before insert on public.memberships
for each row execute function public.guard_prestige_insert();
alter table public.events   add constraint events_title_len check (length(title) between 3 and 120);
alter table public.events   add constraint events_summary_len check (length(summary) <= 2000);
alter table public.events   add constraint events_host_name_len check (length(host_name) between 1 and 120);
-- VULN #47 patch: cap event duration at 14 days. Stops the "event runs all month" gag.
alter table public.events   add constraint events_max_duration check (ends_at >= starts_at and ends_at <= starts_at + interval '14 days');
-- VULN #53 patch: cap tag array length so user can't store thousands of tags.
alter table public.events   add constraint events_tags_count check (array_length(tags, 1) is null or array_length(tags, 1) <= 20);
alter table public.organizations add constraint orgs_name_len check (length(name) between 2 and 120);
alter table public.organizations add constraint orgs_tagline_len check (length(tagline) <= 200);
alter table public.organizations add constraint orgs_description_len check (length(description) <= 4000);
alter table public.campus_affiliations add constraint aff_major_len check (major is null or length(major) <= 120);
-- VULN #54 patch: cap minors array.
alter table public.campus_affiliations add constraint aff_minors_count check (array_length(minors, 1) is null or array_length(minors, 1) <= 5);
-- VULN #52 patch: accent_hex must be a real 6-char hex color.
alter table public.profiles      add constraint profiles_hex_format check (accent_hex ~ '^#[0-9A-Fa-f]{6}$');
alter table public.organizations add constraint orgs_hex_format     check (accent_hex ~ '^#[0-9A-Fa-f]{6}$');

-- ─── GDPR delete + sign-out-everywhere (VULN #20, #21 patch) ─────────────────
create or replace function public.delete_my_account() returns void
language plpgsql security definer as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then raise exception 'not authenticated'; end if;
  -- VULN #72 patch: explicit failure on auth row delete. Without this, a missing grant
  -- would leave the public.profiles row deleted but auth.users orphaned, breaking sign-in.
  delete from public.profiles where id = uid;
  begin
    delete from auth.users where id = uid;
  exception when others then
    raise exception 'could not delete auth.users row (%, %)', sqlstate, sqlerrm;
  end;
end $$;
revoke all on function public.delete_my_account from public;
grant execute on function public.delete_my_account to authenticated;

create or replace function public.revoke_all_sessions() returns void
language plpgsql security definer as $$
begin
  if auth.uid() is null then raise exception 'not authenticated'; end if;
  delete from auth.sessions where user_id = auth.uid();
end $$;
revoke all on function public.revoke_all_sessions from public;
grant execute on function public.revoke_all_sessions to authenticated;

-- ─── Audit log (security-sensitive actions) ──────────────────────────────────
-- Captures role assignments, removals, and permission changes for forensic review.
-- Append-only: no UPDATE or DELETE policies. Rows live forever.
create table if not exists public.audit_log (
  id          uuid primary key default gen_random_uuid(),
  actor_id    uuid references public.profiles(id) on delete set null,
  action      text not null,                  -- e.g. 'membership.assign', 'membership.remove', 'org.transfer_ownership'
  subject_id  uuid,                           -- who/what was acted on
  payload     jsonb not null default '{}',    -- old/new values, IP, user agent
  created_at  timestamptz not null default now()
);

create index if not exists audit_actor on public.audit_log (actor_id);
create index if not exists audit_action on public.audit_log (action);
create index if not exists audit_created on public.audit_log (created_at desc);

-- VULN #100 patch: cap audit_log payload to 8KB so a runaway RPC can't blow the table.
alter table public.audit_log add constraint audit_payload_size
  check (octet_length(payload::text) <= 8192);

create or replace function public.log_membership_change() returns trigger
language plpgsql security definer as $$
begin
  insert into public.audit_log (actor_id, action, subject_id, payload)
  values (
    auth.uid(),
    case
      when TG_OP = 'INSERT' then 'membership.assign'
      when TG_OP = 'UPDATE' then 'membership.update'
      when TG_OP = 'DELETE' then 'membership.remove'
    end,
    coalesce(new.id, old.id),
    jsonb_build_object(
      'organization_id', coalesce(new.organization_id, old.organization_id),
      'profile_id',      coalesce(new.profile_id, old.profile_id),
      'role_old',        old.role,
      'role_new',        new.role
    )
  );
  return null;
end $$;

drop trigger if exists trg_log_membership on public.memberships;
create trigger trg_log_membership
after insert or update or delete on public.memberships
for each row execute function public.log_membership_change();

-- ─── RLS ──────────────────────────────────────────────────────────────────────
alter table public.profiles            enable row level security;
alter table public.campus_affiliations enable row level security;
alter table public.organizations       enable row level security;
alter table public.memberships         enable row level security;
alter table public.events              enable row level security;
alter table public.rsvps               enable row level security;
alter table public.audit_log           enable row level security;
alter table public.auth_identities     enable row level security;
alter table public.campus_requests     enable row level security;
alter table public.campuses            enable row level security;

-- VULN #11 patch: auth_identities owner-only. Other users must never see your linked
-- Apple ID, Google account, phone number, etc.
create policy "auth_owner_read"  on public.auth_identities for select using (auth.uid() = profile_id);
create policy "auth_owner_write" on public.auth_identities for all
  using (auth.uid() = profile_id) with check (auth.uid() = profile_id);

-- VULN #12 patch: audit_log is append-only and never client-readable. Service role only.
-- (No insert/update/delete policies declared — all writes happen through SECURITY DEFINER triggers.)
create policy "audit_no_client_read" on public.audit_log for select using (false);

-- VULN #13 patch: campus_requests — requester sees only their own; admins via service role.
create policy "requests_owner_read" on public.campus_requests for select using (auth.uid() = requester_id);
create policy "requests_create"     on public.campus_requests for insert with check (auth.uid() = requester_id);

-- Campus registry is public reference data; no client writes.
create policy "campuses_read" on public.campuses for select using (true);

-- Profiles readable by any authed user; editable only by owner.
create policy "profiles_read"   on public.profiles for select using (auth.role() = 'authenticated');
create policy "profiles_upsert" on public.profiles for all
  using (auth.uid() = id) with check (auth.uid() = id);

-- Affiliations: readable only by owner. INSERT/UPDATE blocked for direct use —
-- the `verify_affiliation(...)` SECURITY DEFINER RPC is the only sanctioned path in,
-- and it enforces an OTP/ID verification token before creating the row.
create policy "aff_read_owner" on public.campus_affiliations for select using (auth.uid() = profile_id);
create policy "aff_update_owner" on public.campus_affiliations for update using (auth.uid() = profile_id);
create policy "aff_delete_owner" on public.campus_affiliations for delete using (auth.uid() = profile_id);
-- No INSERT policy — must go through verify_affiliation RPC.

-- VULN #6 patch: only the verification RPC may insert affiliations. Clients call it with
-- evidence (OTP code, ID scan result); the RPC validates, then inserts with elevated privileges.
create or replace function public.verify_affiliation(
  p_campus text, p_sub_campus text, p_role public.affiliation_role,
  p_program public.program_kind, p_year public.academic_year,
  p_major text, p_method text, p_evidence_token text
) returns public.campus_affiliations
language plpgsql security definer as $$
declare
  result public.campus_affiliations;
begin
  if auth.uid() is null then raise exception 'not authenticated'; end if;
  -- In production this validates p_evidence_token against a short-lived OTP/ID-scan record.
  -- For MVP it's a stub; replace before going live.
  if coalesce(length(p_evidence_token), 0) < 6 then
    raise exception 'invalid verification evidence';
  end if;
  -- VULN #71 patch: persist verification_method so we know HOW each affiliation was proven.
  -- Previously p_method was accepted then discarded — auditing was broken.
  insert into public.campus_affiliations (
    profile_id, campus, sub_campus, role, program, status, year, major, verified_at, verification_method
  ) values (
    auth.uid(), p_campus, p_sub_campus, p_role, p_program, 'active', p_year, p_major, now(), p_method
  ) returning * into result;
  return result;
end $$;
revoke all on function public.verify_affiliation from public;
grant execute on function public.verify_affiliation to authenticated;

-- Organizations readable by authed; writes restricted to org presidents via membership check.
create policy "orgs_read" on public.organizations for select using (auth.role() = 'authenticated');
create policy "orgs_admin_write" on public.organizations for update using (
  exists (
    select 1 from public.memberships m
    where m.organization_id = organizations.id
      and m.profile_id = auth.uid()
      and m.role in ('president','founder')
      and m.status = 'active'
      and m.ended_at is null
  )
);
create policy "orgs_insert" on public.organizations for insert with check (auth.role() = 'authenticated');

-- VULN #1 patch: force is_verified=false on creation. Verification is admin-only.
create or replace function public.strip_org_verified() returns trigger
language plpgsql as $$
begin
  new.is_verified := false;
  return new;
end $$;
drop trigger if exists trg_strip_org_verified on public.organizations;
create trigger trg_strip_org_verified
before insert on public.organizations
for each row execute function public.strip_org_verified();

-- VULN #5 patch: prevent campus reassignment once an org is created — stops presidents
-- from silently relocating their org to a different school's feed.
create or replace function public.lock_org_campus() returns trigger
language plpgsql as $$
begin
  if new.campus <> old.campus then
    raise exception 'org.campus is immutable (contact support to move an org)';
  end if;
  return new;
end $$;
drop trigger if exists trg_lock_org_campus on public.organizations;
create trigger trg_lock_org_campus
before update on public.organizations
for each row execute function public.lock_org_campus();

-- VULN #23 patch: affiliations are partially immutable. The user can update their year,
-- major, minors, and end_date / status. They cannot retroactively change campus, role,
-- program, or sub-campus — those would invalidate the verification that minted the row.
create or replace function public.lock_affiliation_core() returns trigger
language plpgsql as $$
begin
  if new.campus <> old.campus then raise exception 'affiliation.campus is immutable'; end if;
  if new.role <> old.role then raise exception 'affiliation.role is immutable'; end if;
  if new.program <> old.program then raise exception 'affiliation.program is immutable'; end if;
  if coalesce(new.sub_campus, '') <> coalesce(old.sub_campus, '') then
    raise exception 'affiliation.sub_campus is immutable';
  end if;
  if coalesce(new.verification_method, '') <> coalesce(old.verification_method, '') then
    raise exception 'affiliation.verification_method is immutable';
  end if;
  return new;
end $$;
-- Note: verification_method column added below for full coverage.
alter table public.campus_affiliations add column if not exists verification_method text;
drop trigger if exists trg_lock_affiliation_core on public.campus_affiliations;
create trigger trg_lock_affiliation_core
before update on public.campus_affiliations
for each row execute function public.lock_affiliation_core();

-- VULN #4 patch: pending memberships are invitations, not yet public. Only the invited user
-- and org officers see them; active memberships respect the user's `is_visible` toggle.
create policy "mem_read" on public.memberships for select using (
  profile_id = auth.uid()
  or (status = 'active' and is_visible = true)
  or exists (
    select 1 from public.memberships m
    where m.organization_id = memberships.organization_id
      and m.profile_id = auth.uid()
      and m.role in ('president','founder','vicePresident','officer')
      and m.status = 'active' and m.ended_at is null
  )
);

-- User can update their OWN membership. The state machine (who can transition to what)
-- is enforced by the BEFORE UPDATE trigger below, not here.
create policy "mem_self_update" on public.memberships for update using (profile_id = auth.uid())
  with check (profile_id = auth.uid());

-- Officers can update memberships in their org (e.g. revoke, change role).
create policy "mem_admin_update" on public.memberships for update using (
  exists (
    select 1 from public.memberships m
    where m.organization_id = memberships.organization_id
      and m.profile_id = auth.uid()
      and m.role in ('president','founder')
      and m.status = 'active' and m.ended_at is null
  )
);

-- Only org presidents/founders can invite. Invitation arrives as status='pending' — invited
-- user must accept to go active. Prevents orgs from silently minting badges on strangers.
create policy "mem_admin_invite" on public.memberships for insert with check (
  status = 'pending'
  and exists (
    select 1 from public.memberships m
    where m.organization_id = memberships.organization_id
      and m.profile_id = auth.uid()
      and m.role in ('president','founder')
      and m.status = 'active' and m.ended_at is null
  )
);

create policy "mem_admin_revoke" on public.memberships for delete using (
  exists (
    select 1 from public.memberships m
    where m.organization_id = memberships.organization_id
      and m.profile_id = auth.uid()
      and m.role in ('president','founder')
      and m.status = 'active' and m.ended_at is null
  ) or profile_id = auth.uid()                 -- users can always leave an org themselves
);

-- Membership state machine — enforced regardless of who the updater is:
--   pending → active | declined   (only the invited user, via OldRow check below)
--   active  → resigned (by user) | revoked (by officer)
--   terminal states (declined/revoked/resigned) are frozen
create or replace function public.enforce_membership_transitions() returns trigger
language plpgsql as $$
begin
  -- role + organization + profile + history are immutable after creation
  if new.organization_id <> old.organization_id then
    raise exception 'membership.organization_id is immutable';
  end if;
  if new.profile_id <> old.profile_id then
    raise exception 'membership.profile_id is immutable';
  end if;
  -- VULN #51 patch: `since` and `invited_by` are historical record. Mutating them lets
  -- users backdate seniority or rewrite who invited them.
  if new.since <> old.since then
    raise exception 'membership.since is immutable';
  end if;
  if coalesce(new.invited_by::text, '') <> coalesce(old.invited_by::text, '') then
    raise exception 'membership.invited_by is immutable';
  end if;
  -- VULN #33 patch: a non-officer (the member themselves) cannot change their own role.
  -- Only an officer of the org may assign roles, and prestige changes go via transfer RPC.
  if old.role <> new.role
     and not exists (
       select 1 from public.memberships m
       where m.organization_id = old.organization_id
         and m.profile_id = auth.uid()
         and m.role in ('president','founder')
         and m.status = 'active' and m.ended_at is null
     ) then
    raise exception 'only an active President or Founder can change roles';
  end if;

  -- VULN #69 patch: is_visible is owner-only. Officers can promote/demote but never
  -- toggle a member's badge-visibility preference on their behalf.
  if new.is_visible <> old.is_visible and auth.uid() is not null and auth.uid() <> old.profile_id then
    raise exception 'only the member can change their badge visibility';
  end if;

  -- state transitions
  if old.status = new.status then
    return new;    -- no-op (e.g. owner toggling is_visible)
  end if;

  if old.status = 'pending' then
    -- VULN #49 patch: service-role calls (auth.uid() IS NULL) intentionally bypass user
    -- checks for admin operations; everyone else must match the invited user.
    if auth.uid() is null then return new; end if;
    if auth.uid() <> old.profile_id then
      raise exception 'only the invited user can respond to a pending membership';
    end if;
    if new.status not in ('active', 'declined') then
      raise exception 'pending membership may only move to active or declined';
    end if;
    return new;
  end if;

  if old.status = 'active' then
    -- user may resign themselves; officers may revoke
    if new.status = 'resigned' and auth.uid() = old.profile_id then return new; end if;
    if new.status = 'revoked' and exists (
      select 1 from public.memberships m
      where m.organization_id = old.organization_id and m.profile_id = auth.uid()
        and m.role in ('president','founder') and m.status = 'active' and m.ended_at is null
    ) then return new; end if;
    raise exception 'invalid active→% transition', new.status;
  end if;

  raise exception 'memberships in terminal state (%) cannot be reopened', old.status;
end $$;

drop trigger if exists trg_membership_transitions on public.memberships;
create trigger trg_membership_transitions
before update on public.memberships
for each row execute function public.enforce_membership_transitions();

-- VULN #7 patch: visibility-aware read policy.
--   public         → everyone authed
--   campusOnly     → only users with an active affiliation at the event's campus
--   inviteOnly     → only the host or users RSVP'd (the host adds them to `rsvps` to grant access)
--   officersOnly   → only active officers of the host org
alter table public.events add column if not exists visibility text not null default 'public';
alter table public.events add column if not exists hide_attendees boolean not null default false;
alter table public.events add column if not exists timezone text not null default 'America/Los_Angeles';

create policy "events_read" on public.events for select using (
  case visibility
    when 'public' then auth.role() = 'authenticated'
    when 'campusOnly' then exists (
      select 1 from public.campus_affiliations a
      where a.profile_id = auth.uid() and a.campus = events.campus and a.status = 'active'
    )
    when 'inviteOnly' then host_id = auth.uid() or exists (
      select 1 from public.event_invites i where i.event_id = events.id and i.profile_id = auth.uid()
    )
    when 'officersOnly' then exists (
      select 1 from public.memberships m
      where m.organization_id = events.organization_id
        and m.profile_id = auth.uid()
        and m.role in ('president','founder','vicePresident','officer')
        and m.status = 'active' and m.ended_at is null
    )
    else false
  end
);

-- VULN #2 patch: if the event is attributed to an org, the poster must be an active
-- member of that org. Stops users from forging "Hosted by IIT Bombay" events.
create policy "events_insert" on public.events for insert with check (
  auth.uid() = host_id
  and (
    organization_id is null
    or exists (
      select 1 from public.memberships m
      where m.organization_id = events.organization_id
        and m.profile_id = auth.uid()
        and m.status = 'active' and m.ended_at is null
    )
  )
);

create policy "events_update" on public.events for update using (
  auth.uid() = host_id
  or exists (
    select 1 from public.memberships m
    where m.organization_id = events.organization_id
      and m.profile_id = auth.uid()
      and m.role in ('president','founder','vicePresident','officer')
      and m.status = 'active' and m.ended_at is null
  )
)
with check (
  -- VULN #25 patch: prevent post-creation re-attribution. The host can update fields,
  -- but if they CHANGE organization_id, they must be an active member of the NEW org too.
  organization_id is null
  or exists (
    select 1 from public.memberships m
    where m.organization_id = events.organization_id
      and m.profile_id = auth.uid()
      and m.status = 'active' and m.ended_at is null
  )
);
create policy "events_delete" on public.events for delete using (auth.uid() = host_id);

-- VULN #3 + #24 patch: force is_official=false on BOTH insert and update. Only service
-- role (admin / campus partnership) may flip it true. Previously the trigger only fired
-- on INSERT, so an officer could update their event afterwards and silently mark it official.
create or replace function public.strip_event_official() returns trigger
language plpgsql as $$
begin
  if new.is_official is true then new.is_official := false; end if;
  return new;
end $$;
drop trigger if exists trg_strip_event_official on public.events;
create trigger trg_strip_event_official
before insert or update on public.events
for each row execute function public.strip_event_official();

-- VULN #8 patch: cap active RSVPs per user to deflect spam-inflation scripts.
create or replace function public.enforce_rsvp_cap() returns trigger
language plpgsql as $$
declare active_count int;
begin
  if new.status <> 'going' then return new; end if;
  select count(*) into active_count
    from public.rsvps r
    join public.events e on e.id = r.event_id
   where r.user_id = new.user_id and r.status = 'going' and e.ends_at >= now();
  if active_count > 200 then
    raise exception 'RSVP limit reached (200 concurrent going-events per user)';
  end if;
  return new;
end $$;
drop trigger if exists trg_enforce_rsvp_cap on public.rsvps;
create trigger trg_enforce_rsvp_cap
before insert or update on public.rsvps
for each row execute function public.enforce_rsvp_cap();

-- VULN #26 patch: RSVP visibility check. Previously a user who guessed an event ID
-- could RSVP to an officersOnly / inviteOnly / campusOnly event they shouldn't see.
-- The events_read policy hid the row but didn't block the rsvp insert.
create or replace function public.enforce_rsvp_visibility() returns trigger
language plpgsql as $$
declare
  v text; e_campus text; e_org uuid; e_host uuid; e_ends_at timestamptz;
begin
  select visibility, campus, organization_id, host_id, ends_at
    into v, e_campus, e_org, e_host, e_ends_at
    from public.events where id = new.event_id;

  -- VULN #92 patch: explicit error if the target event no longer exists.
  if v is null then raise exception 'event % does not exist', new.event_id; end if;
  -- VULN #95 patch: no retroactive RSVPs on events that have already ended.
  if e_ends_at < now() then raise exception 'event has ended; RSVPs locked'; end if;

  if v = 'public' then return new; end if;
  if v = 'campusOnly' then
    if exists (select 1 from public.campus_affiliations a
               where a.profile_id = new.user_id and a.campus = e_campus and a.status = 'active') then
      return new;
    end if;
    raise exception 'event is campus-only';
  end if;
  if v = 'inviteOnly' then
    if e_host = new.user_id then return new; end if;
    if exists (select 1 from public.event_invites i
               where i.event_id = new.event_id and i.profile_id = new.user_id) then
      return new;
    end if;
    raise exception 'event is invite-only';
  end if;
  if v = 'officersOnly' then
    if exists (select 1 from public.memberships m
               where m.organization_id = e_org and m.profile_id = new.user_id
                 and m.role in ('president','founder','vicePresident','officer')
                 and m.status = 'active' and m.ended_at is null) then
      return new;
    end if;
    raise exception 'event is officers-only';
  end if;
  raise exception 'unknown event visibility';
end $$;
drop trigger if exists trg_enforce_rsvp_visibility on public.rsvps;
create trigger trg_enforce_rsvp_visibility
before insert or update on public.rsvps
for each row execute function public.enforce_rsvp_visibility();

-- VULN #30 patch: prestige-tier role mutations require an explicit ownership transfer
-- (not silent role bumps). A President can promote others to Officer/VP; transferring
-- Founder or President must go through `transfer_org_ownership(...)` RPC which logs the
-- action and notifies both parties.
-- VULN #109 + #112 patch: guard prestige role changes in BOTH directions, and use a
-- check that users cannot bypass.
--
-- Previous version checked `current_setting('buzz.transfer_in_progress', true)`. CRITICAL
-- bug: any authenticated user can `SET LOCAL buzz.transfer_in_progress = 'true'` before
-- their UPDATE — custom GUC namespaces have no permission gate. The "guard" was a paper
-- wall and any user could promote themselves to Founder of any org.
--
-- Fix: check `current_user`. Inside SECURITY DEFINER functions owned by postgres,
-- `current_user = 'postgres'`. Regular API requests run as 'authenticated' / 'anon',
-- which users cannot assume into 'postgres' without superuser credentials. This is a real
-- privilege gate, not a settable variable.
create or replace function public.guard_prestige_changes() returns trigger
language plpgsql as $$
begin
  if old.role <> new.role
     and (new.role in ('founder','president','captain')
          or old.role in ('founder','president','captain'))
     and current_user not in ('postgres', 'supabase_admin') then
    raise exception 'prestige-tier role changes (in or out) must go through transfer_org_ownership()';
  end if;
  return new;
end $$;
drop trigger if exists trg_guard_prestige on public.memberships;
create trigger trg_guard_prestige
before update on public.memberships
for each row execute function public.guard_prestige_changes();

create or replace function public.transfer_org_ownership(
  p_org uuid, p_new_owner uuid
) returns void language plpgsql security definer as $$
begin
  if not exists (
    select 1 from public.memberships
    where organization_id = p_org and profile_id = auth.uid()
      and role in ('president','founder') and status = 'active' and ended_at is null
  ) then
    raise exception 'only an active President or Founder may transfer ownership';
  end if;
  -- VULN #59 patch: new owner must already be an active member of THIS org. Stops a
  -- president from promoting a random stranger to take over.
  if not exists (
    select 1 from public.memberships
    where organization_id = p_org and profile_id = p_new_owner
      and status = 'active' and ended_at is null
  ) then
    raise exception 'new owner must be an active member of this organization';
  end if;
  -- VULN #112 patch: no more set_config flag. The guard now checks `current_user`,
  -- which is 'postgres' here (SECURITY DEFINER), so prestige updates are allowed.
  update public.memberships set role = 'member'
    where organization_id = p_org and profile_id = auth.uid()
      and role in ('president','founder') and status = 'active';
  update public.memberships set role = 'president'
    where organization_id = p_org and profile_id = p_new_owner
      and status = 'active' and ended_at is null;
end $$;
revoke all on function public.transfer_org_ownership from public;
grant execute on function public.transfer_org_ownership to authenticated;

-- RSVPs: user-owned.
create policy "rsvps_read_own"  on public.rsvps for select using (auth.uid() = user_id);
create policy "rsvps_write_own" on public.rsvps for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
