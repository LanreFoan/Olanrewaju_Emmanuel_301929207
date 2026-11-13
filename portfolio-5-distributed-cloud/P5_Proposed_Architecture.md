# Proposed Distributed/Cloud Database Architecture

## Design intent

The proposed architecture extends the **clinical document model** from Portfolio 4 while preserving a clear boundary with the **relational transaction model** from Portfolios 1–3.
It is designed for a future MetriCare that may need multi-branch access, greater tolerance for server failures, and controlled handling of clinical data.

For a compact visual representation, see [Architecture_Diagram.md](P5_Architecture_Diagram.md).

## Existing baseline versus future design

| Component | Current Component | Proposed component |
|---|---|---|
| Relational store | Local PostgreSQL 18 (`public` hospital tables) | Retain an appropriately managed relational service for appointment/billing transactions if required |
| NoSQL store | Local MongoDB Community Server, `metricare_nosql` | Managed MongoDB Atlas replica set for clinical consultation documents |
| Application layer | No full production clinical app deployed for this portfolio | Secure application/API mediating authorised access |
| Distributed nodes | None demonstrated | One primary, two secondaries across appropriate failure domains |
| Synchronisation | No real-time PostgreSQL–MongoDB synchronisation | Separately designed integration/service ownership, only if justified |
| Sharding | None | Possible future cluster design after workload analysis |

##  Proposed logical components

### A. Hospital users and application services

Physicians, laboratory scientists, pharmacists, front-desk staff, and billing officers should access records through authenticated application services rather than directly through unrestricted database accounts. The service enforces role permissions and clinical/business validation.

### B. Clinical document database

The proposed MongoDB collections mirror the Portfolio 4 educational design:

- **`patients`** — stable logical identifier (`patientId`), demographics and contact information subject to data-minimization rules.
- **`consultations`** — `consultationId`, `patientId` reference, doctor snapshot, date, and embedded `diagnoses`, `laboratoryRequests` and `prescriptions` arrays.

A consultation that includes a laboratory request can be retrieved as a document without joining multiple relational tables. Patient demographic records remain in a separate collection, so their shared values are not repeated across encounters.

### C. Replica-set members

| Member | Proposed role | Example responsibility |
|---|---|---|
| Node 1 | Primary | Accept consultation updates and normal critical reads |
| Node 2 | Secondary | Asynchronously replicate the primary's oplog; eligible for election |
| Node 3 | Secondary | Maintain another copy; eligible for election |

No particular cloud zone, physical region, server hardware, uptime or failover time was measured or selected. A real deployment would choose supported placements that meet resilience, latency, and data residency needs.

### D. PostgreSQL boundary

The existing relational schema includes `Patients`, `Appointments`, `Consultations`, `LabRequest`, `Invoice`, `Payment` and related entities. The architecture does **not** assume that MongoDB automatically replaces all of them. A future integrated design needs one authoritative source per workflow and a controlled synchronization plan for any shared identifiers or events.

##  Proposed data flows

**Clinical read:** authorised physician -> application/API -> proposed MongoDB primary -> consultation document containing diagnoses and lab requests.

**Laboratory result update:** authorized laboratory user -> application/API validation -> primary updates embedded lab request -> oplog asynchronously replicated to secondary members -> acknowledgment according to configured write concern.

**Billing operation:** authorized billing officer -> application/API -> relational billing store (separate from the MongoDB consultation transaction). A cross-store workflow must be designed explicitly; no single automatic transaction spans both in this academic model.

**Node failure:** primary unreachable -> election if an eligible majority is available -> client reconnect/retry -> new primary resumes writes following election. Application timeouts and partial failure must be managed.

##  Proposed non-functional controls

| Control | Reason | Verification needed before real use |
|---|---|---|
| Majority-acknowledged critical writes | Better resistance to rollback after certain failures | Test under representative conditions and document latency trade-off |
| Primary read preference for clinical decisions | Reduce exposure to lagging secondaries | Verify required recency guarantees and monitor behavior |
| TLS and least-privilege roles | Protect patient information | Security tests, role audits and credential rotation |
| Private or limited network access | Reduce attack surface | Confirm network policy and logging |
| Backups independent of replication | Recover from accidental deletion/corruption | Demonstrate successful restore and defined retention policy |
| Monitoring | Detect replica lag, errors and resource pressure | Alerts, incident handling and runbooks |
| Disaster-recovery plan | Define response to infrastructure failures | Measure RPO/RTO in exercises |

##  Replication versus sharding decision

**Why replication first?** The immediate design concern is loss of a single local server, not proven inability of one well-sized system to hold the small clinical data. A replica set improves redundancy without partitioning the patient collection into independent subsets.

**When sharding may be revisited:** multiple branches, sustained high write volume, very large encounter history, and measured scaling bottlenecks. Candidate shard keys (such as a hashed `patientId`) must be validated against real workloads; no choice is final in this proposal.

##  Limitations and assumptions

- A real clinical production environment, staffing model, and workload have *not* been measured.
- MongoDB Atlas is illustrative, not installed or connected for Portfolio 5.
- No cloud infrastructure, credentials, topology checks, replication tests, failover drills, sharding operations or measured RPO/RTO are available.
- The earlier MongoDB records are fictional educational data; no real patient data is present in this submission.
- Governance requirements for healthcare and personal data must be assessed by appropriate stakeholders before any actual hosting decision.

##  Recommendation

Adopt **a phased, requirements-led evaluation**: plan a secured managed replica set and tested recovery process for clinical documents if the hospital expands; retain appropriate relational transactional controls; define responsibilities across databases; and revisit sharding only with empirical evidence. The diagram is a **design illustration**, not a record of implementation.
