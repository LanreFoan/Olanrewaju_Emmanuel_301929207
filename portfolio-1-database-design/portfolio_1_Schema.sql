-- MetriCare Specialist Hospital Management System
-- PostgreSQL 16 database schema
11 tables in the public schema.

BEGIN;

-- 1. Patients
CREATE TABLE public."Patients" (
    "PatientID" INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "FullName" VARCHAR NOT NULL,
    "DateOfBirth" DATE NOT NULL,
    "Phone" VARCHAR
);

-- 2. Departments
CREATE TABLE public."Departments" (
    "DepartmentID" INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "DepartmentName" VARCHAR NOT NULL UNIQUE
);

-- 3. Staff
CREATE TABLE public."Staff" (
    "StaffID" INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "FullName" VARCHAR NOT NULL,
    "Role" VARCHAR NOT NULL,
    "DepartmentID" INTEGER,
    CONSTRAINT staff_role_check
        CHECK ("Role" IN (
            'Receptionist', 'Doctor', 'Laboratory Personnel',
            'Pharmacist', 'Cashier', 'Administrator'
        )),
    CONSTRAINT staff_department_fk
        FOREIGN KEY ("DepartmentID")
        REFERENCES public."Departments" ("DepartmentID"),
    CONSTRAINT doctor_department_check
        CHECK ("Role" <> 'Doctor' OR "DepartmentID" IS NOT NULL)
);

-- 4. Appointments
CREATE TABLE public."Appointments" (
    "AppointmentID" INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "PatientID" INTEGER NOT NULL,
    "DoctorID" INTEGER NOT NULL,
    "AppointmentDateTime" TIMESTAMP NOT NULL,
    "Status" VARCHAR NOT NULL,
    CONSTRAINT appointment_patient_fk
        FOREIGN KEY ("PatientID")
        REFERENCES public."Patients" ("PatientID"),
    CONSTRAINT appointment_doctor_fk
        FOREIGN KEY ("DoctorID")
        REFERENCES public."Staff" ("StaffID")
);

-- A doctor cannot have two non-cancelled appointments at the same time.
CREATE UNIQUE INDEX appointments_doctor_datetime_unique
    ON public."Appointments" ("DoctorID", "AppointmentDateTime")
    WHERE "Status" <> 'Cancelled';

-- 5. Consultations
CREATE TABLE public."Consultations" (
    "ConsultationID" INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "AppointmentID" INTEGER NOT NULL UNIQUE,
    "Notes" TEXT,
    CONSTRAINT consultation_appointment_fk
        FOREIGN KEY ("AppointmentID")
        REFERENCES public."Appointments" ("AppointmentID")
);

-- 6. Diagnosis
CREATE TABLE public."Diagnosis" (
    "DiagnosisID" INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "ConsultationID" INTEGER NOT NULL,
    "DiagnosisName" VARCHAR NOT NULL,
    CONSTRAINT diagnosis_consultation_fk
        FOREIGN KEY ("ConsultationID")
        REFERENCES public."Consultations" ("ConsultationID")
);

-- 7. LabRequest (shown as LAB_REQUEST in the ER diagram)
CREATE TABLE public."LabRequest" (
    "LabRequestID" INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "PatientID" INTEGER NOT NULL,
    "DoctorID" INTEGER NOT NULL,
    "ConsultationID" INTEGER,
    "TestType" VARCHAR NOT NULL,
    "Status" VARCHAR NOT NULL,
    "Result" TEXT,
    CONSTRAINT lab_request_patient_fk
        FOREIGN KEY ("PatientID")
        REFERENCES public."Patients" ("PatientID"),
    CONSTRAINT lab_request_doctor_fk
        FOREIGN KEY ("DoctorID")
        REFERENCES public."Staff" ("StaffID"),
    CONSTRAINT lab_request_consultation_fk
        FOREIGN KEY ("ConsultationID")
        REFERENCES public."Consultations" ("ConsultationID"),
    CONSTRAINT lab_request_status_check
        CHECK ("Status" IN ('Pending', 'In Progress', 'Completed'))
);

-- 8. Prescriptions
CREATE TABLE public."Prescriptions" (
    "PrescriptionID" INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "PatientID" INTEGER NOT NULL,
    "DoctorID" INTEGER NOT NULL,
    "ConsultationID" INTEGER,
    "PrescriptionDate" DATE NOT NULL,
    CONSTRAINT prescription_patient_fk
        FOREIGN KEY ("PatientID")
        REFERENCES public."Patients" ("PatientID"),
    CONSTRAINT prescription_doctor_fk
        FOREIGN KEY ("DoctorID")
        REFERENCES public."Staff" ("StaffID"),
    CONSTRAINT prescription_consultation_fk
        FOREIGN KEY ("ConsultationID")
        REFERENCES public."Consultations" ("ConsultationID")
);

-- 9. PrescriptionMedication
CREATE TABLE public."PrescriptionMedication" (
    "PrescriptionMedicationID" INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "PrescriptionID" INTEGER NOT NULL,
    "MedicationName" VARCHAR NOT NULL,
    "Dosage" VARCHAR NOT NULL,
    "Frequency" VARCHAR NOT NULL,
    CONSTRAINT prescription_medication_fk
        FOREIGN KEY ("PrescriptionID")
        REFERENCES public."Prescriptions" ("PrescriptionID")
);

-- 10. Invoice
CREATE TABLE public."Invoice" (
    "InvoiceID" INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "PatientID" INTEGER NOT NULL,
    "InvoiceAmount" NUMERIC(10,2) NOT NULL,
    CONSTRAINT invoice_patient_fk
        FOREIGN KEY ("PatientID")
        REFERENCES public."Patients" ("PatientID"),
    CONSTRAINT invoice_amount_positive_check
        CHECK ("InvoiceAmount" > 0)
);

-- 11. Payment
CREATE TABLE public."Payment" (
    "PaymentID" INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "InvoiceID" INTEGER NOT NULL,
    "Amount" NUMERIC(10,2) NOT NULL,
    "PaymentDate" DATE NOT NULL,
    CONSTRAINT payment_invoice_fk
        FOREIGN KEY ("InvoiceID")
        REFERENCES public."Invoice" ("InvoiceID"),
    CONSTRAINT payment_amount_positive_check
        CHECK ("Amount" > 0)
);



COMMIT;




