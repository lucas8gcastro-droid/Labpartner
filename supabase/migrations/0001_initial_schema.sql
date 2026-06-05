-- =============================================================================
-- LabPartner — Esquema inicial do banco de dados
-- Plataforma B2B de cotações de química fina para representantes universitários
-- Alvo: Supabase / PostgreSQL 15+
--
-- COMO APLICAR:
--   1. Supabase Studio > SQL Editor > cole este arquivo e execute; ou
--   2. CLI:  supabase db push   (com este arquivo em supabase/migrations/)
--
-- Esta migration é idempotente o suficiente para um primeiro setup limpo.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- EXTENSÕES
-- -----------------------------------------------------------------------------
create extension if not exists "pgcrypto";       -- gen_random_uuid()

-- -----------------------------------------------------------------------------
-- ENUMS (valores internos em inglês para estabilidade do código; a UI traduz)
-- -----------------------------------------------------------------------------
do $$ begin
  create type public.user_role as enum ('representative', 'admin');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.product_category as enum ('solvent', 'reagent', 'acid', 'base', 'lab_supply');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.quote_status as enum ('pending', 'approved', 'rejected', 'delivered');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.urgency_level as enum ('low', 'normal', 'high');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.payment_status as enum ('pending', 'paid');
exception when duplicate_object then null; end $$;

