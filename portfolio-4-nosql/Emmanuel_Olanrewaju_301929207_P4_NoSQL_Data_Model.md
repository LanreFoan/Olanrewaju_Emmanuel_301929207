# NoSQL document design for MetriCare Specialist Hospital (fictional)

## Use Case
MetriCare is a simulated outpatient specialist hospital. Portfolio 1 modeled its operations in PostgreSQL, spanning patients, staff, appointments, consultations, diagnoses, prescriptions, lab requests, invoices, and payments. Portfolio 4 models a subset of the same clinical workflow using MongoDB documents; **it is not a migration or live link to the PostgreSQL database**.

## Collections
- `patients`: one document per fictional patient, with `patientId`, name, birth date, optional contact data, and demographic example fields. `patientId` is a unique logical identifier.
- `consultations`: one document per consultation, with `consultationId`, `patientId`, nested `doctor`, `diagnoses[]`, `laboratoryRequests[]`, and `prescriptions[]`. `consultationId` is unique.

## Embedding and referencing decisions
Consultations **reference** patients through `patientId`. Keeping patients separate prevents the repetition of demographic data across visits. Diagnoses, prescription items, and laboratory orders are **embedded** as arrays within one consultation because they are ordinarily retrieved together for a single encounter. Doctor fields are a limited snapshot; production implementations may maintain a staff collection with identifiers and policies for updating doctor data.

MongoDB assigns each record an `_id`, distinct from the Portfolio 1-style logical `patientId` and `consultationId`. Unique indexes guard the logical identifiers within each collection, but MongoDB does not automatically enforce a relational foreign key from `consultations.patientId` to `patients.patientId`. The example scripts deliberately insert matching identifiers.

## Suitability and limitations
A document model can return a whole encounter with a single find operation, handle optional laboratory results and empty prescription arrays, and allow queries of nested content using dot notation. An aggregation pipeline summarises diagnoses.

Trade-offs include duplicate clinician snapshot fields, the potential for nested arrays, the absence of automatic cross-collection foreign keys, and application-level handling of clinical audit, access control, validation, and data consistency. A real hospital would require strict privacy safeguards and secure access controls; no real patient data is used here. The medication and diagnosis examples are fictional, not clinical advice.

