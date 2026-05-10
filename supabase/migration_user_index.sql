-- 已有 learning_notes 表时可选执行：按用户 + 时间查询时更易扩展（RLS 已保证每人只看自己的行）

create index if not exists learning_notes_user_id_created_at_idx
  on public.learning_notes (user_id, created_at desc);
