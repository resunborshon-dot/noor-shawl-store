create extension if not exists pgcrypto;
create table if not exists public.orders (
 id uuid primary key default gen_random_uuid(), order_number text unique not null,
 customer_name text not null, phone text not null, email text, address text not null, city text not null,
 delivery_zone text check (delivery_zone in ('inside','outside')), delivery_charge integer not null default 0,
 items jsonb not null, subtotal integer not null default 0, total integer not null check (total >= 0),
 payment_method text not null check (payment_method in ('COD','bKash','Nagad')),
 payment_id text, transaction_id text, payment_status text not null default 'Pending',
 status text not null default 'New', created_at timestamptz not null default now()
);
alter table public.orders add column if not exists delivery_zone text;
alter table public.orders add column if not exists delivery_charge integer not null default 0;
alter table public.orders add column if not exists subtotal integer not null default 0;
alter table public.orders add column if not exists payment_id text;
alter table public.orders add column if not exists payment_status text not null default 'Pending';
alter table public.orders enable row level security;
revoke all on public.orders from anon, authenticated;
