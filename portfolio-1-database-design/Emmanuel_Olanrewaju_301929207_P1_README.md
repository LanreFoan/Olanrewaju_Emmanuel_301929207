# Case Study Statement - MetriCare Specialist Hospital (simulated)

**Organisation/scenario:** MetriCare Specialist, a simulated private multi-department outpatient clinic.

**Nature of the system:** A Specialist Hospital Management System that handles patient registration, specialist consultations, appointment scheduling, diagnoses, laboratory investigations, prescriptions and billing. The database connects patients, hospital staff, appointments, consultations, lab requests, prescriptions, invoices and payments to help support coordinated outpatient specialist services.

**Users of the database:**

| User | Operations |
|---|---|
| Front-desk staff | Enroll patients, maintain patient data, and make or cancel appointments |
| Billing officers | Create invoices for payment, document payment, and manage outstanding payment balances |
| Physicians | Consult with patients, document the diagnosis, order lab investigations, and prescribe medicines |
| Pharmacists | Review medicines prescribed, and document dispensing of medicines |
| Lab scientist | Record lab investigation orders, store test results, and update lab investigation order statuses |
| Admins | Maintain staff data, assign user roles, and manage hospital operations |

**Major data stored:** patients, doctors and departments, appointments, consultations, diagnoses, medications and stock, prescriptions, lab tests/orders/results, invoices and payments.

**Key operations supported:**
1. Book an appointment without duplicating a booking for a doctor
2. Retrieve a patient's full history
3. Record consultation, diagnosis, prescription, and lab orders/results
4. Dispense medication 
5. Invoice and record payments
6. Management reporting (workload, top diagnoses, outstanding balances)

## Design Approach
1. PatientIDs must be unique for each patient, and each patient can have many appointments, consultations, prescriptions, and invoices.
2. Staff members need to have unique StaffIDs and roles, like being receptionists, doctors, lab members, pharmacists, cashiers, or administrators.
3. Appointments must have unique AppointmentIDs, date and time values, referencing one patient and one specialist doctor, and both patients and doctors can have many appointments.
4. Consultations must have unique ConsultationIDs, referencing one patient, one appointment, and the doctor who gave the consultation; an appointment can have at most one consultation.
5. Laboratory requests must have unique LabRequestIDs, referencing one patient and one requesting doctor, and each request must have either the pending, in progress, or completed statuses.
6. Prescriptions must have unique PrescriptionIDs, referencing one patient and one prescribing doctor, and each prescription can include several prescribed medications and the names, dosages, and frequencies of those medications.
7. Invoices must have unique InvoiceIDs, referencing one patient, and each invoice can have many payments, but the total amount of recorded payments cannot be greater than the amount of the invoice.

## Scope 
The database handles the registration of patients, personnel, and departments; appointments, consultations, diagnoses, laboratory tests, prescriptions, medications, invoices, and payments. An appointment is the relationship between one patient and one doctor and can lead to a consultation, with only one outcome. A consultation can involve several diagnoses, prescriptions, and laboratory tests. A laboratory test is specific to one type of test and includes only one recorded result. Prescriptions can include several medications, and invoices can include several payments, but the total amount cannot exceed the invoice total. Unique keys and fictitious data are used. Management of inpatients, surgery, insurance claim processing, payroll, complete pharmacy database, and integration with other systems are not included.

## Implementation files

| File | Contents |
| --- | --- |
| [Design](P1_Design.md) | Entities, attributes, keys, relationships and business rules |
| [ER diagram](P1_ERDiagram.md) | Mermaid ER diagram + cardinality decisions |
| [Normalisation](P1_Normalisation.md) | Example tables showing 1NF, 2NF and 3NF reasoning and trade-offs |
| [Schema](P1_Schema.sql) | PostgreSQL table definitions, complete DDL with keys and constraints |
| [Sample Data](P1_SampleData.sql) | Fictional members, a book, physical copies and loans |
| [Constraint tests](P1_ConstraintTests.sql) | Deliberate invalid inserts, proving the constraints work |
| [Evidence](screenshots) | Links to the screenshots stored in screenshots/. |

## Implementation
The MetriCare Specialist Hospital database was implemented using PostgreSQL 18 and pgAdmin 4. It consists of 11 related tables covering patients, departments, staff, appointments, consultations, diagnoses, laboratory requests, prescriptions, prescription medications, invoices, and payments.

Primary keys, foreign keys, NOT NULL, UNIQUE, and CHECK constraints were implemented to maintain data integrity and enforce the database rules. Sample records were inserted successfully into the database.

## Test Results
The database constraints were tested using the SQL statements in portfolio_1_ConstraintTests.sql. All 12 invalid INSERT statements were rejected by PostgreSQL as expected.

The tests covered NOT NULL, UNIQUE, FOREIGN KEY, and CHECK constraints. For example, an attempt to insert a patient without a date of birth was rejected with SQLSTATE 23502, confirming that the NOT NULL constraint on Patients.DateOfBirth was working correctly.

The test results demonstrate that the implemented constraints prevent invalid records from being inserted and help maintain data integrity.
