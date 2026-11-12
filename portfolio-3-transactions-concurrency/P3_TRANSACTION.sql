-- Run each numbered BLOCK separately by HIGHLIGHTING its SQL and pressing F5.
-- Do not run the entire file in one click. Never use invoice_id = 1 for repeat tests:
-- invoice 1 contains the genuine evidence from our earlier Portfolio 3 runs.
-- Only p3_demo is changed; public Portfolio 1 tables are untouched.

-- ===== T1: ONE-TIME DEMO SETUP (run this whole block first) =====
CREATE SCHEMA IF NOT EXISTS p3_demo;
CREATE TABLE IF NOT EXISTS p3_demo.invoice_demo (
    invoice_id INTEGER PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    invoice_amount NUMERIC(10,2) NOT NULL CHECK (invoice_amount > 0),
    amount_paid NUMERIC(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT chk_p3_paid_range CHECK (
        amount_paid >= 0 AND amount_paid <= invoice_amount
    )
);
INSERT INTO p3_demo.invoice_demo
    (invoice_id, patient_name, invoice_amount, amount_paid)
VALUES
    (301, 'Commit and Rollback Demo Patient', 50000.00, 0.00),
    (302, 'Concurrent Billing Demo Patient', 50000.00, 10000.00)
ON CONFLICT (invoice_id) DO NOTHING;
SELECT invoice_id, patient_name, invoice_amount, amount_paid
FROM p3_demo.invoice_demo
WHERE invoice_id IN (301, 302)
ORDER BY invoice_id;

-- ===== T2: COMMIT EXAMPLE (select BEGIN through COMMIT together) =====
-- Expected for untouched invoice 301: amount_paid increases 0 -> 10000.
-- The guard protects against accidentally applying the payment twice.
BEGIN;
UPDATE p3_demo.invoice_demo
SET amount_paid = amount_paid + 10000.00
WHERE invoice_id = 301 AND amount_paid = 0.00
RETURNING invoice_id, invoice_amount, amount_paid;
COMMIT;

-- ===== T3: VERIFY COMMIT (separate execution) =====
-- Expected: invoice 301 amount_paid = 10000; balance = 40000.
SELECT invoice_id, invoice_amount, amount_paid,
       invoice_amount - amount_paid AS outstanding_balance
FROM p3_demo.invoice_demo
WHERE invoice_id = 301;

-- ===== T4: ROLLBACK - TEMPORARY WRONG PAYMENT (separate execution) =====
-- Select BEGIN through RETURNING only. DO NOT COMMIT this transaction.
-- Invoice 301 should temporarily show 25000 if T2 succeeded.
BEGIN;
UPDATE p3_demo.invoice_demo
SET amount_paid = amount_paid + 15000.00
WHERE invoice_id = 301
  AND amount_paid + 15000.00 <= invoice_amount
RETURNING invoice_id, invoice_amount, amount_paid;
-- STOP: screenshot temporary value. Then execute T5 in THIS SAME pgAdmin tab.

-- ===== T5: UNDO WRONG PAYMENT (execute separately in same connection) =====
ROLLBACK;

-- ===== T6: VERIFY ROLLBACK (separate execution) =====
-- Expected: invoice 301 amount_paid returns to 10000, balance 40000.
SELECT invoice_id, invoice_amount, amount_paid,
       invoice_amount - amount_paid AS outstanding_balance
FROM p3_demo.invoice_demo
WHERE invoice_id = 301;

-- ===== T7: CHECK ORIGINAL HISTORICAL EVIDENCE (READ-ONLY) =====
-- Existing invoice 1 was used for your original screenshots; don't update it.
SELECT invoice_id, invoice_amount, amount_paid,
       invoice_amount - amount_paid AS outstanding_balance
FROM p3_demo.invoice_demo
WHERE invoice_id = 1;
