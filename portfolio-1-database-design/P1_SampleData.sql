-- Sample Data for MetriCare Specialist Hospital: fictional dataset
BEGIN;

-- Departments
INSERT INTO public."Departments" ("DepartmentName") VALUES
    ('General Medicine'),
    ('Paediatrics'),
    ('Laboratory Services');

-- Patients
INSERT INTO public."Patients" ("FullName", "DateOfBirth", "Phone") VALUES
    ('Adaeze Okafor', DATE '1992-04-18', '08030001001'),
    ('Tunde Bello', DATE '1985-09-07', '08030001002'),
    ('Mariam Yusuf', DATE '2001-01-25', NULL);

-- Staff
INSERT INTO public."Staff" ("FullName", "Role", "DepartmentID") VALUES
    ('Dr Chika Nwosu', 'Doctor',
        (SELECT "DepartmentID" FROM public."Departments"
         WHERE "DepartmentName" = 'General Medicine')),
    ('Dr Femi Adeyemi', 'Doctor',
        (SELECT "DepartmentID" FROM public."Departments"
         WHERE "DepartmentName" = 'Paediatrics')),
    ('Bisi Lawal', 'Receptionist', NULL),
    ('Kunle James', 'Laboratory Personnel',
        (SELECT "DepartmentID" FROM public."Departments"
         WHERE "DepartmentName" = 'Laboratory Services')),
    ('Ngozi Eze', 'Pharmacist', NULL),
    ('Sola Danjuma', 'Cashier', NULL),
    ('Ibrahim Musa', 'Administrator', NULL);

-- Appointments: scheduled, cancelled and completed examples.
-- The cancelled appointment shares a time with a scheduled appointment.
INSERT INTO public."Appointments"
    ("PatientID", "DoctorID", "AppointmentDateTime", "Status")
VALUES
    (
        (SELECT "PatientID" FROM public."Patients" WHERE "FullName" = 'Adaeze Okafor'),
        (SELECT "StaffID" FROM public."Staff" WHERE "FullName" = 'Dr Chika Nwosu'),
        TIMESTAMP '2026-11-10 09:00:00',
        'Scheduled'
    ),
    (
        (SELECT "PatientID" FROM public."Patients" WHERE "FullName" = 'Tunde Bello'),
        (SELECT "StaffID" FROM public."Staff" WHERE "FullName" = 'Dr Chika Nwosu'),
        TIMESTAMP '2026-11-10 09:00:00',
        'Cancelled'
    ),
    (
        (SELECT "PatientID" FROM public."Patients" WHERE "FullName" = 'Tunde Bello'),
        (SELECT "StaffID" FROM public."Staff" WHERE "FullName" = 'Dr Chika Nwosu'),
        TIMESTAMP '2026-11-10 10:00:00',
        'Completed'
    ),
    (
        (SELECT "PatientID" FROM public."Patients" WHERE "FullName" = 'Mariam Yusuf'),
        (SELECT "StaffID" FROM public."Staff" WHERE "FullName" = 'Dr Femi Adeyemi'),
        TIMESTAMP '2026-11-11 11:00:00',
        'Completed'
    );

-- One consultation per completed appointment.
INSERT INTO public."Consultations" ("AppointmentID", "Notes")
VALUES
    (
        (SELECT a."AppointmentID"
         FROM public."Appointments" a
         JOIN public."Patients" p ON p."PatientID" = a."PatientID"
         WHERE p."FullName" = 'Tunde Bello'
           AND a."AppointmentDateTime" = TIMESTAMP '2026-11-10 10:00:00'),
        'Patient reports recurring headaches.'
    ),
    (
        (SELECT a."AppointmentID"
         FROM public."Appointments" a
         JOIN public."Patients" p ON p."PatientID" = a."PatientID"
         WHERE p."FullName" = 'Mariam Yusuf'
           AND a."AppointmentDateTime" = TIMESTAMP '2026-11-11 11:00:00'),
        'Routine review; patient is stable.'
    );

-- Diagnoses
INSERT INTO public."Diagnosis" ("ConsultationID", "DiagnosisName")
VALUES
    (
        (SELECT c."ConsultationID"
         FROM public."Consultations" c
         JOIN public."Appointments" a ON a."AppointmentID" = c."AppointmentID"
         JOIN public."Patients" p ON p."PatientID" = a."PatientID"
         WHERE p."FullName" = 'Tunde Bello'),
        'Tension-type headache'
    ),
    (
        (SELECT c."ConsultationID"
         FROM public."Consultations" c
         JOIN public."Appointments" a ON a."AppointmentID" = c."AppointmentID"
         JOIN public."Patients" p ON p."PatientID" = a."PatientID"
         WHERE p."FullName" = 'Mariam Yusuf'),
        'Seasonal allergic rhinitis'
    ),
    (
        (SELECT c."ConsultationID"
         FROM public."Consultations" c
         JOIN public."Appointments" a ON a."AppointmentID" = c."AppointmentID"
         JOIN public."Patients" p ON p."PatientID" = a."PatientID"
         WHERE p."FullName" = 'Mariam Yusuf'),
        'Mild nasal inflammation'
    );

-- Laboratory requests: all three permitted status values.
INSERT INTO public."LabRequest"
    ("PatientID", "DoctorID", "ConsultationID", "TestType", "Status", "Result")
