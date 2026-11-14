# Cloud Architecture Diagrams

**Interpretation note:** All cloud services and replication arrows below are **proposed/hypothetical**. The only completed MongoDB exercise is the **local, single-server** Portfolio 4 document database. These are *editable Mermaid source diagrams* intended to render directly on GitHub.

## Proposed initial replica-set architecture

```mermaid
flowchart TB
    Users["Authorised MetriCare staff<br/>Physicians · Lab · Pharmacy · Billing"]
    API["Hospital application / API<br/>Authentication · Role checks · Validation"]

    subgraph CLOUD["PROPOSED cloud clinical database — NOT deployed"]
        P["MongoDB primary<br/>consultations + patients<br/>Accepts writes"]
        S1["MongoDB secondary A<br/>Asynchronous copy"]
        S2["MongoDB secondary B<br/>Asynchronous copy"]
        P -.->|"Oplog replication"| S1
        P -.->|"Oplog replication"| S2
    end

    subgraph REL["Separate relational workflow (architecture proposal)"]
        SQL["PostgreSQL service<br/>Appointments · Invoices · Payments"]
    end

    Backup["Independent backup and tested restore plan<br/>(proposed, not performed)"]

    Users --> API
    API -->|"Clinical reads / writes"| P
    API -->|"Relational billing / scheduling"| SQL
    P -.->|"Backup policy"| Backup

    classDef proposed fill:#eef6f4,stroke:#238b73,color:#134e40,stroke-width:1px;
    classDef boundary fill:#f6f7fa,stroke:#64748b,color:#1e293b;
    class P,S1,S2,API proposed;
    class Users,SQL,Backup boundary;
```

**Interpretation:**

- **Primary/secondary** are *roles*, not fixed physical servers. Elections can change which member is primary.
- Replication is **asynchronous**, so the secondaries may be behind the primary.
- The standalone relational workflow represents a **design boundary**, not a claim that the existing local PostgreSQL database has been migrated or connected to Atlas.
- Backup is a separate protection from replica copies; neither backups nor restores have been performed in this portfolio.
**Note:** No direct network path from the real local Portfolio 4 database to this proposed cloud deployment is shown, because no such connection exists in the completed exercise.


For detailed component responsibilities: [Proposed_Architecture.md](Emmanuel_Olanrewaju_301929207_P5_Proposed_Architecture.md).
