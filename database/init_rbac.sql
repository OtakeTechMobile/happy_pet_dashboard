-- Create a custom enum for user roles if it doesn't exist
create type public.user_role as enum ('admin', 'owner', 'staff', 'tutor');

-- Create a table for public user profiles
create table if not exists public.users (
  id uuid references auth.users(id) on delete cascade not null primary key,
  full_name text,
  role public.user_role default 'tutor'::public.user_role,
  phone text,
  hotel_id uuid, -- Link to a hotel if applicable
  is_active boolean default true,
  created_at sections.timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at sections.timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable Row Level Security (RLS)
alter table public.users enable row level security;

-- Policy: Users can view their own profile
create policy "Users can view own profile"
  on public.users for select
  using ( auth.uid() = id );

-- Policy: Users can update their own profile
create policy "Users can update own profile"
  on public.users for update
  using ( auth.uid() = id );

-- Policy: Admins can view all profiles
create policy "Admins can view all profiles"
  on public.users for select
  using (
    auth.uid() in (
      select id from public.users where role = 'admin'
    )
  );

-- Policy: Owners can view profiles related to their hotel (assuming hotel_id logic in future, for now same as admin or broad)
-- For simplicity, let's allow Owners to view all for now, or refine based on hotel_id later.
create policy "Owners can view all profiles"
  on public.users for select
  using (
     auth.uid() in (
      select id from public.users where role = 'owner'
    )
  );

-- Trigger to handle new user signup
-- This ensures a row in public.users is created whenever a new user signs up via Supabase Auth
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users (id, full_name, role)
  values (
    new.id,
    new.raw_user_meta_data->>'full_name',
    coalesce((new.raw_user_meta_data->>'role')::public.user_role, 'tutor'::public.user_role)
  );
  return new;
end;
$$ language plpgsql security definer;

-- Trigger creates the public profile on signup
create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Grant permissions (optional, depends on default setup)
grant select, insert, update on public.users to authenticated;
grant usage on type public.user_role to authenticated;
