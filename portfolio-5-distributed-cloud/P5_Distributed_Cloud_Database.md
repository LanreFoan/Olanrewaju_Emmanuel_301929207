# Distributed and Cloud Database Discussion

## Context
MetriCare Specialist Hospital is a **simulated private multi-department outpatient clinic** that supports patient registration, appointment booking, consultations, diagnosis recording, laboratory requests/results, prescriptions, invoices and payments. Users include front-desk personnel, physicians, laboratory scientists, pharmacists, billing staff and administrators.


## Distributed databases and cloud databases

A **distributed database** stores or manages information across more than one database node. Nodes may cooperate to replicate data for redundancy, partition data for scalability, or both. A **cloud database** is hosted and operated using cloud infrastructure, often with managed provisioning, monitoring and backup options. Cloud hosting alone does not prove the database is sharded or highly available; the topology and configuration matter.

For this case study, **MongoDB Atlas** is an illustrative managed service, **not a service actually configured**. The preferred first-phase proposal is a three-data-bearing-member MongoDB replica set. A future sharded-cluster option is evaluated separately; no sharding is presently required by MetriCare's small academic sample.

## Proposed replication strategy

###  Replica set topology

A three-member replica set would contain:

1. **One primary**, receiving writes and normally serving the application's critical reads.
2. **Two secondaries**, maintaining copies by applying operations from the primary's **oplog**.

MongoDB secondaries replicate **asynchronously**. Consequently, a secondary can briefly lag behind the primary and cannot automatically be treated as a source of the newest result. The proposed architecture uses a driver-aware application connection, rather than hardcoding a connection to a specific server. [1][2]

###  Hospital example

Suppose a laboratory scientist changes a fictional consultation's Full Blood Count status from `Pending` to `Completed`. The application writes the update to the primary. Secondary members then replicate the operation. A physician reading from a lagging secondary could, depending on the read configuration, temporarily see the previous status; for clinically important result retrieval, reading from the primary and choosing suitable consistency settings reduces that risk.

###  Advantages and limitations

Replication reduces the risk of losing a single database host. If the primary becomes unavailable and a majority of voting members remains reachable, an eligible secondary can be elected to primary. **Write service may pause during election**, and the outcome depends on quorum and operating conditions. Replication does **not** guarantee permanent zero downtime or zero data loss under every configuration.

**Important distinction:** replica copies do **not** replace backups. Deletions, accidental updates, and application mistakes can be copied to secondaries. MetriCare would still need an independently managed backup policy with periodic restore verification.

## Sharding as a possible future scaling mechanism

**Sharding** partitions documents across multiple shards. It differs from replication: each shard may hold a different subset of the overall collection, whereas replica-set members hold copies of a shared dataset. In many production sharded designs, each shard itself is a replica set. [5]

###  Growth scenario

A single outpatient clinic with three fictional patient documents has no demonstrated reason to shard. If MetriCare later served many branches, accumulated years of consultation data, and measured sustained load beyond the capacity of an appropriately sized replica set, horizontal partitioning could become useful.

A **hashed `patientId`** is one *candidate* shard key for consultation records, especially when applications frequently retrieve data by patient ID. However, the suitability of any shard key depends on actual cardinality, frequency, write distribution, query targeting, index requirements and cross-shard access patterns. Queries that omit the shard key may have to contact multiple shards, and date-range/reporting workloads may favor a different approach. No final shard key is selected in this submission. [5][6]

###  Trade-offs

Sharding can increase storage and throughput capacity but also introduces routing, resharding, balancing, distributed-query and operational complexity. It should follow workload profiling, cost analysis and controlled testing—not be adopted merely because the platform offers it.

## High availability, failure tolerance and recovery

High availability is an architectural goal rather than a guaranteed outcome. For MetriCare, the failure of a single database machine should not necessarily render every clinical record inaccessible. Replication across appropriately separated failure domains is a reasonable proposed control.

**Illustrative failure sequence:**

1. Primary node becomes unreachable.
2. Remaining voting members determine whether a majority is available.
3. An eligible secondary may be elected as the new primary.
4. Applications with suitable drivers and retry/error-handling logic reconnect and resume operations after any failover interruption.

If a majority is unavailable, a replica set cannot elect a primary to accept normal writes. A network partition, slow election, or client connectivity problem can still interrupt service. Backups and a documented recovery process remain essential.

For this case study we should define recovery objectives before production use:

- **RPO (recovery point objective):** maximum tolerable loss of recent data.
- **RTO (recovery time objective):** maximum tolerable service-recovery time.


## Consistency and durability in a clinical setting

