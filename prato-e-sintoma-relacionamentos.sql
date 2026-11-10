-- Prato e Sintoma: relacionar sintomas às refeições
-- Execute este script no SQL Editor do Supabase antes de publicar o HTML atualizado.

-- Permite que as chaves compostas garantam que a relação use registros do mesmo usuário.
create unique index if not exists meals_id_user_id_uidx
  on public.meals (id, user_id);

create unique index if not exists symptoms_id_user_id_uidx
  on public.symptoms (id, user_id);

create table if not exists public.symptom_meals (
  user_id uuid not null default auth.uid(),
  symptom_id text not null,
  meal_id text not null,
  created_at timestamptz not null default now(),
  primary key (symptom_id, meal_id),
  constraint symptom_meals_user_id_fkey
    foreign key (user_id) references auth.users(id) on delete cascade,
  constraint symptom_meals_symptom_user_fkey
    foreign key (symptom_id, user_id)
    references public.symptoms(id, user_id) on delete cascade,
  constraint symptom_meals_meal_user_fkey
    foreign key (meal_id, user_id)
    references public.meals(id, user_id) on delete cascade
);

create index if not exists symptom_meals_user_id_idx
  on public.symptom_meals (user_id);

create index if not exists symptom_meals_meal_id_idx
  on public.symptom_meals (meal_id);

alter table public.symptom_meals enable row level security;

drop policy if exists own_symptom_meals on public.symptom_meals;
create policy own_symptom_meals
  on public.symptom_meals
  for all
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
