-- 0003_indexes_and_payments.sql
-- Closes the perf indexes flagged by the cross-platform performance audit plus the
-- payments-flow gaps (stripe_events_seen, ticket overselling guard, pending-status RPC,
-- mark-used RPC, refund RPC). Idempotent.

-- ─── Missing query-path indexes ─────────────────────────────────────────────
create index if not exists rsvps_user        on public.rsvps (user_id);
create index if not exists fr_a              on public.friendships (user_a);
create index if not exists pr_professor      on public.professor_reviews (professor_id);
create index if not exists events_host_handle on public.events (host_handle);
create index if not exists bc_org_time       on public.broadcasts (organization_id, sent_at desc);


-- ─── Stripe webhook idempotency ─────────────────────────────────────────────
create table if not exists public.stripe_events_seen (
    event_id    text primary key,
    received_at timestamptz not null default now()
);
alter table public.stripe_events_seen enable row level security;
alter table public.stripe_events_seen force row level security;
-- service_role bypass is the only intended consumer; no policy needed.


-- ─── Stripe Connect onboarding ──────────────────────────────────────────────
alter table public.organizations
    add column if not exists stripe_connect_account_id text;


-- ─── Ticket overselling guard ───────────────────────────────────────────────
create or replace function public.enforce_ticket_quantity()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare cap int; sold int;
begin
    select quantity_total into cap from public.ticket_types where id = new.ticket_type_id for update;
    if cap is null then return new; end if;
    select count(*) into sold from public.tickets
     where ticket_type_id = new.ticket_type_id and status in ('pending', 'paid');
    if sold >= cap then
        raise exception 'sold_out';
    end if;
    return new;
end;
$$;
drop trigger if exists trg_enforce_ticket_quantity on public.tickets;
create trigger trg_enforce_ticket_quantity
    before insert on public.tickets
    for each row execute function public.enforce_ticket_quantity();


-- ─── Checkout: insert pending ticket via service-role-only RPC ──────────────
create or replace function public.tickets_insert_pending(
    p_ticket_type_id  uuid,
    p_buyer_id        uuid,
    p_price_cents     int,
    p_stripe_session  text
) returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare new_id uuid;
begin
    insert into public.tickets (ticket_type_id, buyer_id, price_cents_paid, status, stripe_session_id, qr_token)
    values (
        p_ticket_type_id, p_buyer_id, p_price_cents, 'pending', p_stripe_session,
        encode(gen_random_bytes(32), 'hex')
    )
    returning id into new_id;
    return new_id;
end;
$$;
revoke all on function public.tickets_insert_pending(uuid, uuid, int, text) from public, anon, authenticated;
grant execute on function public.tickets_insert_pending(uuid, uuid, int, text) to service_role;


-- ─── Webhook: mark refunded + invalidate QR ─────────────────────────────────
create or replace function public.tickets_mark_refunded(p_stripe_session text)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
    update public.tickets
       set status = 'refunded',
           qr_token = 'refunded:' || encode(gen_random_bytes(16), 'hex')
     where stripe_session_id = p_stripe_session;
end;
$$;
revoke all on function public.tickets_mark_refunded(text) from public, anon, authenticated;
grant execute on function public.tickets_mark_refunded(text) to service_role;


-- ─── Door scanner: atomic mark-used ─────────────────────────────────────────
create or replace function public.tickets_mark_used(p_ticket_id uuid, p_token text)
returns boolean
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare ok boolean;
begin
    update public.tickets
       set status = 'used', used_at = now()
     where id = p_ticket_id and qr_token = p_token and status = 'paid'
    returning true into ok;
    return coalesce(ok, false);
end;
$$;
revoke all on function public.tickets_mark_used(uuid, text) from public, anon, authenticated;
grant execute on function public.tickets_mark_used(uuid, text) to service_role;


-- ─── Partial GiST on published, future events (audit #21) ───────────────────
-- Time-based predicate must stay in the query — `now()` isn't immutable — but the
-- status filter is, so this partial cuts the index size + improves selectivity.
create index if not exists events_geo_published on public.events using gist (geo)
    where status = 'published';
