-- BASELINE EXECUTION PLANS

-- Plan for Query 1
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT a."AppointmentID", p."FullName", s."FullName",
       a."AppointmentDateTime", a."Status"
FROM public."Appointments" a
JOIN public."Patients" p ON p."PatientID" = a."PatientID"
JOIN public."Staff" s ON s."StaffID" = a."DoctorID"
WHERE a."AppointmentDateTime" >= TIMESTAMP '2026-11-10 00:00:00'
  AND a."AppointmentDateTime" < TIMESTAMP '2026-11-11 00:00:00'
ORDER BY a."AppointmentDateTime", a."AppointmentID";

-- Plan for Query 3
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT lr."LabRequestID", p."FullName", lr."TestType", lr."Status", lr."Result"
FROM public."LabRequest" lr
JOIN public."Patients" p ON p."PatientID" = lr."PatientID"
WHERE lr."Status" IN ('Pending', 'In Progress')
ORDER BY lr."Status", p."FullName";

-- Plan for Query 4
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT i."InvoiceID", p."FullName", i."InvoiceAmount",
       COALESCE(SUM(pay."Amount"), 0) AS "TotalPaid",
       i."InvoiceAmount" - COALESCE(SUM(pay."Amount"), 0) AS "OutstandingBalance"
FROM public."Invoice" i
JOIN public."Patients" p ON p."PatientID" = i."PatientID"
LEFT JOIN public."Payment" pay ON pay."InvoiceID" = i."InvoiceID"
GROUP BY i."InvoiceID", p."FullName", i."InvoiceAmount"
ORDER BY i."InvoiceID";
