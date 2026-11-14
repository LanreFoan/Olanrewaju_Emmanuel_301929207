# Portfolio 5: Distributed and Cloud Database Exercise

**Current MetriCare Specialist Hospital Database Setup:**

- **Portfolio 1:** PostgreSQL 18 relational design for 11 hospital tables, including patient registration, appointments, consultations, diagnoses, laboratory requests, prescriptions, invoices and payments.
- **Portfolio 2:** A separate PostgreSQL query-optimization benchmark.
- **Portfolio 3:** A separate PostgreSQL schema used to demonstrate transactions, isolation and row-level locking.
- **Portfolio 4:** An actual **local MongoDB** document-model exercise (`metricare_nosql`) with `patients` and `consultations` collections, including fictional embedded diagnoses, laboratory requests and prescriptions.

**This Portfolio 5 evaluates how a future distributed system could be designed for MetriCare**

## Portfolio content

| File | Contents |
|---|---|
| [Distributed Cloud Database Discussion](Emmanuel_Olanrewaju_301929207_P5_Distributed_Cloud_Database.md) | Case-study discussion of replication, sharding, availability, consistency, security, benefits and limitations |
| [Proposed Architecture](Emmanuel_Olanrewaju_301929207_P5_Proposed_Architecture.md) | Proposed components, data flow, design decisions, risk controls, and phased rollout |
| [Architecture Diagram](Emmanuel_Olanrewaju_301929207_P5_Architecture_Diagram.md) | **Editable Mermaid diagrams** of the proposed deployment and a potential future sharded design |


##  Proposed approach 

**Preferred initial future architecture:** a managed MongoDB replica set for the consultation-document workload, alongside MetriCare's existing PostgreSQL-based transactional model where appropriate.

- **MongoDB clinical documents:** `patients` and `consultations`, with consultation-embedded diagnoses, laboratory requests and prescription snapshots.
- **Replica set:** one **primary** and two **secondaries** (a proposed three-data-bearing-node configuration), connected by asynchronous oplog replication.
- **Primary read/write pathway:** authorized application services access the primary for latency-sensitive clinical reads and writes.
- **Consistency controls:** consider `w: "majority"` and appropriate read concern/read preference for critical workflows; verify their trade-offs before production use.
- **Failure handling:** election of a new primary can restore write access, but there is an interruption during failover.
- **Sharding:** a **future option only**, justified by measured dataset scale and query patterns, not by the tiny fictional Portfolio 4 dataset.
- **Security and recovery:** TLS, least-privilege access, network restrictions, encryption, independent backups, restore drills and appropriate data-protection review.


## Findings and  design choice

The proposed first step for a growing MetriCare would be **replication and sound backup/security controls**, not immediate sharding. Replication is a response to single-node failure; sharding is a response to partitionable scale and workload pressures. Neither eliminates the need for strong access control, independent recovery, application reliability, and governance.

See the [technical discussion](Emmanuel_Olanrewaju_301929207_P5_Distributed_Cloud_Database.md) for details and the [architecture diagram](Emmanuel_Olanrewaju_301929207_P5_Architecture_Diagram.md) for the conceptual topology.


