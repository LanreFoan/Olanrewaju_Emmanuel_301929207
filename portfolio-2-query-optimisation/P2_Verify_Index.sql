-- Safe, read-only index verification
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'p2_benchmark'
  AND tablename = 'appointment_history_synthetic'
ORDER BY indexname;

-- Returns index details, including the B-tree date index if still present.
SELECT i.relname AS index_name,
       pg_get_indexdef(i.oid) AS index_definition
FROM pg_class i
JOIN pg_index ix ON ix.indexrelid=i.oid
JOIN pg_class t ON t.oid=ix.indrelid
JOIN pg_namespace n ON n.oid=t.relnamespace
WHERE n.nspname='p2_benchmark'
  AND t.relname='appointment_history_synthetic'
ORDER BY index_name;
