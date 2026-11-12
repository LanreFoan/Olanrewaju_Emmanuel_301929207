-- Safe read-only post-index plan. Run once as warm-up then 3 times
-- for measurements if repeating the experiment. Record Execution Time
EXPLAIN (ANALYZE, BUFFERS)
SELECT synthetic_history_id, patient_id, doctor_id,
       appointment_datetime, appointment_status
FROM p2_benchmark.appointment_history_synthetic
WHERE appointment_datetime >= TIMESTAMP '2026-11-10 00:00:00'
  AND appointment_datetime < TIMESTAMP '2026-11-11 00:00:00';
