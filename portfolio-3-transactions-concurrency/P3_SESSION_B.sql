-- Run ONE labelled block at a time (highlight exact statements
-- Both tabs must connect to metricare_db, have different pg_backend_pid()s,
-- and stay open through the paired demonstrations.

-- ===== B0: IDENTIFY THIS INDEPENDENT CONNECTION =====
SELECT pg_backend_pid() AS session_b_pid;

-- ===== B1: START READ COMMITTED, AFTER SESSION A RUNS A2 =====
BEGIN ISOLATION LEVEL READ COMMITTED;

-- ===== B2: READ BEFORE A COMMITS (execute alone) =====
-- Expected with new invoice 302: 10000, despite A seeing uncommitted 15000.
SELECT invoice_id, amount_paid
FROM p3_demo.invoice_demo
WHERE invoice_id = 302;
-- STOP. Capture result. Ask Session A to run A3 COMMIT.

-- ===== B3: READ AGAIN AFTER A COMMITS (execute alone) =====
-- Expected: 15000. READ COMMITTED allows a new snapshot per statement.
SELECT invoice_id, amount_paid
FROM p3_demo.invoice_demo
WHERE invoice_id = 302;

-- ===== B4: END ISOLATION TRANSACTION (execute alone) =====
COMMIT;
-- Ask Session A to run A4 then A5 and leave lock held.

-- ===== B5: START LOCK-CHECK TRANSACTION (after A5; execute alone) =====
BEGIN;

-- ===== B6: DEMONSTRATE CONFLICT (execute alone; EXPECTED ERROR) =====
-- Expected SQLSTATE 55P03, since Session A holds FOR UPDATE on invoice 302.
SELECT invoice_id, invoice_amount, amount_paid
FROM p3_demo.invoice_demo
WHERE invoice_id = 302
FOR UPDATE NOWAIT;
-- STOP. Screenshot error. Do not mistake this for a defective script.

-- ===== B7: CLEAR FAILED TRANSACTION (execute alone) =====
ROLLBACK;
-- Ask Session A to run A6 COMMIT and release its row lock.

-- ===== B8: VERIFY LOCK RELEASE (select entire block together) =====
-- Expected: no lock error. Result and COMMIT are both legitimate evidence.
BEGIN;
SELECT invoice_id, invoice_amount, amount_paid
FROM p3_demo.invoice_demo
WHERE invoice_id = 302
FOR UPDATE NOWAIT;
COMMIT;

-- ===== B9: FINAL READ-ONLY CHECK (execute alone) =====
SELECT invoice_id, invoice_amount, amount_paid,
       invoice_amount - amount_paid AS outstanding_balance
FROM p3_demo.invoice_demo
WHERE invoice_id = 302;
