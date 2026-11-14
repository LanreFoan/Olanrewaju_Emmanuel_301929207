-- Complete TRANSACTION.sql BLOCK T1 first: invoice 302 should have 10000 paid.
-- Do not close the connection while its transaction is open.

-- ===== A0: IDENTIFY THIS INDEPENDENT CONNECTION =====
SELECT pg_backend_pid() AS session_a_pid;

-- ===== A1: START READ COMMITTED TRANSACTION (execute alone) =====
BEGIN ISOLATION LEVEL READ COMMITTED;

-- ===== A2: ADD UNCOMMITTED PAYMENT (execute alone; keep transaction open) =====
-- Expected with fresh invoice 302: 10000 -> 15000, visible only in Session A.
UPDATE p3_demo.invoice_demo
SET amount_paid = amount_paid + 5000.00
WHERE invoice_id = 302
  AND amount_paid + 5000.00 <= invoice_amount
RETURNING invoice_id, amount_paid;
-- STOP. Session B now runs B1 then B2 and screenshots old committed value.

-- ===== A3: COMMIT ONLY AFTER B2 (execute alone)
COMMIT;
-- Session B now runs B3 and B4; should see newly committed 15000.

-- ===== A4: START ROW-LOCK TRANSACTION (after B4; execute alone) =====
BEGIN;

-- ===== A5: LOCK INVOICE 302 (execute alone; DO NOT COMMIT YET) =====
SELECT invoice_id, invoice_amount, amount_paid
FROM p3_demo.invoice_demo
WHERE invoice_id = 302
FOR UPDATE;
-- STOP. Session B now runs B5 and B6; B6 should fail SQLSTATE 55P03.

-- ===== A6: RELEASE LOCK AFTER B6 ERROR (execute alone) =====
COMMIT;
-- Session B then runs B7 and B8 to prove locking works after release.
