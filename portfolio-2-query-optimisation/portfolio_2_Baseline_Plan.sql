-- PRE-INDEX QUERY ONLY
-- 99945 rows removed by filter, 1235 shared buffer hits.
EXPLAIN (ANALYZE, BUFFERS)
SELECT synthetic_history_id, patient_id, doctor_id,
       appointment_datetime, appointment_status
FROM p2_benchmark.appointment_history_synthetic
WHERE appointment_datetime >= TIMESTAMP '2026-11-10 00:00:00'
  AND appointment_datetime < TIMESTAMP '2026-11-11 00:00:00';