-- =============================================================================
-- TABELA: users (perfil público que estende auth.users)
-- O Supabase já mantém auth.users (credenciais). Aqui guardamos o perfil de
-- negócio. A linha é criada automaticamente por trigger no cadastro (ver abaixo).
-- =============================================================================
create table if not exists public.users (
  id              uuid primary key references auth.users (id) on delete cascade,
  full_name       text        not null,
  email           text        not null,
  phone           text,
  university      text,
  course          text,
  semester        text,
  pix_key         text,
  role            public.user_role not null default 'representative',
  -- Percentual de comissão do representante (0.10 = 10%). Usado no cálculo automático.
  commission_rate numeric(5,4) not null default 0.1000 check (commission_rate >= 0 and commission_rate <= 1),
  avatar_url      text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

comment on table  public.users is 'Perfil de negócio do usuário, estendendo auth.users.';
comment on column public.users.commission_rate is 'Percentual de comissão (0..1). Ex.: 0.10 = 10%.';

-- =============================================================================
-- TABELA: products (catálogo de química fina)
-- =============================================================================
create table if not exists public.products (
  id                  uuid primary key default gen_random_uuid(),
  name                text not null,
  cas_number          text,                       -- CAS Registry Number (ex.: 67-56-1)
  category            public.product_category not null,
  purity              text,                        -- ex.: '99.9% (HPLC)'
  packaging           text,                        -- ex.: 'Frasco 1 L'
  technical_description text,
  price               numeric(12,2) not null default 0 check (price >= 0),
  unit                text not null default 'un',  -- un, L, kg, g...
  stock               integer not null default 0 check (stock >= 0),
  image_url           text,
  is_active           boolean not null default true,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

comment on table public.products is 'Catálogo de produtos de química fina.';
create index if not exists idx_products_category on public.products (category);
create index if not exists idx_products_active   on public.products (is_active);
-- Busca textual simples por nome / CAS
create index if not exists idx_products_name_trgm on public.products using gin (to_tsvector('portuguese', coalesce(name, '') || ' ' || coalesce(cas_number, '')));

-- =============================================================================
-- TABELA: quotes (cotações — funcionalidade central)
-- Para o MVP, dados do professor/laboratório são campos da cotação (sem cadastro
-- separado), conforme escopo enxuto.
-- =============================================================================
create table if not exists public.quotes (
  id              uuid primary key default gen_random_uuid(),
  -- Número sequencial legível por humanos (ex.: COT-000123). Gerado por trigger.
  quote_number    text unique,
  representative_id uuid not null references public.users (id) on delete restrict,

  -- Contexto acadêmico (texto livre no MVP)
  professor_name  text not null,
  laboratory      text,
  department      text,
  university      text,
  observations    text,
  urgency         public.urgency_level not null default 'normal',

  status          public.quote_status not null default 'pending',
  total_amount    numeric(12,2) not null default 0 check (total_amount >= 0),

  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  approved_at     timestamptz,
  delivered_at    timestamptz
);

comment on table public.quotes is 'Cotações geradas pelos representantes.';
create index if not exists idx_quotes_representative on public.quotes (representative_id);
create index if not exists idx_quotes_status        on public.quotes (status);
create index if not exists idx_quotes_created_at    on public.quotes (created_at desc);

-- =============================================================================
-- TABELA: quote_items (itens de cada cotação)
-- unit_price é um "snapshot" do preço no momento da cotação (preço pode mudar).
-- line_total é coluna gerada (não editável).
-- =============================================================================
create table if not exists public.quote_items (
  id          uuid primary key default gen_random_uuid(),
  quote_id    uuid not null references public.quotes (id) on delete cascade,
  product_id  uuid not null references public.products (id) on delete restrict,
  quantity    integer not null check (quantity > 0),
  unit_price  numeric(12,2) not null check (unit_price >= 0),
  line_total  numeric(12,2) generated always as (quantity * unit_price) stored,
  created_at  timestamptz not null default now()
);

comment on table public.quote_items is 'Itens (produtos + quantidades) de uma cotação.';
create index if not exists idx_quote_items_quote on public.quote_items (quote_id);
create unique index if not exists uq_quote_items_quote_product on public.quote_items (quote_id, product_id);

-- =============================================================================
-- TABELA: commissions (uma comissão por cotação aprovada)
-- commission_amount é coluna gerada a partir de total_amount * percentage.
-- =============================================================================
create table if not exists public.commissions (
  id                uuid primary key default gen_random_uuid(),
  quote_id          uuid not null unique references public.quotes (id) on delete cascade,
  representative_id  uuid not null references public.users (id) on delete restrict,
  total_amount      numeric(12,2) not null check (total_amount >= 0),
  percentage        numeric(5,4)  not null check (percentage >= 0 and percentage <= 1),
  commission_amount numeric(12,2) generated always as (round(total_amount * percentage, 2)) stored,
  payment_status    public.payment_status not null default 'pending',
  created_at        timestamptz not null default now(),
  paid_at           timestamptz
);

comment on table public.commissions is 'Comissões geradas automaticamente ao aprovar uma cotação.';
create index if not exists idx_commissions_representative on public.commissions (representative_id);
create index if not exists idx_commissions_payment_status on public.commissions (payment_status);

-- =============================================================================
-- FUNÇÕES E TRIGGERS
-- =============================================================================

-- ----- 1. updated_at automático -----------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists trg_users_updated_at on public.users;
create trigger trg_users_updated_at
  before update on public.users
  for each row execute function public.set_updated_at();

drop trigger if exists trg_products_updated_at on public.products;
create trigger trg_products_updated_at
  before update on public.products
  for each row execute function public.set_updated_at();

drop trigger if exists trg_quotes_updated_at on public.quotes;
create trigger trg_quotes_updated_at
  before update on public.quotes
  for each row execute function public.set_updated_at();

-- ----- 2. Criação automática do perfil no cadastro -----------------------------
-- Lê os metadados enviados no signUp (data: {...}) e cria a linha em public.users.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (id, full_name, email, phone, university, course, semester, pix_key, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    new.email,
    new.raw_user_meta_data ->> 'phone',
    new.raw_user_meta_data ->> 'university',
    new.raw_user_meta_data ->> 'course',
    new.raw_user_meta_data ->> 'semester',
    new.raw_user_meta_data ->> 'pix_key',
    coalesce((new.raw_user_meta_data ->> 'role')::public.user_role, 'representative')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists trg_on_auth_user_created on auth.users;
create trigger trg_on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ----- 3. Número sequencial legível da cotação ---------------------------------
create sequence if not exists public.quote_number_seq start 1;

create or replace function public.set_quote_number()
returns trigger
language plpgsql
as $$
begin
  if new.quote_number is null then
    new.quote_number := 'COT-' || lpad(nextval('public.quote_number_seq')::text, 6, '0');
  end if;
  return new;
end;
$$;

drop trigger if exists trg_quotes_set_number on public.quotes;
create trigger trg_quotes_set_number
  before insert on public.quotes
  for each row execute function public.set_quote_number();

-- ----- 4. Recalcular total da cotação quando itens mudam -----------------------
create or replace function public.recalculate_quote_total()
returns trigger
language plpgsql
as $$
declare
  v_quote_id uuid;
begin
  v_quote_id := coalesce(new.quote_id, old.quote_id);

  update public.quotes q
     set total_amount = coalesce((
       select sum(line_total) from public.quote_items where quote_id = v_quote_id
     ), 0)
   where q.id = v_quote_id;

  return null; -- trigger AFTER, retorno ignorado
end;
$$;

drop trigger if exists trg_quote_items_recalc on public.quote_items;
create trigger trg_quote_items_recalc
  after insert or update or delete on public.quote_items
  for each row execute function public.recalculate_quote_total();

-- ----- 5. Gerar comissão automática ao aprovar a cotação -----------------------
create or replace function public.handle_quote_approval()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_rate numeric(5,4);
begin
  -- Disparou ao mudar para 'approved'
  if new.status = 'approved' and (old.status is distinct from 'approved') then
    new.approved_at := coalesce(new.approved_at, now());

    select commission_rate into v_rate
      from public.users where id = new.representative_id;

    insert into public.commissions (quote_id, representative_id, total_amount, percentage)
    values (new.id, new.representative_id, new.total_amount, coalesce(v_rate, 0.10))
    on conflict (quote_id) do update
      set total_amount = excluded.total_amount,
          percentage   = excluded.percentage;
  end if;

  -- Marca data de entrega
  if new.status = 'delivered' and (old.status is distinct from 'delivered') then
    new.delivered_at := coalesce(new.delivered_at, now());
  end if;

  return new;
end;
$$;

drop trigger if exists trg_quotes_approval on public.quotes;
create trigger trg_quotes_approval
  before update on public.quotes
  for each row execute function public.handle_quote_approval();

-- =============================================================================
-- HELPER DE SEGURANÇA
-- Verifica se o usuário atual é admin. SECURITY DEFINER evita recursão de RLS
-- (uma policy na tabela users que consultasse users entraria em loop).
-- =============================================================================
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.users
    where id = auth.uid() and role = 'admin'
  );
$$;

-- =============================================================================
-- ROW LEVEL SECURITY
-- =============================================================================
alter table public.users       enable row level security;
alter table public.products    enable row level security;
alter table public.quotes      enable row level security;
alter table public.quote_items enable row level security;
alter table public.commissions enable row level security;

-- ----- USERS -------------------------------------------------------------------
drop policy if exists users_select_self_or_admin on public.users;
create policy users_select_self_or_admin on public.users
  for select to authenticated
  using (id = auth.uid() or public.is_admin());

drop policy if exists users_update_self_or_admin on public.users;
create policy users_update_self_or_admin on public.users
  for update to authenticated
  using (id = auth.uid() or public.is_admin())
  with check (id = auth.uid() or public.is_admin());

-- (INSERT é feito pelo trigger handle_new_user via SECURITY DEFINER, então
--  não expomos policy de INSERT direta.)

-- ----- PRODUCTS ----------------------------------------------------------------
-- Todos autenticados leem os ativos; admin gerencia tudo.
drop policy if exists products_select_all on public.products;
create policy products_select_all on public.products
  for select to authenticated
  using (is_active = true or public.is_admin());

drop policy if exists products_admin_write on public.products;
create policy products_admin_write on public.products
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- ----- QUOTES ------------------------------------------------------------------
-- Representante vê/gerencia as próprias; admin vê todas.
drop policy if exists quotes_select_own_or_admin on public.quotes;
create policy quotes_select_own_or_admin on public.quotes
  for select to authenticated
  using (representative_id = auth.uid() or public.is_admin());

drop policy if exists quotes_insert_own on public.quotes;
create policy quotes_insert_own on public.quotes
  for insert to authenticated
  with check (representative_id = auth.uid());

-- Representante edita a própria cotação enquanto pendente; admin edita qualquer
-- (necessário para aprovar/recusar/entregar e mudar status).
drop policy if exists quotes_update_own_pending_or_admin on public.quotes;
create policy quotes_update_own_pending_or_admin on public.quotes
  for update to authenticated
  using (
    public.is_admin()
    or (representative_id = auth.uid() and status = 'pending')
  )
  with check (
    public.is_admin()
    or (representative_id = auth.uid())
  );

drop policy if exists quotes_delete_own_pending_or_admin on public.quotes;
create policy quotes_delete_own_pending_or_admin on public.quotes
  for delete to authenticated
  using (public.is_admin() or (representative_id = auth.uid() and status = 'pending'));

-- ----- QUOTE_ITEMS -------------------------------------------------------------
-- Acesso herdado da posse da cotação-pai.
drop policy if exists quote_items_select on public.quote_items;
create policy quote_items_select on public.quote_items
  for select to authenticated
  using (
    public.is_admin()
    or exists (
      select 1 from public.quotes q
      where q.id = quote_items.quote_id and q.representative_id = auth.uid()
    )
  );

drop policy if exists quote_items_write_own_pending on public.quote_items;
create policy quote_items_write_own_pending on public.quote_items
  for all to authenticated
  using (
    public.is_admin()
    or exists (
      select 1 from public.quotes q
      where q.id = quote_items.quote_id
        and q.representative_id = auth.uid()
        and q.status = 'pending'
    )
  )
  with check (
    public.is_admin()
    or exists (
      select 1 from public.quotes q
      where q.id = quote_items.quote_id
        and q.representative_id = auth.uid()
        and q.status = 'pending'
    )
  );

-- ----- COMMISSIONS -------------------------------------------------------------
-- Representante vê as próprias; admin gerencia (inclui marcar como paga).
drop policy if exists commissions_select_own_or_admin on public.commissions;
create policy commissions_select_own_or_admin on public.commissions
  for select to authenticated
  using (representative_id = auth.uid() or public.is_admin());

drop policy if exists commissions_admin_write on public.commissions;
create policy commissions_admin_write on public.commissions
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- =============================================================================
-- SEED OPCIONAL — alguns produtos de exemplo para validar o catálogo.
-- (Remova em produção, ou rode apenas em ambiente de desenvolvimento.)
-- =============================================================================
insert into public.products (name, cas_number, category, purity, packaging, technical_description, price, unit, stock)
values
  ('Metanol P.A.',            '67-56-1',  'solvent',     '99.9% (HPLC)',  'Frasco 1 L',  'Solvente orgânico de alta pureza para HPLC e síntese.',         48.90,  'L',  120),
  ('Ácido Clorídrico 37%',    '7647-01-0','acid',        '37% (P.A.)',    'Frasco 1 L',  'Ácido mineral forte, grau analítico.',                          39.50,  'L',  80),
  ('Hidróxido de Sódio',      '1310-73-2','base',        '98% (lentilhas)','Frasco 500 g','Base forte em lentilhas para preparo de soluções.',            29.90,  'kg', 60),
  ('Acetonitrila',            '75-05-8',  'solvent',     '99.9% (HPLC)',  'Frasco 1 L',  'Solvente aprótico polar para cromatografia.',                   95.00,  'L',  45),
  ('Sulfato de Cobre II',     '7758-98-7','reagent',     '99% (P.A.)',    'Frasco 250 g','Reagente analítico para titulações e ensaios.',                 34.20,  'kg', 30),
  ('Luvas de Nitrila (cx)',   null,       'lab_supply',  null,            'Caixa 100 un','EPI descartável, sem pó, tamanho M.',                           42.00,  'cx', 200)
on conflict do nothing;

-- =============================================================================
-- FIM
-- =============================================================================
