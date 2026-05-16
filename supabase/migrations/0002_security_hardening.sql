-- 0002_security_hardening.sql
-- Addresses the Crit/High red-team findings from the 2026-05-16 audit.
-- Idempotent where possible; safe to re-run.

set check_function_bodies = off;

-- ─── #1 Crit ────────────────────────────────────────────────────────────────
-- `message_thread_members.mtm_self` let any authed user join any thread by INSERT.
-- Split: explicit thread_invites gates membership; users may only self-leave / mute.
drop policy if exists mtm_self on public.message_thread_members;

create table if not exists public.thread_invites (
    thread_id   uuid not null references public.message_threads(id) on delete cascade,
    invitee_id  uuid not null references public.profiles(id) on delete cascade,
    invited_by  uuid not null references public.profiles(id) on delete cascade,
    created_at  timestamptz not null default now(),
    primary key (thread_id, invitee_id)
);
alter table public.thread_invites enable row level security;
alter table public.thread_invites force row level security;

drop policy if exists ti_invite_visible on public.thread_invites;
create policy ti_invite_visible on public.thread_invites
    for select using (auth.uid() = invitee_id or auth.uid() = invited_by);

drop policy if exists ti_invite_write on public.thread_invites;
create policy ti_invite_write on public.thread_invites
    for insert with check (
        auth.uid() = invited_by
        -- Inviter must already be a member of the thread; can't self-invite.
        and auth.uid() <> invitee_id
        and exists (
            select 1 from public.message_thread_members m
            where m.thread_id = thread_invites.thread_id and m.profile_id = auth.uid()
        )
    );

create policy mtm_join_via_invite on public.message_thread_members
    for insert with check (
        auth.uid() = profile_id
        and exists (
            select 1 from public.thread_invites ti
            where ti.thread_id = message_thread_members.thread_id and ti.invitee_id = auth.uid()
        )
    );
-- Critical: dropping mtm_self removed the SELECT path used by mt_member_read +
-- msg_member_read. Re-add a self-read policy so members can see their own row.
create policy mtm_self_read on public.message_thread_members
    for select using (auth.uid() = profile_id);
create policy mtm_self_leave on public.message_thread_members
    for delete using (auth.uid() = profile_id);
create policy mtm_self_mute on public.message_thread_members
    for update using (auth.uid() = profile_id) with check (auth.uid() = profile_id);


-- ─── #2 Crit + #10 High ─────────────────────────────────────────────────────
-- Tickets: revoke direct INSERT (was: any authed user could forge `status='paid'`).
-- buyer_id flipped to SET NULL so GDPR delete_my_account cascade doesn't hit RESTRICT.
drop policy if exists tk_buyer_insert on public.tickets;

alter table public.tickets
    drop constraint if exists tickets_buyer_id_fkey;
alter table public.tickets
    alter column buyer_id drop not null,
    add constraint tickets_buyer_id_fkey
        foreign key (buyer_id) references public.profiles(id) on delete set null;

create or replace function public.tickets_insert_from_webhook(
    p_ticket_type_id uuid,
    p_buyer_id       uuid,
    p_price_cents    int,
    p_stripe_session text,
    p_qr_token       text
) returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare new_id uuid;
begin
    insert into public.tickets (ticket_type_id, buyer_id, price_cents_paid, status, stripe_session_id, qr_token)
    values (p_ticket_type_id, p_buyer_id, p_price_cents, 'paid', p_stripe_session, p_qr_token)
    returning id into new_id;
    return new_id;
end;
$$;
revoke all on function public.tickets_insert_from_webhook(uuid, uuid, int, text, text) from public, anon, authenticated;
grant execute on function public.tickets_insert_from_webhook(uuid, uuid, int, text, text) to service_role;


