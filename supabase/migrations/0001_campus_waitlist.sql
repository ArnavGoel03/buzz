-- Holds emails from students whose campus Buzz hasn't launched at yet. Populated by
-- the web sign-in form when the user's domain doesn't match any entry in the
-- client-side CAMPUS_DOMAINS map. Used to prioritize launch order by demand.

create table if not exists public.campus_waitlist (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  domain text not null,
  created_at timestamptz not null default now(),
  ambassador boolean not null default false,
  notified_at timestamptz
);

create index if not exists campus_waitlist_domain_idx on public.campus_waitlist (domain);
create index if not exists campus_waitlist_created_idx on public.campus_waitlist (created_at desc);

alter table public.campus_waitlist enable row level security;

-- Inserts are allowed from any authenticated OR anonymous request (server route
-- runs with anon key). Reads/updates are service-role only (admin dashboard).
create policy "waitlist_insert_any" on public.campus_waitlist
  for insert with check (true);
