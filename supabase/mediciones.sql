-- Tabla de mediciones de Golfy: cada fila es una medición de UN usuario.
-- Pégalo en Supabase: SQL Editor -> New query -> Run. Se corre una sola vez.

create table if not exists public.mediciones (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid()
              references auth.users on delete cascade,
  fecha       date not null default current_date,
  peso        numeric(5, 2) not null check (peso between 20 and 300),
  estatura    numeric(3, 2) not null check (estatura between 1 and 2.5),
  pulso       int check (pulso between 30 and 220),
  created_at  timestamptz not null default now()
);

-- Las políticas filtran por user_id: un índice hace rápida esa búsqueda.
create index if not exists mediciones_user_id_idx
  on public.mediciones (user_id);

-- Solo los usuarios con sesión pueden tocar la tabla, y solo con lo necesario.
revoke all on public.mediciones from anon, authenticated;
grant select, insert, update, delete on public.mediciones to authenticated;

-- Sin RLS, cualquiera con la publishable key leería TODAS las filas.
-- Al activarlo, nadie ve nada hasta que una política lo permita.
alter table public.mediciones enable row level security;

-- Cada usuario solo ve, crea, edita y borra SUS mediciones.
create policy "ver mis mediciones"
  on public.mediciones for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "crear mis mediciones"
  on public.mediciones for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "editar mis mediciones"
  on public.mediciones for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "borrar mis mediciones"
  on public.mediciones for delete
  to authenticated
  using ((select auth.uid()) = user_id);