-- ─── #11 High ───────────────────────────────────────────────────────────────
-- Promised GDPR data-export RPC. Bundles every user-referencing table.
create or replace function public.export_my_data()
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare uid uuid := auth.uid();
begin
    if uid is null then raise exception 'unauthorized'; end if;
    return jsonb_build_object(
        'profile',              (select to_jsonb(p) from public.profiles p where p.id = uid),
        'affiliations',         coalesce((select jsonb_agg(a) from public.campus_affiliations a where a.profile_id = uid), '[]'::jsonb),
        'memberships',          coalesce((select jsonb_agg(m) from public.memberships m where m.profile_id = uid), '[]'::jsonb),
        'rsvps',                coalesce((select jsonb_agg(r) from public.rsvps r where r.user_id = uid), '[]'::jsonb),
        'events_hosted',        coalesce((select jsonb_agg(e) from public.events e where e.host_id = uid), '[]'::jsonb),
        'friendships',          coalesce((select jsonb_agg(f) from public.friendships f where f.user_a = uid or f.user_b = uid), '[]'::jsonb),
        'messages',             coalesce((select jsonb_agg(m) from public.messages m where m.author_id = uid), '[]'::jsonb),
        'wellness_checkins',    coalesce((select jsonb_agg(w) from public.wellness_checkins w where w.profile_id = uid), '[]'::jsonb),
        'emergency_contacts',   coalesce((select jsonb_agg(c) from public.emergency_contacts c where c.profile_id = uid), '[]'::jsonb),
        'tickets',              coalesce((select jsonb_agg(t) from public.tickets t where t.buyer_id = uid), '[]'::jsonb),
        -- Push tokens are API credentials, not personal data. Export only metadata so
        -- the GDPR dump isn't itself a notification-takeover toolkit.
        'push_tokens',          coalesce((select jsonb_agg(jsonb_build_object('platform', p.platform, 'updated_at', p.updated_at)) from public.push_tokens p where p.profile_id = uid), '[]'::jsonb),
        'auth_identities',      coalesce((select jsonb_agg(a) from public.auth_identities a where a.profile_id = uid), '[]'::jsonb),
        'event_check_ins',      coalesce((select jsonb_agg(c) from public.event_check_ins c where c.profile_id = uid), '[]'::jsonb),
        'study_sessions',       coalesce((select jsonb_agg(s) from public.study_sessions s where s.organizer_id = uid), '[]'::jsonb),
        'professor_reviews',    coalesce((select jsonb_agg(r) from public.professor_reviews r where r.author_id = uid), '[]'::jsonb),
        'exported_at',          to_jsonb(now())
    );
end;
$$;
grant execute on function public.export_my_data() to authenticated;


-- ─── #12 High ───────────────────────────────────────────────────────────────
-- friends_going_to_event RPC. Server-side hide_attendees enforcement; mutual-friends only.
create or replace function public.friends_going_to_event(event_id uuid)
returns setof public.profiles
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare hidden bool;
begin
    if auth.uid() is null then return; end if;
    select e.hide_attendees into hidden from public.events e where e.id = event_id;
    if coalesce(hidden, false) then return; end if;
    return query
    select p.* from public.profiles p
    join public.rsvps r on r.user_id = p.id
    join public.friendships f on (
        (f.user_a = auth.uid() and f.user_b = p.id) or
        (f.user_b = auth.uid() and f.user_a = p.id)
    )
    where r.event_id = friends_going_to_event.event_id
      and r.status   = 'going'
      and f.status   = 'accepted';
end;
$$;
grant execute on function public.friends_going_to_event(uuid) to authenticated;


-- ─── #13 High ───────────────────────────────────────────────────────────────
-- rush_interests.chapter_mark must be officer-only. Rushees may edit only rushee_rank.
drop policy if exists ri_rushee_update on public.rush_interests;
create policy ri_rushee_update_rank on public.rush_interests
    for update using (auth.uid() = profile_id)
    with check (auth.uid() = profile_id);

create or replace function public.guard_rush_chapter_mark()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
    if new.chapter_mark is distinct from old.chapter_mark then
        if not exists (
            select 1 from public.memberships m
            where m.profile_id = auth.uid()
              and m.organization_id = old.organization_id
              and m.role in ('president','founder','vicePresident','officer')
        ) then
            raise exception 'only chapter officers may set chapter_mark';
        end if;
    end if;
    return new;
