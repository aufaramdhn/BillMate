-- S2-T01: Create bills table and enable Row Level Security (RLS)

create extension if not exists pgcrypto;

create table if not exists public.bills (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title varchar(120) not null,
  amount numeric(12, 2) not null check (amount > 0),
  category text not null check (
    category in ('listrik', 'air', 'internet', 'cicilan', 'streaming', 'lainnya')
  ),
  due_date date not null,
  is_paid boolean not null default false,
  is_recurring boolean not null default false,
  recurrence_interval text null check (
    recurrence_interval in ('monthly', 'yearly')
  ),
  notes text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint bills_recurrence_required check (
    (is_recurring = false and recurrence_interval is null)
    or (is_recurring = true and recurrence_interval is not null)
  )
);

create index if not exists idx_bills_user_id on public.bills(user_id);
create index if not exists idx_bills_due_date on public.bills(due_date);
create index if not exists idx_bills_is_paid on public.bills(is_paid);

alter table public.bills enable row level security;

drop policy if exists "Users can view own bills" on public.bills;
create policy "Users can view own bills"
on public.bills
for select
using (auth.uid() = user_id);

drop policy if exists "Users can insert own bills" on public.bills;
create policy "Users can insert own bills"
on public.bills
for insert
with check (auth.uid() = user_id);

drop policy if exists "Users can update own bills" on public.bills;
create policy "Users can update own bills"
on public.bills
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can delete own bills" on public.bills;
create policy "Users can delete own bills"
on public.bills
for delete
using (auth.uid() = user_id);
