-- 已有 learning_notes 表时：在 Supabase → SQL Editor 运行本文件一次即可加标签列
-- （若你是全新建表且已用带 tags 的 schema.sql，可跳过本文件）

alter table public.learning_notes
  add column if not exists tags text[] not null default '{}';

comment on column public.learning_notes.tags is '笔记标签，可多选；用 text[] 存一组字符串';

-- 加速「包含某标签」的查询（tags @> ARRAY['前端']）
create index if not exists learning_notes_tags_gin
  on public.learning_notes using gin (tags);
