# NoSQL document design — MetriCare Specialist Hospital

## Purpose
MetriCare is a simulated outpatient specialist hospital. Portfolio 1 modelled its operations relationally in PostgreSQL across patients, staff, appointments, consultations, diagnoses, prescriptions, lab requests, invoices and payments. Portfolio 4 models a subset of the same clinical workflow using MongoDB documents; **it is not a migration or live link to the PostgreSQL database**.

## Collections
- `patients`: one document per fictional patient, with `patientId`, name, birth date, optional contact data and demographic example fields. `patientId` is a unique logical identifier.
- `consultations`: one document per consultation, with `consultationId`, `patientId`, nested `doctor`, `diagnoses[]`, `laboratoryRequests[]`, and `prescriptions[]`. `consultationId` is unique.

## Embedding and referencing decisions
Consultations **reference** patients through `patientId`. Keeping patients separate avoids repeating demographic data across visits. Diagnoses, prescription items and laboratory orders are **embedded** as arrays within one consultation because they are ordinarily retrieved together for a single encounter. Doctor fields are a limited snapshot; production implementations may maintain a staff collection with identifiers and policies for updating doctor data.

MongoDB assigns each record an `_id`, distinct from the Portfolio 1-style logical `patientId` and `consultationId`. Unique indexes guard the logical identifiers within each collection, but MongoDB does not automatically enforce a relational foreign key from `consultations.patientId` to `patients.patientId`. The example scripts insert matching identifiers deliberately.

## Suitability and limitations
A document model can return a whole encounter with one find operation, handles optional laboratory results and empty prescription arrays, and allows queries of nested content using dot notation. An aggregation pipeline summarises diagnoses.

Trade-offs include duplicated clinician snapshot fields, the potential growth of nested arrays, the absence of automatic cross-collection foreign keys, and application-level handling of clinical audit, access control, validation, and data consistency. A real hospital would require strict privacy safeguards and secure access controls; no real patient data is used here. The medication and diagnosis examples are fictional, not clinical advice.