VALUES
    (
        (SELECT "PatientID" FROM public."Patients" WHERE "FullName" = 'Tunde Bello'),
        (SELECT "StaffID" FROM public."Staff" WHERE "FullName" = 'Dr Chika Nwosu'),
        (SELECT c."ConsultationID"
         FROM public."Consultations" c
         JOIN public."Appointments" a ON a."AppointmentID" = c."AppointmentID"
         JOIN public."Patients" p ON p."PatientID" = a."PatientID"
         WHERE p."FullName" = 'Tunde Bello'),
        'Full Blood Count', 'Pending', NULL
    ),
    (
        (SELECT "PatientID" FROM public."Patients" WHERE "FullName" = 'Mariam Yusuf'),
        (SELECT "StaffID" FROM public."Staff" WHERE "FullName" = 'Dr Femi Adeyemi'),
        (SELECT c."ConsultationID"
         FROM public."Consultations" c
         JOIN public."Appointments" a ON a."AppointmentID" = c."AppointmentID"
         JOIN public."Patients" p ON p."PatientID" = a."PatientID"
         WHERE p."FullName" = 'Mariam Yusuf'),
        'Allergy Panel', 'In Progress', NULL
    ),
    (
        (SELECT "PatientID" FROM public."Patients" WHERE "FullName" = 'Tunde Bello'),
        (SELECT "StaffID" FROM public."Staff" WHERE "FullName" = 'Dr Chika Nwosu'),
        (SELECT c."ConsultationID"
         FROM public."Consultations" c
         JOIN public."Appointments" a ON a."AppointmentID" = c."AppointmentID"
         JOIN public."Patients" p ON p."PatientID" = a."PatientID"
         WHERE p."FullName" = 'Tunde Bello'),
        'Blood Glucose', 'Completed', 'Fasting glucose: 5.1 mmol/L'
    );

-- Prescriptions
INSERT INTO public."Prescriptions"
    ("PatientID", "DoctorID", "ConsultationID", "PrescriptionDate")
VALUES
    (
        (SELECT "PatientID" FROM public."Patients" WHERE "FullName" = 'Tunde Bello'),
        (SELECT "StaffID" FROM public."Staff" WHERE "FullName" = 'Dr Chika Nwosu'),
        (SELECT c."ConsultationID"
         FROM public."Consultations" c
         JOIN public."Appointments" a ON a."AppointmentID" = c."AppointmentID"
         JOIN public."Patients" p ON p."PatientID" = a."PatientID"
         WHERE p."FullName" = 'Tunde Bello'),
        DATE '2026-11-10'
    ),
    (
        (SELECT "PatientID" FROM public."Patients" WHERE "FullName" = 'Mariam Yusuf'),
        (SELECT "StaffID" FROM public."Staff" WHERE "FullName" = 'Dr Femi Adeyemi'),
        (SELECT c."ConsultationID"
         FROM public."Consultations" c
         JOIN public."Appointments" a ON a."AppointmentID" = c."AppointmentID"
         JOIN public."Patients" p ON p."PatientID" = a."PatientID"
         WHERE p."FullName" = 'Mariam Yusuf'),
        DATE '2026-11-11'
    );

-- Prescription medication lines
INSERT INTO public."PrescriptionMedication"
    ("PrescriptionID", "MedicationName", "Dosage", "Frequency")
VALUES
    (
        (SELECT pr."PrescriptionID"
         FROM public."Prescriptions" pr
         JOIN public."Patients" p ON p."PatientID" = pr."PatientID"
         WHERE p."FullName" = 'Tunde Bello'),
        'Paracetamol', '500 mg', 'Twice daily'
    ),
    (
        (SELECT pr."PrescriptionID"
         FROM public."Prescriptions" pr
         JOIN public."Patients" p ON p."PatientID" = pr."PatientID"
         WHERE p."FullName" = 'Tunde Bello'),
        'Ibuprofen', '200 mg', 'Once daily after food'
    ),
    (
        (SELECT pr."PrescriptionID"
         FROM public."Prescriptions" pr
         JOIN public."Patients" p ON p."PatientID" = pr."PatientID"
         WHERE p."FullName" = 'Mariam Yusuf'),
        'Cetirizine', '10 mg', 'Once daily'
    );

-- Invoices: one fully paid, one partly paid and one unpaid.
INSERT INTO public."Invoice" ("PatientID", "InvoiceAmount")
VALUES
    (
        (SELECT "PatientID" FROM public."Patients" WHERE "FullName" = 'Tunde Bello'),
        25000.00
    ),
    (
        (SELECT "PatientID" FROM public."Patients" WHERE "FullName" = 'Mariam Yusuf'),
        18000.00
    ),
    (
        (SELECT "PatientID" FROM public."Patients" WHERE "FullName" = 'Adaeze Okafor'),
        12000.00
    );

-- Payments: totals remain within each invoice amount.
INSERT INTO public."Payment" ("InvoiceID", "Amount", "PaymentDate")
VALUES
    (
        (SELECT i."InvoiceID"
         FROM public."Invoice" i
         JOIN public."Patients" p ON p."PatientID" = i."PatientID"
         WHERE p."FullName" = 'Tunde Bello'),
        25000.00, DATE '2026-11-10'
    ),
    (
        (SELECT i."InvoiceID"
         FROM public."Invoice" i
         JOIN public."Patients" p ON p."PatientID" = i."PatientID"
         WHERE p."FullName" = 'Mariam Yusuf'),
        8000.00, DATE '2026-11-11'
    ),
    (
        (SELECT i."InvoiceID"
         FROM public."Invoice" i
         JOIN public."Patients" p ON p."PatientID" = i."PatientID"
         WHERE p."FullName" = 'Mariam Yusuf'),
        5000.00, DATE '2026-11-12'
    );

COMMIT;
