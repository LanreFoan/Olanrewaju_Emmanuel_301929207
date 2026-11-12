## Performance Analysis

The selected optimisation task for Portfolio 2 was to improve the execution of a date-range query on the `p2_benchmark.appointment_history_synthetic` table, which contained 100,000 synthetic appointment-history records.

The benchmark query retrieved records for 10 November 2026:

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    synthetic_history_id,
    patient_id,
    doctor_id,
    appointment_datetime,
    appointment_status
FROM p2_benchmark.appointment_history_synthetic
WHERE appointment_datetime >= TIMESTAMP '2026-11-10 00:00:00'
  AND appointment_datetime < TIMESTAMP '2026-11-11 00:00:00';
