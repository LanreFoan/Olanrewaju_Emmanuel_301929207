-- MetriCare Specialist Hospital: constraint tests
-- Each statement is expected to fail for the reason in its comment

-- REQUIRED FIELDS: expected error: NOT NULL violation on Patients.DateOfBirth.
INSERT INTO public."Patients" ("FullName")
VALUES ('Test Patient Missing Birth Date');

-- UNIQUE: expected error: duplicate Departments.DepartmentName.
INSERT INTO public."Departments" ("DepartmentName")
VALUES ('General Medicine');

-- REQUIRED FIELDS: expected error: NOT NULL violation on Staff.FullName.
INSERT INTO public."Staff" ("Role")
VALUES ('Receptionist');

-- REQUIRED FIELDS: expected error: NOT NULL violation on Staff.Role.
INSERT INTO public."Staff" ("FullName")
VALUES ('Test Staff Missing Role');

-- REQUIRED FIELDS: expected error: NOT NULL violation on Appointments.PatientID.
INSERT INTO public."Appointments"
    ("DoctorID", "AppointmentDateTime", "Status")
VALUES
    ((SELECT "StaffID" FROM public."Staff" WHERE "FullName" = 'Dr Chika Nwosu'),
     TIMESTAMP '2026-12-01 09:00:00', 'Scheduled');


-- REQUIRED FIELDS: expected error: NOT NULL violation on Consultations.AppointmentID.
INSERT INTO public."Consultations" ("Notes")
VALUES ('Test consultation without an appointment');


-- REQUIRED FIELDS: expected error: NOT NULL violation on Diagnosis.DiagnosisName.
INSERT INTO public."Diagnosis" ("ConsultationID")
VALUES (
    (SELECT c."ConsultationID"
     FROM public."Consultations" c
     JOIN public."Appointments" a ON a."AppointmentID" = c."AppointmentID"
     JOIN public."Patients" p ON p."PatientID" = a."PatientID"
     WHERE p."FullName" = 'Tunde Bello')
);


-- REQUIRED FIELDS: expected error: NOT NULL violation on LabRequest.Status.
INSERT INTO public."LabRequest" ("PatientID", "DoctorID", "TestType")
VALUES (
    (SELECT "PatientID" FROM public."Patients" WHERE "FullName" = 'Adaeze Okafor'),
    (SELECT "StaffID" FROM public."Staff" WHERE "FullName" = 'Dr Chika Nwosu'),
    'Test panel'
);



-- FOREIGN KEY: expected error: prescription_consultation_fk cannot find this consultation.
INSERT INTO public."Prescriptions"
    ("PatientID", "DoctorID", "ConsultationID", "PrescriptionDate")
VALUES (
    (SELECT "PatientID" FROM public."Patients" WHERE "FullName" = 'Adaeze Okafor'),
    (SELECT "StaffID" FROM public."Staff" WHERE "FullName" = 'Dr Chika Nwosu'),
    -1,
    DATE '2026-12-01'
);


-- REQUIRED FIELDS: expected error: NOT NULL violation on PrescriptionMedication.MedicationName.
INSERT INTO public."PrescriptionMedication" ("PrescriptionID", "Dosage", "Frequency")
VALUES (
    (SELECT pr."PrescriptionID"
     FROM public."Prescriptions" pr
     JOIN public."Patients" p ON p."PatientID" = pr."PatientID"
     WHERE p."FullName" = 'Tunde Bello'),
    '10 mg', 'Once daily'
);


-- CHECK: expected error: invoice_amount_positive_check rejects zero.
INSERT INTO public."Invoice" ("PatientID", "InvoiceAmount")
VALUES (
    (SELECT "PatientID" FROM public."Patients" WHERE "FullName" = 'Adaeze Okafor'),
    0.00
);

-- CHECK: expected error: payment_amount_positive_check rejects zero.
INSERT INTO public."Payment" ("InvoiceID", "Amount", "PaymentDate")
VALUES (
    (SELECT i."InvoiceID"
     FROM public."Invoice" i
     JOIN public."Patients" p ON p."PatientID" = i."PatientID"
     WHERE p."FullName" = 'Tunde Bello'),
    0.00, DATE '2026-12-01'
);