end;
$$;
drop trigger if exists trg_guard_rush_chapter_mark on public.rush_interests;
create trigger trg_guard_rush_chapter_mark
    before update on public.rush_interests
    for each row execute function public.guard_rush_chapter_mark();


-- ─── #15 High ───────────────────────────────────────────────────────────────
-- Co-host hijack: require explicit invite from the primary host.
create table if not exists public.co_host_invites (
    event_id        uuid not null references public.events(id) on delete cascade,
    organization_id uuid not null references public.organizations(id) on delete cascade,
    invited_by      uuid not null references public.profiles(id) on delete cascade,
    created_at      timestamptz not null default now(),
    primary key (event_id, organization_id)
);
alter table public.co_host_invites enable row level security;
alter table public.co_host_invites force row level security;

drop policy if exists chi_read on public.co_host_invites;
create policy chi_read on public.co_host_invites
    for select using (
        exists (select 1 from public.events e where e.id = co_host_invites.event_id and e.host_id = auth.uid())
        or exists (
            select 1 from public.memberships m
            where m.organization_id = co_host_invites.organization_id
              and m.profile_id = auth.uid()
              and m.role in ('president','founder','vicePresident','officer')
        )
    );

drop policy if exists chi_host_invite on public.co_host_invites;
create policy chi_host_invite on public.co_host_invites
    for insert with check (
        auth.uid() = invited_by
        and exists (select 1 from public.events e where e.id = event_id and e.host_id = auth.uid())
    );

drop policy if exists ech_write on public.event_co_hosts;
create policy ech_write_after_invite on public.event_co_hosts
    for insert with check (
        exists (
            select 1 from public.co_host_invites i
            where i.event_id = event_co_hosts.event_id
              and i.organization_id = event_co_hosts.organization_id
        )
        and exists (
            select 1 from public.memberships m
            where m.organization_id = event_co_hosts.organization_id
              and m.profile_id = auth.uid()
              and m.role in ('president','founder','vicePresident','officer')
        )
    );


-- ─── #18 High ───────────────────────────────────────────────────────────────
-- Webhook endpoints must be https + match the expected host per `kind`.
alter table public.webhook_endpoints
    drop constraint if exists webhook_endpoints_url_check;
alter table public.webhook_endpoints
    add constraint webhook_endpoints_url_check check (
        url ~* '^https://[^/]+/'
        and (
            (kind = 'discord' and url ~* '^https://discord(app)?\.com/api/webhooks/')
         or (kind = 'slack'   and url ~* '^https://hooks\.slack\.com/')
         or (kind = 'generic' and url !~* '\.(internal|local)(/|:|$)'
                              and url !~* '://(localhost|127\.|169\.254\.|10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.)')
        )
    );


-- ─── #20 High ───────────────────────────────────────────────────────────────
-- lock_affiliation_core didn't lock status; graduated users could flip back to active.
create or replace function public.lock_affiliation_core()
returns trigger language plpgsql as $$
begin
    if new.campus is distinct from old.campus
       or new.role is distinct from old.role
       or new.program is distinct from old.program
       or new.sub_campus is distinct from old.sub_campus
       or new.verification_method is distinct from old.verification_method then
        raise exception 'affiliation core fields are immutable post-verification';
    end if;
    -- Status: terminal states (graduated/transferred/withdrawn) may only be reactivated
    -- by the service role (admin restoration, returning student post-gap-year). Authenticated
    -- end-users cannot self-flip back to active.
    if old.status in ('graduated','transferred','withdrawn')
       and new.status not in ('graduated','transferred','withdrawn')
       and current_user not in ('postgres', 'supabase_admin', 'service_role') then
        raise exception 'cannot reactivate a terminal-state affiliation';
    end if;
    return new;
end;
$$;


-- ─── #21 Med ────────────────────────────────────────────────────────────────
-- Friendship initiator can't self-accept their own request.
create or replace function public.guard_friendship_accept()
returns trigger language plpgsql as $$
begin
    if new.status = 'accepted' and old.status = 'pending'
       and auth.uid() = old.initiated_by then
        raise exception 'only the recipient may accept the friend request';
    end if;
    return new;
