# Portfolio 2  Query Processing and Optimization

In Portfolio 2, a **separate** schema `p2_benchmark` holds synthetic appointment history, so the original Portfolio 1 clinical and billing records remain untouched. Patient and doctor IDs came from the original data, rather than arbitrary guessed keys. Previous pgAdmin verification recorded **100,000 synthetic rows**.

## Benchmark query and expected result

The query retrieves outpatient appointment-history entries for **10 November 2026** using a half-open timestamp range, which includes the whole date and excludes midnight on 11 November:

```sql
SELECT synthetic_history_id, patient_id, doctor_id,
       appointment_datetime, appointment_status
FROM p2_benchmark.appointment_history_synthetic
WHERE appointment_datetime >= TIMESTAMP '2026-11-10 00:00:00'
  AND appointment_datetime < TIMESTAMP '2026-11-11 00:00:00';
```

pgAdmin results indicate **55 matching rows out of 100,000** (0.055% selectivity). `00_Verify_Benchmark.sql` reproduces the row count and returns the actual matching rows. Screenshots of the returned rows should be added if not already available.

## Plan before indexing

Run with `EXPLAIN (ANALYZE, BUFFERS)` (historical SQL shown in `01_Baseline_Plan_HISTORICAL.sql`). Before index creation, PostgreSQL selected a **Sequential Scan**, examining the 100,000-row table and discarding **99,945** rows under the filter. Observed screenshots show **1,235 shared buffer hits** and `Execution Time` of **13.682 ms** and **22.006 ms** in distinct reported measurements.

**Do not rerun this plan file and call the result a baseline**: the index now exists, so a newly executed plan reflects the *current* indexed schema.

## Index choice and implementation

A B-tree index on the timestamp column supports the `>=` and `<` range predicates:

```sql
CREATE INDEX idx_ahs_appointment_datetime
ON p2_benchmark.appointment_history_synthetic
USING BTREE (appointment_datetime);

ANALYZE p2_benchmark.appointment_history_synthetic;
```

These are the statements used historically. **The index already exists; do not run the creation script again.** `ANALYZE` updates statistics to inform planner estimates. `03_Verify_Index.sql` safely inspects the installed indexes. An additional primary-key index exists on the table; the date index is separate.

## Plan after indexing

The same query subsequently produced a **Bitmap Index Scan** on `idx_ahs_appointment_datetime` followed by a **Bitmap Heap Scan**. PostgreSQL used the index to identify relevant row locations and then read the matching table rows. This is *observed index usage*, not a claim that every query will always prefer an index. The retrieved row count remained 55.

One post-index screenshot shows **7.410 ms** with index and heap scans; another shows **12.042 ms**. These are additional executions **not included** in the specified three post-index measurement runs, which were reported separately.

## Timing comparison and calculations

| Measured run | Before indexing (ms) | After indexing (ms) |
|---|---:|---:|
| 1 | 13.682 | 0.512 |
| 2 | 13.682 | 0.314 |
| 3 | 22.006 | 0.186 |
| **Mean** | **16.457** | **0.337** |

All times ABOVE are **PostgreSQL `Execution Time` from `EXPLAIN (ANALYZE, BUFFERS)`**, in milliseconds, as reported in the conversation. 

Calculations with unrounded means:

- Pre-index mean = `(13.682 + 13.682 + 22.006) / 3 = 16.456666… ms`
- Post-index mean = `(0.512 + 0.314 + 0.186) / 3 = 0.337333… ms`
- Indicative time reduction = `(1 − 0.337333… / 16.456666…) × 100 ≈ 97.95%`
- Indicative speedup = `16.456666… / 0.337333… ≈ 48.79×`
  Based on the reported three-run classification, the average time was reduced by **approximately 97.95%**, or an **approximately 48.79× speedup**. Calculations use the unrounded averages.


## Interpretation and limitations

The baseline Sequential Scan examined all rows, returning only a very small subset. Following index creation, an index-assisted bitmap plan located the relevant timestamps and table rows more selectively. The reported indexed runs are, on average, faster than the reported baseline runs, consistent with the plan change.

Observed times vary (including post-index runs of 7.410 and 12.042 ms), so indexing alone does not guarantee a fixed execution time. Cache state, operating system activity, physical I/O, planner estimates, and repeated measurements can affect timing. `EXPLAIN ANALYZE` reports server-side execution time; it is **not** the pgAdmin UI round-trip or Query History duration. B-tree indexes also consume storage and incur maintenance costs during data modifications. The benchmark uses synthetic data and does not directly establish production workload performance.
