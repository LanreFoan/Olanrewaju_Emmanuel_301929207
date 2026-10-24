# MetriCare Specialist Hospital Management System Database Design

**Entities:**
- The database stores information about patients, hospital staff, departments, appointments, consultations, diagnoses, laboratory requests, prescriptions, prescribed medications, invoices, and payments.
- Eleven tables are proposed because we require separate records for clinical activities, multiple prescribed medications, and multiple payments. Laboratory results are stored within laboratory request records to keep the design smaller.

## Attributes and keys
| Entities | Attributes and PostgreSQL types |
| --- | --- |
| `Patients`| PatientID (PK, INTEGER), FullName (VARCHAR, required), DateOfBirth (DATE, required), Phone (VARCHAR, optional) |
| `Departments` | DepartmentID (PK, INTEGER), DepartmentName (VARCHAR, required, UNIQUE) |
| `Staff` | StaffID (PK, INTEGER), FullName (VARCHAR, required), Role (VARCHAR, required), DepartmentID (FK, INTEGER, optional for non-doctors) |
| `Appointments`| AppointmentID (PK, INTEGER), PatientID (FK), DoctorID (FK to Staff), AppointmentDateTime (TIMESTAMP, required), Status (VARCHAR, required) |
| `Consultations`| ConsultationID (PK, INTEGER), AppointmentID (FK, UNIQUE), Notes (TEXT, optional) |
| `Diagnosis`| DiagnosisID (PK, INTEGER), ConsultationID (FK), DiagnosisName (VARCHAR, required) |
| `LabRequest`| LabRequestID (PK, INTEGER), PatientID (FK), DoctorID (FK to Staff), ConsultationID (FK, optional), TestType (VARCHAR, required), Status (VARCHAR, required), Result (TEXT, optional) |
| `Prescriptions`| PrescriptionID (PK, INTEGER), PatientID (FK), DoctorID (FK to Staff), ConsultationID (FK, optional), PrescriptionDate (DATE, required) |
| `PrescriptionMedication`| PrescriptionMedicationID (PK, INTEGER), PrescriptionID (FK), MedicationName (VARCHAR, required), Dosage (VARCHAR, required), Frequency (VARCHAR, required) |
| `Invoice`| InvoiceID (PK, INTEGER), PatientID (FK), InvoiceAmount (NUMERIC(10,2), required) |
| `Payment`| PaymentID (PK, INTEGER), InvoiceID (FK), Amount (NUMERIC(10,2), required), PaymentDate (DATE, required)

** Primary key (PK) uniquely identifies a record. A foreign key (FK) connects a record to another table

## Relationships

| Relationship | Relationship rule |
|---|---|
| Patient–Appointment | One patient can have zero or many appointments; each appointment belongs to exactly one patient. |
| Department–Staff | One department can have zero or many staff members; each doctor belongs to exactly one department. |
| Staff–Appointment | One doctor can have zero or many appointments; each appointment has exactly one doctor. |
| Appointment–Consultation | An appointment can have zero or one consultation; each consultation belongs to exactly one appointment. |
| Consultation–Diagnosis | One consultation can have zero or many diagnoses; each diagnosis belongs to exactly one consultation. |
| Patient–LabRequest | One patient can have zero or many laboratory requests; each request belongs to exactly one patient. |
| Staff–LabRequest | One doctor can request zero or many laboratory investigations; each request has exactly one requesting doctor. |
| Patient–Prescription | Prescription | One patient can have zero or many prescriptions; each prescription belongs to exactly one patient. |
| Staff–Prescription | One doctor can issue zero or many prescriptions; each prescription has exactly one prescribing doctor. |
| Prescription–PrescriptionMedication | One prescription contains one or more medication records; each medication record belongs to exactly one prescription. |
| Patient–Invoice | One patient can have zero or many invoices; each invoice belongs to exactly one patient. |
| Invoice–Payment | One invoice can have zero or many payments; each payment belongs to exactly one invoice. |

**Additional relationship:** Each `LabRequest` concerns one test type and may have at most one recorded result. The result is stored in the `LabRequest` table, so a separate `LabResult` table is unnecessary for this simplified model.


## Rules and Constraints

1. **Unique patients:** `PatientID` is the primary key and uniquely identifies each patient. A patient can have multiple appointments, consultations, prescriptions, and invoices.

2. **Staff identification and roles:** `StaffID` is the primary key and uniquely identifies each staff member. A `CHECK` constraint restricts `Role` to Receptionist, Doctor, Laboratory Personnel, Pharmacist, Cashier, or Administrator.

3. **Appointments:** `AppointmentID` is the primary key, and `PatientID` and `DoctorID` are required foreign keys referencing the Patient and Staff tables. Each appointment must have a valid date and time, and both patients and doctors can have multiple appointments.

4. **No conflicting appointments:** A doctor cannot have two active appointments scheduled for the same date and time. A partial unique index enforces this rule while excluding cancelled appointments.

5. **Consultations:** `ConsultationID` is the primary key, and `AppointmentID` is a unique foreign key referencing the Appointment table. This ensures that each appointment has at most one consultation; the associated patient and doctor are identified through the linked appointment.

6. **Lab requests:** `LabRequestID` is the primary key, and `PatientID` and `DoctorID` are required foreign keys. A `CHECK` constraint restricts `Status` to Pending, In Progress, or Completed; the recorded result is optional.

7. **Prescriptions:** `PrescriptionID` is the primary key, with required `PatientID` and `DoctorID` foreign keys. Each prescription can contain multiple medication records, and each record must include a medication name, dosage, and frequency.

8. **Invoices and payments:** `InvoiceID` and `PaymentID` are primary keys, and `Payment.InvoiceID` is a foreign key referencing `Invoice.InvoiceID`. Invoice and payment amounts must be positive, and total payments must not exceed the invoice amount; a database trigger or controlled transaction enforces this rule because a simple `CHECK` constraint cannot safely validate totals across multiple payment records.

**Consultations inherit their patient and doctor through the linked appointment rather than storing duplicate foreign keys. This preserves the agreed relationship while reducing redundant data.
