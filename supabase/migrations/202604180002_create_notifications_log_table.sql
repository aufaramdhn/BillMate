-- S3-T07: notifications_log table for schedule/send/cancel audit

create table if not exists public.notifications_log (
  id uuid primary key default gen_random_uuid(),
  bill_id uuid not null references public.bills(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  trigger_type text not null check (trigger_type in ('h3', 'h1', 'h0')),
  status text not null check (status in ('scheduled', 'sent', 'cancelled')),
  event_time timestamptz not null default timezone('utc', now())
);

create index if not exists idx_notifications_log_bill_id
  on public.notifications_log(bill_id);

create index if not exists idx_notifications_log_user_id
  on public.notifications_log(user_id);

create index if not exists idx_notifications_log_event_time
  on public.notifications_log(event_time);

alter table public.notifications_log enable row level security;

drop policy if exists "Users can view own notifications logs" on public.notifications_log;
create policy "Users can view own notifications logs"
on public.notifications_log
for select
using (auth.uid() = user_id);

drop policy if exists "Users can insert own notifications logs" on public.notifications_log;
create policy "Users can insert own notifications logs"
on public.notifications_log
for insert
with check (auth.uid() = user_id);
