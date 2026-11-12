# Portfolio 3 — Transactions and Concurrency

All practical tests use **`p3_demo.invoice_demo`**, a small standalone table created specifically for Portfolio 3. It does **not** modify `public."Invoice"`, `public."Payment"`, `public."Patients"`, or the Portfolio 2 `p2_benchmark` tables.

| Attribute | Description |
|---|---|
| `invoice_id` | Integer primary key |
| `patient_name` | Fictional label |
| `invoice_amount` | Invoice total; positive numeric(10,2) |
| `amount_paid` | Amount recorded; constrained between zero and invoice total |
| Initial record | Invoice 1, Demo Patient, 50,000.00 due, 0.00 paid |

Amounts are fictional Nigerian naira values. The final observed committed balance following the exercises was **30,000.00 paid out of 50,000.00**, with **20,000.00 outstanding** (the screenshot of the post-isolation SELECT confirms 30,000.00; the outstanding balance is calculated).

## Files and safe execution order

| File | Purpose | 
|---|---|
| `01_Setup_HISTORICAL.sql` | Define separate schema and fictional invoice | 
| `02_COMMIT_HISTORICAL.sql` | Original payment transaction | 
| `03_ROLLBACK_Repeatable_Demo.sql` | Demonstrate cancelling a temporary payment | 
| `04_Isolation_Session_A.sql` | Instructions for uncommitted update |
| `05_Isolation_Session_B.sql` | Instructions for concurrent reads | 
| `06_Row_Lock_Session_A.sql` | Lock invoice row | Multi-step guide |
| `07_Row_Lock_Session_B.sql` | Detect conflicting lock using NOWAIT | 
| `08_Lock_Release_Verification.sql` | Lock reacquisition after Session A commits |
| `09_Read_Only_Final_Check.sql` | Inspect current invoice state |

The two Query Tool tabs must represent different backend sessions. Verify this by running `SELECT pg_backend_pid()` in each and comparing the IDs. pgAdmin may retain transaction state across separate executions in a tab: do not run an entire multi-stage workflow in one selection. If testing is interrupted, use `ROLLBACK` in any still-open demo session before continuing. Avoid changing PostgreSQL isolation settings globally.

## Experiment A — COMMIT (durability)

The initial payment record was 0.00. The billing officer added 10,000.00 using `BEGIN`, `UPDATE ... RETURNING`, and `COMMIT`. A separate read-only verification returned:

| Invoice | Total | Paid after commit | Outstanding |
|---:|---:|---:|---:|
| 1 | 50,000.00 | 10,000.00 | 40,000.00 |

**Interpretation:** The payment survived the end of the transaction and was visible to a later query, demonstrating normal durability behavior after commit. No crash-recovery test was performed.

Evidence: [P3_Commit_Verification](screenshots/P3_Commit_Verification.jpg)

## Experiment B — ROLLBACK (atomicity)

The exercise simulated an incorrect additional payment of 15,000.00 in an uncommitted transaction, then executed `ROLLBACK`. The subsequent read returned the earlier committed amount of 10,000.00 and an outstanding balance of 40,000.00.

**Interpretation:** `ROLLBACK` discarded any uncommitted change without undoing the previously committed payment. The supplied screenshot shows the post-rollback verification; no screenshot of the temporary 25,000.00 value was supplied.

Evidence: [P3_Rollback_Verification](screenshots/P3_Rollback_Verification.jpg)

## Experiment C — READ COMMITTED isolation

Two pgAdmin sessions read or modified the same invoice. An earlier attempt accidentally committed changes, setting **25,000.00** as the recorded starting value for the successful demonstration. The experiment then produced:

| Moment | Session A | Session B |
|---|---:|---:|
| Before A commits | 30,000.00 (own uncommitted UPDATE) | 25,000.00 (previously committed value) |
| After A commits | 30,000.00 | 30,000.00 (fresh SELECT) |

**Interpretation:** A separate session was not shown the uncommitted update (dirty reads prevented). Under `READ COMMITTED`, a later statement can see a newly committed value; if both B queries were in the same open transaction, this illustrates a non-repeatable read. The screenshots do not include backend PID comparisons, so this is a limitation in the available evidence.

Evidence: [P3_Session_A_Uncommitted](screenshots/P3_Session_A_Uncommitted.jpg), [P3_Session_B_Before_Commit](screenshots/P3_Session_B_Before_Commit.jpg), [P3_Session_B_After_Commit](screenshots/P3_Session_B_After_Commit.jpg)

## Experiment D — Concurrency control with FOR UPDATE NOWAIT

Session A selected invoice 1 using `SELECT ... FOR UPDATE` inside an open transaction. While A held the row lock, Session B attempted `SELECT ... FOR UPDATE NOWAIT`. PostgreSQL responded with:

```text
ERROR: could not obtain lock on row in relation "invoice_demo"
SQL state: 55P03
```

Session B then rolled back its aborted transaction; Session A committed and released its lock. When Session B repeated `FOR UPDATE NOWAIT`, the transaction completed successfully (`COMMIT` in Messages).

**Interpretation:** PostgreSQL enforces conflicting row-level locks. `NOWAIT` fails immediately rather than queuing and waiting for the lock to be released. The final screenshot displays successful completion, not the SELECT result grid.

Evidence: [P3_Session_B_Lock_Conflict](screenshots/P3_Session_B_Lock_Conflict.jpg), [P3_Lock_Released_Verification](screenshots/P3_Lock_Released_Verification.jpg)

## ACID concepts and limitations

| Principle | Portfolio 3 evidence |
|---|---|
| **Atomicity** | `ROLLBACK` undoes temporary work |
| **Consistency** | Table constraints guard positive invoice amounts and prevent overpayment; not every possible constraint failure was tested |
| **Isolation** | Committed vs uncommitted visibility under `READ COMMITTED`; row-level locking |
| **Durability** | A later query sees the committed payment; no simulated crash |

The exercise is not a production billing system: its single `amount_paid` column simplifies the real Portfolio 1 `Invoice`/`Payment` relational model. Transactions were demonstrated with fictional data in a separate schema. Screenshot coverage is strongest for result verification and lock-conflict output, with some missing intermediate captures noted transparently in `SCREENSHOT_MANIFEST.md`.

## Practical evidence and documentation

- [screenshots](screenshots/) — original pgAdmin captures supplied during the exercise.

