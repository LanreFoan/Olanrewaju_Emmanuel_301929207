-- Expected from historical evidence: 100000 synthetic rows; 55 date matches.
SELECT COUNT(*) AS total_synthetic_rows
FROM p2_benchmark.appointment_history_synthetic;

SELECT COUNT(*) AS matching_appointments
FROM p2_benchmark.appointment_history_synthetic
WHERE appointment_datetime >= TIMESTAMP '2026-11-10 00:00:00'
  AND appointment_datetime <  TIMESTAMP '2026-11-11 00:00:00';

SELECT synthetic_history_id, patient_id, doctor_id,
       appointment_datetime, appointment_status
FROM p2_benchmark.appointment_history_synthetic
WHERE appointment_datetime >= TIMESTAMP '2026-11-10 00:00:00'
  AND appointment_datetime <  TIMESTAMP '2026-11-11 00:00:00'
ORDER BY appointment_datetime, synthetic_history_id;