end;
$$;
drop trigger if exists trg_guard_friendship_accept on public.friendships;
create trigger trg_guard_friendship_accept
    before update on public.friendships
    for each row execute function public.guard_friendship_accept();


-- ─── #23 Med ────────────────────────────────────────────────────────────────
-- Superseded by the visibility-checking policy at the bottom of this migration.


-- ─── #24 Med ────────────────────────────────────────────────────────────────
-- SECURITY DEFINER functions need pinned search_path. Re-create with explicit pin.
alter function public.delete_my_account()             set search_path = public, pg_temp;
alter function public.revoke_all_sessions()           set search_path = public, pg_temp;
-- Signature pulled from 0000; ALTER must match exactly or it targets nothing.
alter function public.verify_affiliation(text, text, public.affiliation_role, public.program_kind, public.academic_year, text, text, text)
    set search_path = public, pg_temp;
alter function public.log_membership_change()         set search_path = public, pg_temp;
alter function public.transfer_org_ownership(uuid, uuid) set search_path = public, pg_temp;


-- ─── #29 Med ────────────────────────────────────────────────────────────────
-- events.host_name must derive from organization/profile, not be free-text. Trigger
-- only fires on org/host change (not on direct host_name writes) so admin-side name
-- corrections via host_name still work.
create or replace function public.set_event_host_name()
returns trigger language plpgsql as $$
begin
    new.host_name := coalesce(
        (select o.name from public.organizations o where o.id = new.organization_id),
        (select p.display_name from public.profiles p where p.id = new.host_id),
        ''
    );
    return new;
end;
$$;
drop trigger if exists trg_set_event_host_name on public.events;
create trigger trg_set_event_host_name
    before insert or update of organization_id, host_id on public.events
    for each row execute function public.set_event_host_name();


-- ─── Auth callback compatibility ────────────────────────────────────────────
-- Migration 0000 omits `email`, `campus`, `verified` from profiles, but the web auth
-- callback writes those fields on first sign-in. Add the columns so the writes succeed
-- (previously silent drops). Indexed on email for the inbound-email officer lookup.
alter table public.profiles add column if not exists email     text;
-- ON DELETE SET NULL: profile survives if its campus row is removed (rename, dedup).
alter table public.profiles add column if not exists campus text references public.campuses(id) on delete set null;
alter table public.profiles add column if not exists verified  boolean not null default false;
create index if not exists profiles_email on public.profiles (lower(email));


-- ─── Campus waitlist: lock reads + add to GDPR delete path ──────────────────
-- 0001 has only an INSERT policy. Any authed user could SELECT the full email list.
-- FORCE RLS subjects service_role too, so we explicitly allow service_role + the postgres
-- role (admin tooling, analytics). All other authenticated reads are blocked.
drop policy if exists waitlist_read_blocked on public.campus_waitlist;
create policy waitlist_read_admin on public.campus_waitlist
    for select using (current_user in ('postgres', 'supabase_admin', 'service_role'));


-- ─── delete_my_account: drop waitlist + audit payload references ────────────
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare uid uuid := auth.uid();
        uemail text;
begin
    if uid is null then raise exception 'unauthorized'; end if;
    select email into uemail from auth.users where id = uid;
    if uemail is not null then
        delete from public.campus_waitlist where lower(email) = lower(uemail);
    end if;
    -- Scrub the user's profile_id out of audit_log payloads (cascade nulls actor_id;
    -- the payload jsonb still embeds the UUID, which is PII).
    update public.audit_log
       set payload = payload - 'profile_id'
     where payload ? 'profile_id' and (payload ->> 'profile_id') = uid::text;
    -- Original cascade-delete: removing the auth.users row tears down every FK that
    -- references profiles(id) via on-delete-cascade.
    delete from auth.users where id = uid;
end;
$$;
grant execute on function public.delete_my_account() to authenticated;


