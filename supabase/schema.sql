-- 在 Supabase 控制台：SQL Editor → New query → 粘贴本文件全部内容 → Run
-- 作用：学习笔记表 + 仅登录用户可读写自己的数据（RLS）
-- 请先在 Authentication → Providers 中启用 Email

create table if not exists public.learning_notes (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  text text not null,
  tags text[] not null default '{}',
  user_id uuid references auth.users (id) on delete cascade
);

-- 旧表补列
alter table public.learning_notes
  add column if not exists tags text[] not null default '{}';

alter table public.learning_notes
  add column if not exists user_id uuid references auth.users (id) on delete cascade;

-- 无法归属到账号的旧数据（匿名演示期）删除，避免策略无法收紧
delete from public.learning_notes
where user_id is null;

alter table public.learning_notes
  alter column user_id set default auth.uid();

alter table public.learning_notes
  alter column user_id set not null;

comment on table public.learning_notes is '学习笔记：按 user_id 隔离，需登录';

comment on column public.learning_notes.tags is '笔记标签，可多选';

comment on column public.learning_notes.user_id is '所属用户；插入时默认 auth.uid()';

create index if not exists learning_notes_tags_gin
  on public.learning_notes using gin (tags);

drop policy if exists "learning_notes_select_anon" on public.learning_notes;
drop policy if exists "learning_notes_insert_anon" on public.learning_notes;
drop policy if exists "learning_notes_select_own" on public.learning_notes;
drop policy if exists "learning_notes_insert_own" on public.learning_notes;

alter table public.learning_notes enable row level security;

create policy "learning_notes_select_own"
  on public.learning_notes
  for select
  to authenticated
  using (auth.uid() = user_id);

create policy "learning_notes_insert_own"
  on public.learning_notes
  for insert
  to authenticated
  with check (auth.uid() = user_id);
