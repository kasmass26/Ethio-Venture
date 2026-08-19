-- This project uses public.users, not public.profiles.
-- public.users must already exist with the account_type enum from the supplied
-- schema. Apply this in Supabase Dashboard > SQL Editor.

alter table public.users enable row level security;

drop policy if exists "Users can view their own user record" on public.users;
create policy "Users can view their own user record"
  on public.users for select to authenticated
  using ((select auth.uid()) = id);

-- Runs with database-owner rights so it works even when email confirmation is
-- on and signUp therefore returns no client session.
create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.users (id, email, full_name, account_type)
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    case
      when new.raw_user_meta_data ->> 'role' = 'investor'
        then 'investor'::public.account_type
      else 'startup'::public.account_type
    end
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_auth_user();

-- Includes accounts created before this trigger was installed.
insert into public.users (id, email, full_name, account_type)
select
  id,
  coalesce(email, ''),
  coalesce(raw_user_meta_data ->> 'full_name', ''),
  case
    when raw_user_meta_data ->> 'role' = 'investor'
      then 'investor'::public.account_type
    else 'startup'::public.account_type
  end
from auth.users
on conflict (id) do nothing;