For healthcare data, a stale laboratory result or medication record can create operational risk. MongoDB provides **write concern**, **read concern** and **read preference**, which influence durability, visibility and which replica-set member serves reads. 

| Consideration | Proposed design reasoning | Important qualification |
|---|---|---|
| Critical writes | Evaluate `writeConcern: { w: "majority" }` | Majority acknowledgement improves resistance to rollback; it does not prove successful backup or eliminate every failure |
| Critical clinical reads | Prefer primary reads with an appropriate read concern | Reading from the primary is generally fresher than reading lagging secondaries, but exact guarantees depend on settings and failure conditions |
| Majority reads | Consider read concern `"majority"` where durability visibility matters | `"majority"` does **not** necessarily mean the absolute newest write is returned |
| Strict recency requirements | Assess whether stronger consistency mechanisms are warranted | Additional latency, availability and application design trade-offs may apply |
| Multi-collection updates | Design carefully; use a transaction where required and supported | Embedding helps keep a related encounter in one document but does not make cross-document consistency automatic |

**Example:** for a critical laboratory-result status update, MetriCare could require a majority-acknowledged write, then route the subsequent clinical read through the primary with a reviewed read concern. This is a **proposed policy**, not one experimentally verified in Atlas.

## Architecture integration with existing PostgreSQL work

The earlier PostgreSQL model remains relevant for structured, constraint-heavy workflows such as invoices, payments, and appointment conflict rules. The MongoDB consultation model can support encounter-oriented reads with diagnoses, lab requests and prescriptions grouped into one document.

A future combined application would need to decide **which database owns each fact**. For example:

- PostgreSQL could remain the authoritative store for financial records and appointment scheduling.
- MongoDB could be the proposed authoritative store for future consultation documents *if* a production migration were formally designed.
- Patient identifiers shared across systems would require a governed mapping and validation process.
- Updates spanning both systems require an explicit integration strategy (for example, a service layer and reliable event/outbox process); independent updates do not constitute a single automatic cross-database transaction.

This division of responsibility is only a **design proposal**. The Portfolio 4 MongoDB sample was **not synchronized** with the PostgreSQL dataset, and no live integration is claimed.

## Security, privacy and governance

The hospital would need to protect personal and clinical data through:

- **Authentication and authorisation:** distinct application and administrator identities, role-based access, least privilege, and access review.
- **Network security:** encrypted client connections (TLS), restricted access, and appropriate private connectivity where supported.
- **Encryption and keys:** encryption at rest plus managed secrets and key lifecycle procedures.
- **Auditing:** logs for administrative and clinical-record activity, reviewed with appropriate retention and privacy controls.
- **Resilience:** independent backups, tested restores, monitoring and alerting.
- **Data governance:** data minimisation, record retention, vendor agreements, and review of any cross-border processing of Nigerian personal data under applicable law, including the Nigeria Data Protection Act, 2023.


## Benefits and constraints

| Potential advantage | Qualification / cost |
|---|---|
| More resilient clinical database | Elections, network failures and application errors can still cause interruption |
| Flexible document model | Duplicate embedded snapshots must be managed; references and schema governance still matter |
| Possible future horizontal scaling | Sharding demands workload analysis and additional operational complexity |
| Managed infrastructure | Financial cost, cloud dependency and vendor operations must be assessed |
| Multi-location access | Requires secure network access, identity management and governance |
| Faster deployment of managed features | Does not remove MetriCare's responsibility for safe configuration, privacy and recovery |

## 10. Recommendation and implementation roadmap

**Recommended initial option:** plan a managed, replicated MongoDB clinical datastore **only if** hospital scale and reliability requirements justify it. Do **not** introduce sharding at the present academic scale.

A future production project should proceed in controlled phases:

1. **Requirements:** document clinical workflows, data sensitivity, query volume, RPO/RTO, and authorized users.
2. **Design:** map the document schema, identify system-of-record responsibilities, choose appropriate consistency settings, and define security rules.
3. **Prototype:** deploy a non-production replica set with fictional or properly de-identified test data; establish monitoring and backups.
4. **Validation:** assess query behavior, replica lag, failure handling, restore procedures, access controls, and application reconnect behavior.
5. **Migration planning:** if appropriate, design data-quality checks and reconciliation between any original data source and the new system.
6. **Expansion:** revisit sharding only after measurable workload evidence supports it.


## Conclusion

For MetriCare, a replicated cloud document database is a plausible future design for consultation records because it can improve resilience while retaining the nested model demonstrated locally in Portfolio 4. A sharded architecture might be useful only when scale and query patterns justify it. The main technical design choices concern **availability during failure, consistency of clinical reads, safe recovery, and the separation of responsibilities between MongoDB and PostgreSQL**.



