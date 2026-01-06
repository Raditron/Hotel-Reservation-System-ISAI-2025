DROP PROCEDURE IF EXISTS Run_Fail_Tests;
DELIMITER //
CREATE PROCEDURE Run_Fail_Tests()
BEGIN
  DECLARE v_err TEXT;

  -- F1: Overlapping booking should be blocked
  f1: BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      GET DIAGNOSTICS CONDITION 1 v_err = MESSAGE_TEXT;
      SELECT 'F1_overlap_room_booking' AS test_name, 'PASS (blocked)' AS result, v_err AS error_message;
    END;

    INSERT INTO Reservations(customer_id, check_in_date, check_out_date, number_of_guests, total_price, pay_at_checkin, booking_source, notes)
    VALUES ((SELECT customer_id FROM Customers ORDER BY customer_id LIMIT 1),
            '2026-01-16','2026-01-18', 1, 200.00, 0, 'Website', 'TEST_OV_A2');

    INSERT INTO Reservation_Rooms(reservation_id, room_id)
    VALUES (LAST_INSERT_ID(), @room101);

    SELECT 'F1_overlap_room_booking' AS test_name, 'FAIL (should have been blocked)' AS result,
           'Room was booked despite overlap' AS error_message;
  END;

  -- F2: Under Renovation room should be blocked
  f2: BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      GET DIAGNOSTICS CONDITION 1 v_err = MESSAGE_TEXT;
      SELECT 'F2_unavailable_room' AS test_name, 'PASS (blocked)' AS result, v_err AS error_message;
    END;

    INSERT INTO Reservations(customer_id, check_in_date, check_out_date, number_of_guests, total_price, pay_at_checkin, booking_source, notes)
    VALUES ((SELECT customer_id FROM Customers ORDER BY customer_id LIMIT 1),
            '2026-03-01','2026-03-03', 1, 200.00, 0, 'Website', 'TEST_UNAV2');

    INSERT INTO Reservation_Rooms(reservation_id, room_id)
    VALUES (LAST_INSERT_ID(), @room502);

    SELECT 'F2_unavailable_room' AS test_name, 'FAIL (should have been blocked)' AS result,
           'Room 502 was booked though under renovation' AS error_message;
  END;

  -- F3: Completed payment without rooms should be blocked
  f3: BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      GET DIAGNOSTICS CONDITION 1 v_err = MESSAGE_TEXT;
      SELECT 'F3_completed_payment_without_rooms' AS test_name, 'PASS (blocked)' AS result, v_err AS error_message;
    END;

    INSERT INTO Reservations(customer_id, check_in_date, check_out_date, number_of_guests, total_price, pay_at_checkin, booking_source, notes)
    VALUES ((SELECT customer_id FROM Customers ORDER BY customer_id LIMIT 1),
            '2026-03-10','2026-03-12', 1, 250.00, 0, 'Website', 'TEST_PAY_NOROOM2');

    INSERT INTO Payments(reservation_id, payment_type, amount, payment_method, status, notes)
    VALUES (LAST_INSERT_ID(), 'Final', 250.00, 'Online', 'Completed', 'Should fail');

    SELECT 'F3_completed_payment_without_rooms' AS test_name, 'FAIL (should have been blocked)' AS result,
           'Completed payment succeeded without rooms' AS error_message;
  END;

  -- F4: Deposit not allowed when deposit_amount=0 (SEED_R1)
  f4: BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      GET DIAGNOSTICS CONDITION 1 v_err = MESSAGE_TEXT;
      SELECT 'F4_deposit_not_allowed_when_deposit_zero' AS test_name, 'PASS (blocked)' AS result, v_err AS error_message;
    END;

    INSERT INTO Payments(reservation_id, payment_type, amount, payment_method, status, notes)
    VALUES (@r1, 'Deposit', 10.00, 'Cash', 'Pending', 'Should fail');

    SELECT 'F4_deposit_not_allowed_when_deposit_zero' AS test_name, 'FAIL (should have been blocked)' AS result,
           'Deposit row inserted for deposit_amount=0 reservation' AS error_message;
  END;

  -- F5: Freeze total_price after Completed payments exist (SEED_R2)
  f5: BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      GET DIAGNOSTICS CONDITION 1 v_err = MESSAGE_TEXT;
      SELECT 'F5_freeze_total_price_after_completed' AS test_name, 'PASS (blocked)' AS result, v_err AS error_message;
    END;

    UPDATE Reservations SET total_price = total_price + 1 WHERE reservation_id = @r2;

    SELECT 'F5_freeze_total_price_after_completed' AS test_name, 'FAIL (should have been blocked)' AS result,
           'total_price changed despite completed payments' AS error_message;
  END;

  -- F6: Cannot modify rooms after any Completed payment exists (SEED_R2)
  f6: BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      GET DIAGNOSTICS CONDITION 1 v_err = MESSAGE_TEXT;
      SELECT 'F6_modify_rooms_after_completed' AS test_name, 'PASS (blocked)' AS result, v_err AS error_message;
    END;

    INSERT INTO Reservation_Rooms(reservation_id, room_id)
    VALUES (@r2, @room102);

    SELECT 'F6_modify_rooms_after_completed' AS test_name, 'FAIL (should have been blocked)' AS result,
           'Was able to add room after completed payment' AS error_message;
  END;

  -- F7: Check-in blocked if not fully paid (SEED_R3 is deposit-only completed)
  f7: BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
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
CALL Run_Fail_Tests();
