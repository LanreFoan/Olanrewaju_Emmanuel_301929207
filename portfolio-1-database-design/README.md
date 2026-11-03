# Case Study Statement - MetriCare Specialist Hospital (simulated)

**Organisation/scenario:** MetriCare Specialist, a simulated private multi-department outpatient clinic.

**Nature of the system:** A Specialist Hospital Management System that handles patient registration, specialist consultations, appointment scheduling, diagnoses, laboratory investigations, prescriptions and billing. The database connects patients, hospital staff, appointments, consultations, lab requests, prescriptions, invoices and payments to help support coordinated outpatient specialist services.

**Users of the database:**

| User | Operations |
|---|---|
| Front-desk staff | Enrol patients, maintain patient data, and make or cancel appointments |
| Billing officers | Create invoice for payment, document payment, and manage outstanding payment balances |
| Physicians | Consult with patients, document the diagnosis, order lab investigations, and prescribe medicines |
| Pharmacists | Review medicines prescribed, and document dispensing of medicines |
| Lab scientist | Record lab investigation orders, store test results, and update lab investigation order statuses |
| Admins | Maintain staff data, assign user roles, and manage hospital operations |

**Major data stored:** patients, doctors and departments, appointments, consultations, diagnoses, medications and stock, prescriptions, lab tests/orders/results, invoices and payments.

**Key operations supported:**
1. Book an appointment without duplicating booking a doctor
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
The database deals with registration of patients, personnel and departments information, appointment, consultations, diagnosis, laboratory tests, prescriptions, medications, invoices, and payments. One appointment consists of the relationship between one patient and one doctor and can lead to the consultation at all with only one outcome. Consultation can involve several diagnoses, prescriptions, and laboratory tests. Laboratory test is related to only one type of test and includes only one recorded test result. Prescriptions can include several medications, and invoices can have several payments, but cannot exceed the total invoice amount. There are used unique keys and fictitious data. Management of inpatients, surgery, insurance claim processing, payroll, complete pharmacy database, and integration with other systems are not included.

## Implementation files

| File | Contents |
| --- | --- |
| [Design](portfolio_1_Design.md) | Entities, attributes, keys, relationships and business rules |
| [ER diagram](portfolio_1_ERDiagram.md) | Mermaid ER diagram + cardinality decisions |
| [Normalisation](portfolio_1_Normalisation.md) | Example tables showing 1NF, 2NF and 3NF reasoning and trade-offs |
| [Schema](portfolio_1_Schema.sql) | PostgreSQL table definitions, complete DDL with keys and constraints |
| [Sample Data](portfolio_1_SampleData.sql) | Fictional members, a book, physical copies and loans |
| [Constraint tests](portfolio_1_ConstraintTests.sql) | Deliberate invalid inserts, proving the constraints work |
| [Evidence](/screenshots) | Links to the screenshots stored in screenshots/. |


