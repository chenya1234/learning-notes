-- 已有 learning_notes 表时：在 Supabase → SQL Editor 运行本文件一次
-- 作用：每条笔记归属登录用户；匿名无法读写；旧的无归属数据会被删除（原演示数据）
-- 运行前请在控制台 Authentication → Providers 中启用 Email

-- 去掉旧的「全员可读可写」策略
drop policy if exists "learning_notes_select_anon" on public.learning_notes;
drop policy if exists "learning_notes_insert_anon" on public.learning_notes;
drop policy if exists "learning_notes_select_own" on public.learning_notes;
drop policy if exists "learning_notes_insert_own" on public.learning_notes;

alter table public.learning_notes
  add column if not exists user_id uuid references auth.users (id) on delete cascade;

-- 迁移前写入的笔记没有 user_id，无法归属到具体账号，按安全策略直接清除
delete from public.learning_notes
where user_id is null;

alter table public.learning_notes
  alter column user_id set default auth.uid();

alter table public.learning_notes
  alter column user_id set not null;

comment on column public.learning_notes.user_id is '笔记所属用户，与 auth.users 对应；插入时默认当前 JWT 用户';

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

-- 如需允许用户删除自己的笔记，可取消下面注释：
-- create policy "learning_notes_delete_own"
--   on public.learning_notes
--   for delete
--   to authenticated
--   using (auth.uid() = user_id);
