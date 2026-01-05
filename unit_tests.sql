USE hotel_management_db1;

-- ============================================================
-- TESTS (PASS first, FAIL tests at end but they don't stop script)
-- ============================================================

-- -------------------------
-- Setup ids
-- -------------------------
SET @r1 :=
(SELECT reservation_id
FROM Reservations
WHERE notes='SEED_R1');
SET @r2 :=
(SELECT reservation_id
FROM Reservations
WHERE notes='SEED_R2');
SET @r3 :=
(SELECT reservation_id
FROM Reservations
WHERE notes='SEED_R3');

SET @room101 :=
(SELECT room_id
FROM Rooms
WHERE room_number='101');
SET @room102 :=
(SELECT room_id
FROM Rooms
WHERE room_number='102');
SET @room103 :=
(SELECT room_id
FROM Rooms
WHERE room_number='103');
SET @room104 :=
(SELECT room_id
FROM Rooms
WHERE room_number='104');
SET @room201 :=
(SELECT room_id
FROM Rooms
WHERE room_number='201');
SET @room202 :=
(SELECT room_id
FROM Rooms
WHERE room_number='202');
SET @room301 :=
(SELECT room_id
FROM Rooms
WHERE room_number='301');
SET @room502 :=
(SELECT room_id
FROM Rooms
WHERE room_number='502');

-- ============================================================
-- PASS TESTS (should not error)
-- ============================================================

-- P0: Show seed snapshot
SELECT 'P0_seed_reservations' AS test_name;
SELECT reservation_id, notes, reservation_status, check_in_date, check_out_date, total_price, deposit_amount
FROM Reservations
WHERE notes LIKE 'SEED_R%'
ORDER BY reservation_id;

-- P1: Deposit matches assigned rooms (your output already showed PASS; keep it here anyway)
SELECT 'P1_deposit_matches_rooms' AS test_name;
SELECT r.reservation_id, r.notes,
    r.deposit_amount AS stored_deposit,
    (
         SELECT IFNULL(SUM(rt.deposit_required),0.00)
    FROM Reservation_Rooms rr
        JOIN Rooms rm ON rm.room_id = rr.room_id
        JOIN Room_Types rt ON rt.room_type_id = rm.room_type_id
    WHERE rr.reservation_id = r.reservation_id
       ) AS expected_deposit,
    CASE
         WHEN r.deposit_amount = (
           SELECT IFNULL(SUM(rt.deposit_required),0.00)
    FROM Reservation_Rooms rr
        JOIN Rooms rm ON rm.room_id = rr.room_id
        JOIN Room_Types rt ON rt.room_type_id = rm.room_type_id
    WHERE rr.reservation_id = r.reservation_id
         ) THEN 'PASS' ELSE 'FAIL'
       END AS result
FROM Reservations r
WHERE r.notes IN ('SEED_R1','SEED_R2','SEED_R3','SEED_R4','SEED_R5')
ORDER BY r.reservation_id;

-- P2: Payment summary for seeded data (no errors)
SELECT 'P2_payment_summary' AS test_name;
SELECT r.notes,
    r.total_price,
    r.deposit_amount,
    IFNULL(SUM(CASE WHEN p.status='Completed' THEN p.amount END),0) AS completed_paid,
    GROUP_CONCAT(CONCAT(p.payment_type, ':', p.status, ':', p.amount)
ORDER BY p.payment_id SEPARATOR ' | ') AS payments
FROM Reservations r
LEFT JOIN Payments p ON p.reservation_id = r.reservation_id
WHERE r.notes IN
('SEED_R1','SEED_R2','SEED_R3','SEED_R4','SEED_R5')
GROUP BY r.reservation_id, r.notes, r.total_price, r.deposit_amount
ORDER BY r.reservation_id;

-- P3: Procedure PASS: create reservation that includes today, fully pay, check-in, then check-out
DROP PROCEDURE IF EXISTS Test_Pass_CheckInOut_Today;
DELIMITER //
CREATE PROCEDURE Test_Pass_CheckInOut_Today()
BEGIN
    DECLARE v_res INT UNSIGNED;
DECLARE v_total DECIMAL
(10,2);
DECLARE v_room INT UNSIGNED;

-- Pick an available room automatically (Vacant or Cleaning, not unavailable/renovation,
-- and not overlapping with any Confirmed/Checked-in reservation for today)
SELECT rm.room_id
INTO v_room
FROM Rooms rm
WHERE rm.current_status IN ('Vacant','Cleaning')
    AND rm.current_status NOT IN ('Not Available','Under Renovation')
    AND NOT EXISTS (
      SELECT 1
    FROM Reservation_Rooms rr
        JOIN Reservations r ON r.reservation_id = rr.reservation_id
    WHERE rr.room_id = rm.room_id
        AND r.reservation_status IN ('Confirmed','Checked-in')
        AND CURDATE() < r.check_out_date
        AND DATE_ADD(CURDATE(), INTERVAL
2 DAY) > r.check_in_date
    )
  ORDER BY rm.room_id
  LIMIT 1;

IF v_room IS NULL THEN
SELECT 'P3_checkinout_today' AS test_name, 'FAIL' AS result,
    'No free room found for today (Vacant/Cleaning and no overlap).' AS details;
ELSE
INSERT INTO Reservations
    (customer_id, check_in_date, check_out_date, number_of_guests, total_price, pay_at_checkin, booking_source, notes)
VALUES
    (
        (SELECT customer_id
        FROM Customers
        ORDER BY customer_id LIMIT 1),
      CURDATE
(),
      DATE_ADD
(CURDATE
(), INTERVAL 2 DAY),
      1, 180.00, 0, 'Walk-in', 'TEST_TODAY_OK'
    );

SET v_res
:= LAST_INSERT_ID
();

INSERT INTO Reservation_Rooms
    (reservation_id, room_id)
VALUES
    (v_res, v_room);

SELECT total_price
INTO v_total
FROM Reservations
WHERE reservation_id = v_res;

INSERT INTO Payments
    (reservation_id, payment_type, amount, payment_method, status, notes)
VALUES
    (v_res, 'Final', v_total, 'Online', 'Completed', 'Full upfront for PASS test');

CALL PerformRoomCheckIn
(v_res, v_room);

    CALL PerformRoomCheckOut
(v_res, v_room);

SELECT 'P3_checkinout_today' AS test_name,
    'PASS' AS result,
    v_res AS reservation_id,
    v_room AS room_id,
    (SELECT reservation_status
    FROM Reservations
    WHERE reservation_id=v_res) AS reservation_status,
    (SELECT current_status
    FROM Rooms
    WHERE room_id=v_room) AS room_status;
END
IF;
END//
DELIMITER ;

CALL Test_Pass_CheckInOut_Today
();

-- ============================================================
-- FAIL TESTS (expected to be blocked) - BUT THEY WON'T STOP SCRIPT
-- Each test catches the SQL error and prints it.
-- ============================================================

DROP PROCEDURE IF EXISTS Run_Fail_Tests;
DELIMITER //
CREATE PROCEDURE Run_Fail_Tests()
BEGIN
    DECLARE v_err TEXT;

-- F1: Overlapping booking should be blocked
BEGIN
    DECLARE
    CONTINUE
    HANDLER FOR SQLEXCEPTION
    BEGIN
    GET DIAGNOSTICS CONDITION 1 v_err = MESSAGE_TEXT;
    SELECT 'F1_overlap_room_booking' AS test_name, 'PASS (blocked)' AS result, v_err AS error_message;
END;

-- Create reservation overlapping SEED_R1 and try room 101
INSERT INTO Reservations
    (customer_id, check_in_date, check_out_date, number_of_guests, total_price, pay_at_checkin, booking_source, notes)
VALUES
    ((SELECT customer_id
        FROM Customers
        ORDER BY customer_id LIMIT 1),
            '2026-01-16','2026-01-18', 1, 200.00, 0, 'Website', 'TEST_OV_A2');

    INSERT INTO Reservation_Rooms
(reservation_id, room_id)
    VALUES
(LAST_INSERT_ID
(), @room101);

-- If it reaches here, it was NOT blocked (bad)
SELECT 'F1_overlap_room_booking' AS test_name, 'FAIL (should have been blocked)' AS result,
    'Room was booked despite overlap' AS error_message;
END;

-- F2: Under Renovation room should be blocked
BEGIN
    DECLARE
    CONTINUE
    HANDLER FOR SQLEXCEPTION
    BEGIN
    GET DIAGNOSTICS CONDITION 1 v_err = MESSAGE_TEXT;
    SELECT 'F2_unavailable_room' AS test_name, 'PASS (blocked)' AS result, v_err AS error_message;
END;

INSERT INTO Reservations
    (customer_id, check_in_date, check_out_date, number_of_guests, total_price, pay_at_checkin, booking_source, notes)
VALUES
    ((SELECT customer_id
        FROM Customers
        ORDER BY customer_id LIMIT 1),
            '2026-03-01','2026-03-03', 1, 200.00, 0, 'Website', 'TEST_UNAV2');

    INSERT INTO Reservation_Rooms
(reservation_id, room_id)
    VALUES
(LAST_INSERT_ID
(), @room502);

SELECT 'F2_unavailable_room' AS test_name, 'FAIL (should have been blocked)' AS result,
    'Room 502 was booked though under renovation' AS error_message;
END;

-- F3: Completed payment without rooms should be blocked
BEGIN
    DECLARE
    CONTINUE
    HANDLER FOR SQLEXCEPTION
    BEGIN
    GET DIAGNOSTICS CONDITION 1 v_err = MESSAGE_TEXT;
    SELECT 'F3_completed_payment_without_rooms' AS test_name, 'PASS (blocked)' AS result, v_err AS error_message;
END;

INSERT INTO Reservations
    (customer_id, check_in_date, check_out_date, number_of_guests, total_price, pay_at_checkin, booking_source, notes)
VALUES
    ((SELECT customer_id
        FROM Customers
        ORDER BY customer_id LIMIT 1),
            '2026-03-10','2026-03-12', 1, 250.00, 0, 'Website', 'TEST_PAY_NOROOM2');

    INSERT INTO Payments
(reservation_id, payment_type, amount, payment_method, status, notes)
    VALUES
(LAST_INSERT_ID
(), 'Final', 250.00, 'Online', 'Completed', 'Should fail');

SELECT 'F3_completed_payment_without_rooms' AS test_name, 'FAIL (should have been blocked)' AS result,
    'Completed payment succeeded without rooms' AS error_message;
END;

-- F4: Deposit not allowed when deposit_amount=0 (SEED_R1)
BEGIN
    DECLARE
    CONTINUE
    HANDLER FOR SQLEXCEPTION
    BEGIN
    GET DIAGNOSTICS CONDITION 1 v_err = MESSAGE_TEXT;
    SELECT 'F4_deposit_not_allowed_when_deposit_zero' AS test_name, 'PASS (blocked)' AS result, v_err AS error_message;
END;

INSERT INTO Payments
    (reservation_id, payment_type, amount, payment_method, status, notes)
VALUES
    (@r1, 'Deposit', 10.00, 'Cash', 'Pending', 'Should fail');

SELECT 'F4_deposit_not_allowed_when_deposit_zero' AS test_name, 'FAIL (should have been blocked)' AS result,
    'Deposit row inserted for deposit_amount=0 reservation' AS error_message;
END;

-- F5: Freeze total_price after Completed payments exist (SEED_R2)
BEGIN
    DECLARE
    CONTINUE
    HANDLER FOR SQLEXCEPTION
    BEGIN
    GET DIAGNOSTICS CONDITION 1 v_err = MESSAGE_TEXT;
    SELECT 'F5_freeze_total_price_after_completed' AS test_name, 'PASS (blocked)' AS result, v_err AS error_message;
END;

UPDATE Reservations SET total_price = total_price + 1 WHERE reservation_id = @r2;

SELECT 'F5_freeze_total_price_after_completed' AS test_name, 'FAIL (should have been blocked)' AS result,
    'total_price changed despite completed payments' AS error_message;
END;

-- F6: Cannot modify rooms after any Completed payment exists (SEED_R2)
BEGIN
    DECLARE
    CONTINUE
    HANDLER FOR SQLEXCEPTION
    BEGIN
    GET DIAGNOSTICS CONDITION 1 v_err = MESSAGE_TEXT;
    SELECT 'F6_modify_rooms_after_completed' AS test_name, 'PASS (blocked)' AS result, v_err AS error_message;
END;

INSERT INTO Reservation_Rooms
    (reservation_id, room_id)
VALUES
    (@r2, @room102);

SELECT 'F6_modify_rooms_after_completed' AS test_name, 'FAIL (should have been blocked)' AS result,
    'Was able to add room after completed payment' AS error_message;
END;

-- F7: Check-in blocked if not fully paid (SEED_R3 is deposit-only completed)
BEGIN
    DECLARE
    CONTINUE
    HANDLER FOR SQLEXCEPTION
    BEGIN
    GET DIAGNOSTICS CONDITION 1 v_err = MESSAGE_TEXT;
    SELECT 'F7_checkin_blocked_not_fully_paid' AS test_name, 'PASS (blocked)' AS result, v_err AS error_message;
END;

UPDATE Reservations SET reservation_status='Checked-in' WHERE reservation_id = @r3;

SELECT 'F7_checkin_blocked_not_fully_paid' AS test_name, 'FAIL (should have been blocked)' AS result,
    'Was able to check in without full payment' AS error_message;
END;

END//
DELIMITER ;

CALL Run_Fail_Tests
();

-- Final summary (optional)
SELECT 'DONE_all_tests_ran' AS status;
