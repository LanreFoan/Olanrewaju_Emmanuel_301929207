-- INDEXING / OPTIMISATION
-- The partial unique index on Appointments from Portfolio 1 remains in place.
-- These additional indexes support common filtering and join operations.

CREATE INDEX IF NOT EXISTS idx_appointments_patient_datetime
    ON public."Appointments" ("PatientID", "AppointmentDateTime");

CREATE INDEX IF NOT EXISTS idx_labrequest_status_patient
    ON public."LabRequest" ("Status", "PatientID");

CREATE INDEX IF NOT EXISTS idx_diagnosis_consultation
    ON public."Diagnosis" ("ConsultationID");

CREATE INDEX IF NOT EXISTS idx_prescriptions_patient_date
    ON public."Prescriptions" ("PatientID", "PrescriptionDate");

CREATE INDEX IF NOT EXISTS idx_payment_invoice
    ON public."Payment" ("InvoiceID");

CREATE INDEX IF NOT EXISTS idx_prescriptionmedication_prescription
    ON public."PrescriptionMedication" ("PrescriptionID");

ANALYZE public."Appointments";
ANALYZE public."LabRequest";
ANALYZE public."Diagnosis";
ANALYZE public."Prescriptions";
ANALYZE public."Payment";
ANALYZE public."PrescriptionMedication";

-- Evidence of indexes
SELECT schemaname, tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN ('Appointments', 'LabRequest', 'Diagnosis',
                    'Prescriptions', 'Payment', 'PrescriptionMedication')
ORDER BY tablename, indexname;

-- POST-INDEX EXECUTION PLANS

-- Plan for Query 1 after indexing
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT a."AppointmentID", p."FullName", s."FullName",
       a."AppointmentDateTime", a."Status"
FROM public."Appointments" a
JOIN public."Patients" p ON p."PatientID" = a."PatientID"
JOIN public."Staff" s ON s."StaffID" = a."DoctorID"
WHERE a."AppointmentDateTime" >= TIMESTAMP '2026-11-10 00:00:00'
  AND a."AppointmentDateTime" < TIMESTAMP '2026-11-11 00:00:00'
ORDER BY a."AppointmentDateTime", a."AppointmentID";

-- Plan for Query 3 after indexing
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT lr."LabRequestID", p."FullName", lr."TestType", lr."Status", lr."Result"
FROM public."LabRequest" lr
JOIN public."Patients" p ON p."PatientID" = lr."PatientID"
WHERE lr."Status" IN ('Pending', 'In Progress')
ORDER BY lr."Status", p."FullName";

-- Plan for Query 4 after indexing
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT i."InvoiceID", p."FullName", i."InvoiceAmount",
       COALESCE(SUM(pay."Amount"), 0) AS "TotalPaid",
       i."InvoiceAmount" - COALESCE(SUM(pay."Amount"), 0) AS "OutstandingBalance"
FROM public."Invoice" i
JOIN public."Patients" p ON p."PatientID" = i."PatientID"
LEFT JOIN public."Payment" pay ON pay."InvoiceID" = i."InvoiceID"
GROUP BY i."InvoiceID", p."FullName", i."InvoiceAmount"
ORDER BY i."InvoiceID";