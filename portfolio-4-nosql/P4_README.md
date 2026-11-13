# Portfolio 4 NoSQL and Advanced Data Models

## Document model
`patients` stores unique patient identifiers and demographic information. `consultations` references a patient using `patientId` and embeds a doctor snapshot, diagnosis array, laboratory request array, and prescription array. See [P4_NoSQL_Data_Model.md](P4_NoSQL_Data_Model.md) for the structure, modeling decisions, benefits, and limitations.

## Files and execution
| File | Purpose |
|---|---|
| [P4_Create_Database.js](P4_Create_Database.js) | Create both collections if absent, add unique logical-ID indexes, show collection names and counts |
| [P4_Insert_Documents.js](P4_Insert_Documents.js) | Insert the three fictional patients and encounters if not already present |
| [P4_CRUD_Operations.js](P4_CRUD_Operations.js) | Queries on patient and nested diagnosis; update lab 501; search pending labs; create and delete patient 999 |
| [P4_Aggregation_Queries.js](P4_Aggregation_Queries.js) | Count consultations per diagnosis and report sample counts |
| [Sample_Consultation.json](P4_Sample_Consultation.json) | Portable JSON illustration of a consultation (date as ISO string) |
| [NoSQL_Data_Model.md](P4_NoSQL_Data_Model.md) | Model and comparison with relational design |
| [screenshots](screenshots) | Screenshots to demonstrate claims |

### Set-Up
MongoDB Community Server running locally, MongoDB Compass, and `mongosh`. In a terminal, verify connectivity with:

```javascript
db.runCommand({ping:1})
```

## Queries demonstrated
- **CREATE:** `updateOne(..., {$setOnInsert:...}, {upsert:true})` for sample records; create temporary record 999.
- **READ:** `find()` by patient, nested diagnosis, and pending lab status.
- **UPDATE:** `updateOne()` using the positional `$` operator on an embedded lab request.
- **DELETE:** `deleteOne()` scoped to temporary test patient 999.
- **AGGREGATION:** `$unwind`, `$group`, `$sort` to count diagnoses.

## Actual observations and evidence
The supplied screenshots show initial database creation, three consultation records, a successful update of the embedded laboratory request (`matchedCount:1`, `modifiedCount:1`), a pending lab retrieval, a diagnosis aggregation yielding one record per diagnosis, and a successful deletion of a temporary patient (`deletedCount:1`, count 0).