-- ─── em_authed_post: must check the user can READ the event, not just that it exists ─
-- Replaces the prior #23 patch which only verified existence. Visibility values match
-- the 0000 schema enum exactly ('public', 'campusOnly', 'officersOnly', 'inviteOnly').
drop policy if exists em_authed_post on public.event_messages;
create policy em_authed_post on public.event_messages
    for insert with check (
        auth.uid() = author_id
        and exists (
            select 1 from public.events e
            where e.id = event_messages.event_id
              and (
                coalesce(e.visibility, 'public') = 'public'
                or (e.visibility = 'campusOnly' and exists (
                    select 1 from public.campus_affiliations a
                    where a.profile_id = auth.uid() and a.campus = e.campus
                      and a.status = 'active'
                ))
                or (e.visibility = 'officersOnly' and exists (
                    select 1 from public.memberships m
                    where m.profile_id = auth.uid()
                      and m.organization_id = e.organization_id
                      and m.status = 'active'
                      and m.role in ('president','founder','vicePresident','officer')
                ))
                or (e.visibility = 'inviteOnly' and exists (
                    select 1 from public.event_invites i
                    where i.event_id = e.id and i.profile_id = auth.uid()
                ))
                or e.host_id = auth.uid()
              )
        )
    );


-- ─── #30 Med ────────────────────────────────────────────────────────────────
-- FORCE RLS on tables with PII / payments / moderation / location / health data.
-- `sos_events` removed: the table doesn't exist yet (Safety SOS writes to the dialer
-- only). When it lands, the creating migration must add `force row level security` itself.
alter table public.wellness_checkins   force row level security;
alter table public.emergency_contacts  force row level security;
alter table public.auth_identities     force row level security;
alter table public.audit_log           force row level security;
alter table public.safe_walks          force row level security;
alter table public.tickets             force row level security;
alter table public.messages            force row level security;
alter table public.event_drafts        force row level security;
alter table public.push_tokens         force row level security;
-- High-PII tables that the original schema enabled but didn't FORCE:
alter table public.profiles            force row level security;
alter table public.rsvps               force row level security;
alter table public.campus_waitlist     force row level security;
alter table public.event_check_ins     force row level security;
alter table public.study_sessions      force row level security;


-- ─── #31 Med ────────────────────────────────────────────────────────────────
-- Users can delete (soft-delete) their own messages.
alter table public.messages add column if not exists deleted_at timestamptz;

drop policy if exists msg_author_soft_delete on public.messages;
create policy msg_author_soft_delete on public.messages
    for update using (auth.uid() = author_id)
    with check (auth.uid() = author_id);


-- ─── #36 Low ────────────────────────────────────────────────────────────────
-- events_insert when organization_id is set must require officer role.
drop policy if exists events_insert on public.events;
create policy events_insert on public.events
    for insert with check (
        auth.uid() = host_id
        and (
            organization_id is null
            or exists (
                select 1 from public.memberships m
                where m.organization_id = events.organization_id
                  and m.profile_id = auth.uid()
                  and m.status = 'active'
                  and m.role in ('president','founder','vicePresident','officer')
            )
        )
    );


-- ─── #35 Low ────────────────────────────────────────────────────────────────
-- broadcasts.sent_by must be pinned to auth.uid() server-side.
create or replace function public.set_broadcast_sender()
returns trigger language plpgsql as $$
begin new.sent_by := auth.uid(); return new; end;
$$;
drop trigger if exists trg_set_broadcast_sender on public.broadcasts;
create trigger trg_set_broadcast_sender
    before insert on public.broadcasts
    for each row execute function public.set_broadcast_sender();


-- ─── #14 High ───────────────────────────────────────────────────────────────
-- Professor reviews: hide author_id when is_anonymous. Public view + revoke base.
-- Column names match `0000_initial_schema.sql`: `text` (body) and `course_id` (FK).
create or replace view public.professor_reviews_public as
    select id, professor_id, course_id, rating, difficulty, text, created_at,
           case when is_anonymous then null else author_id end as author_id,
           is_anonymous
    from public.professor_reviews;
grant select on public.professor_reviews_public to authenticated;
revoke select on public.professor_reviews from authenticated, anon;
