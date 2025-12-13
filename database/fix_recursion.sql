-- Fix for "infinite recursion detected in policy for relation users"

-- 1. Create a secure function to check user role without triggering RLS loop
-- 'SECURITY DEFINER' means this function runs with the privileges of the creator (superuser/owner),
-- bypassing the RLS policies on the table it queries.
create or replace function public.get_my_role()
returns public.user_role
language sql
security definer
stable
set search_path = public -- Best practice for security definers
as $$
  select role from public.users where id = auth.uid();
$$;

-- 2. Drop the problematic policies that caused recursion
drop policy if exists "Admins can view all profiles" on public.users;
drop policy if exists "Owners can view all profiles" on public.users;

-- 3. Re-create policies using the secure function instead of direct table query
create policy "Admins can view all profiles"
  on public.users for select
  using (
    public.get_my_role() = 'admin'
  );

create policy "Owners can view all profiles"
  on public.users for select
  using (
    public.get_my_role() = 'owner'
  );
