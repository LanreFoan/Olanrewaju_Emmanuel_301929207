-- 1. Daily appointment schedule
SELECT a."AppointmentID", p."FullName" AS "PatientName",
       s."FullName" AS "DoctorName", a."AppointmentDateTime", a."Status"
FROM public."Appointments" a
JOIN public."Patients" p ON p."PatientID" = a."PatientID"
JOIN public."Staff" s ON s."StaffID" = a."DoctorID"
WHERE a."AppointmentDateTime" >= TIMESTAMP '2026-11-10 00:00:00'
  AND a."AppointmentDateTime" < TIMESTAMP '2026-11-11 00:00:00'
ORDER BY a."AppointmentDateTime", a."AppointmentID";

-- 2. Patient clinical history (change the patient name as required)
SELECT p."PatientID", p."FullName", a."AppointmentDateTime",
       a."Status" AS "AppointmentStatus", c."ConsultationID",
       c."Notes", d."DiagnosisName"
FROM public."Patients" p
JOIN public."Appointments" a ON a."PatientID" = p."PatientID"
LEFT JOIN public."Consultations" c ON c."AppointmentID" = a."AppointmentID"
LEFT JOIN public."Diagnosis" d ON d."ConsultationID" = c."ConsultationID"
WHERE p."FullName" = 'Mariam Yusuf'
ORDER BY a."AppointmentDateTime", d."DiagnosisName";

-- 3. Laboratory work queue
SELECT lr."LabRequestID", p."FullName" AS "PatientName",
       s."FullName" AS "RequestedByDoctor", lr."TestType",
       lr."Status", lr."Result"
FROM public."LabRequest" lr
JOIN public."Patients" p ON p."PatientID" = lr."PatientID"
JOIN public."Staff" s ON s."StaffID" = lr."DoctorID"
WHERE lr."Status" IN ('Pending', 'In Progress')
ORDER BY lr."Status", p."FullName";

-- 4. Invoice balances and payment status
SELECT i."InvoiceID", p."FullName" AS "PatientName", i."InvoiceAmount",
       COALESCE(SUM(pay."Amount"), 0) AS "TotalPaid",
       i."InvoiceAmount" - COALESCE(SUM(pay."Amount"), 0) AS "OutstandingBalance",
       CASE
         WHEN COALESCE(SUM(pay."Amount"), 0) = 0 THEN 'Unpaid'
         WHEN COALESCE(SUM(pay."Amount"), 0) < i."InvoiceAmount" THEN 'Partly Paid'
         ELSE 'Paid'
       END AS "PaymentStatus"
FROM public."Invoice" i
JOIN public."Patients" p ON p."PatientID" = i."PatientID"
LEFT JOIN public."Payment" pay ON pay."InvoiceID" = i."InvoiceID"
GROUP BY i."InvoiceID", p."FullName", i."InvoiceAmount"
ORDER BY i."InvoiceID";

-- 5. Prescribed medicines
SELECT p."FullName" AS "PatientName", pr."PrescriptionDate",
       pm."MedicationName", pm."Dosage", pm."Frequency"
FROM public."Prescriptions" pr
JOIN public."Patients" p ON p."PatientID" = pr."PatientID"
JOIN public."PrescriptionMedication" pm
  ON pm."PrescriptionID" = pr."PrescriptionID"
ORDER BY p."FullName", pr."PrescriptionDate", pm."MedicationName";

-- 6. Appointment totals by doctor and status
SELECT s."FullName" AS "DoctorName", a."Status",
       COUNT(*) AS "AppointmentCount"
FROM public."Appointments" a
JOIN public."Staff" s ON s."StaffID" = a."DoctorID"
GROUP BY s."StaffID", s."FullName", a."Status"
ORDER BY s."FullName", a."Status";