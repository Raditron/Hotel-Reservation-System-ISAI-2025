USE hotel_management_db;
-- =====================================================================================
-- 1) Roles
-- =====================================================================================
INSERT INTO Roles (role_name, description) VALUES
('Manager', 'Full access'),
('Receptionist', 'Front desk operations'),
('Housekeeping', 'Cleaning staff'),
('Maintenance', 'Technical staff'),
('Accounting', 'Finance & payroll');

SET @reception_role_id = (SELECT role_id FROM Roles WHERE role_name = 'Receptionist');
SET @manager_role_id   = (SELECT role_id FROM Roles WHERE role_name = 'Manager');
SET @housekeeping_role_id = (SELECT role_id FROM Roles WHERE role_name = 'Housekeeping');

-- =====================================================================================
-- 2) Employees
-- =====================================================================================
INSERT INTO Employees (first_name, last_name, national_id, date_of_birth, phone_number, email, role_id, hire_date, base_pay_rate, status) VALUES
('Alice', 'Smith', '19800101-1234', '1980-01-01', '55510001', 'alice.smith@hotel.com', @manager_role_id, '2015-05-20', 80000.00, 'Active'),
('Bob', 'Johnson', '19920315-5678', '1992-03-15', '55510002', 'bob.johnson@hotel.com', @reception_role_id, '2020-08-10', 45000.00, 'Active'),
('Clara', 'Diaz', '19951122-9012', '1995-11-22', '55510003', 'clara.diaz@hotel.com', @housekeeping_role_id, '2022-01-15', 30000.00, 'Active'),
('David', 'Lee', '19880704-3456', '1988-07-04', '55510004', 'david.lee@hotel.com', @reception_role_id, '2021-04-01', 46000.00, 'Active'),
('Eva', 'Rodriguez', '19750930-7890', '1975-09-30', '55510005', 'eva.rodriguez@hotel.com', @manager_role_id, '2018-11-01', 82000.00, 'On Leave');

SET @alice_id = (SELECT employee_id FROM Employees WHERE email = 'alice.smith@hotel.com');
SET @bob_id   = (SELECT employee_id FROM Employees WHERE email = 'bob.johnson@hotel.com');
SET @clara_id = (SELECT employee_id FROM Employees WHERE email = 'clara.diaz@hotel.com');

-- =====================================================================================
-- 3) Room types
-- =====================================================================================
INSERT INTO Room_Types (type_name, standard_price, capacity, bed_count, description, amenities) VALUES
('Standard King', 150.00, 2, 1, 'Comfortable room with a single king-size bed.', JSON_OBJECT('WiFi', true, 'TV', true, 'Mini Bar', true)),
('Deluxe Double', 180.00, 4, 2, 'Spacious room with two double beds, ideal for families.', JSON_OBJECT('WiFi', true, 'TV', true, 'Mini Bar', true, 'Sofa Bed', true)),
('Executive Suite', 350.00, 2, 1, 'Large suite with separate living area and premium amenities.', JSON_OBJECT('WiFi', true, 'TV', true, 'Mini Bar', true, 'Private Balcony', true, 'Coffee Maker', true));

SET @king_type_id    = (SELECT room_type_id FROM Room_Types WHERE type_name = 'Standard King');
SET @double_type_id  = (SELECT room_type_id FROM Room_Types WHERE type_name = 'Deluxe Double');
SET @suite_type_id   = (SELECT room_type_id FROM Room_Types WHERE type_name = 'Executive Suite');

-- =====================================================================================
-- 4) Rooms (start as VACANT except maintenance/unavailable)
-- =====================================================================================
INSERT INTO Rooms (room_number, room_type_id, current_status) VALUES
('101', @king_type_id, 'Vacant'),
('102', @king_type_id, 'Vacant'),
('201', @double_type_id, 'Vacant'),
('202', @double_type_id, 'Vacant'),
('301', @suite_type_id, 'Maintenance'),   -- intentionally unavailable
('302', @suite_type_id, 'Vacant');

SET @room_101 = (SELECT room_id FROM Rooms WHERE room_number = '101');
SET @room_102 = (SELECT room_id FROM Rooms WHERE room_number = '102');
SET @room_201 = (SELECT room_id FROM Rooms WHERE room_number = '201');
SET @room_202 = (SELECT room_id FROM Rooms WHERE room_number = '202');
SET @room_302 = (SELECT room_id FROM Rooms WHERE room_number = '302');

-- =====================================================================================
-- 5) Customers
-- =====================================================================================
INSERT INTO Customers (first_name, last_name, national_id, date_of_birth, phone_number, email, country) VALUES
('John', 'Doe', '19780510-1234', '1978-05-10', '910000001', 'john.doe@example.com', 'USA'),
('Maria', 'Garcia', '19901205-5678', '1990-12-05', '910000002', 'maria.g@example.com', 'Spain'),
('Chen', 'Wei', '19850320-9012', '1985-03-20', '910000003', 'chen.wei@example.com', 'China'),
('Sarah', 'Connor', '19990815-3456', '1999-08-15', '910000004', 'sarah.c@example.com', 'Canada');

SET @john_id  = (SELECT customer_id FROM Customers WHERE last_name = 'Doe' LIMIT 1);
SET @maria_id = (SELECT customer_id FROM Customers WHERE last_name = 'Garcia' LIMIT 1);
SET @chen_id  = (SELECT customer_id FROM Customers WHERE last_name = 'Wei' LIMIT 1);

-- =====================================================================================
-- 6) Reservations (create as CONFIRMED or pay_at_checkin as required)
--    We will not mark them 'Checked-in' until we call the procedure.
-- =====================================================================================

-- Reservation 1: multi-room intended to be checked-in during tests
INSERT INTO Reservations (customer_id, check_in_date, check_out_date, number_of_guests, reservation_status, total_price, pay_at_checkin, booking_source)
VALUES (@john_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 3 DAY), 3, 'Confirmed', 480.00, FALSE, 'Website');
SET @res_multi_room = LAST_INSERT_ID();

-- Reservation 2: today's arrival (Confirmed)
INSERT INTO Reservations (customer_id, check_in_date, check_out_date, number_of_guests, reservation_status, total_price, pay_at_checkin, booking_source)
VALUES (@maria_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 1 DAY), 2, 'Confirmed', 150.00, FALSE, 'Booking.com');
SET @res_today_arrival = LAST_INSERT_ID();

-- Reservation 3: will go through check-in then check-out simulation (so create as Confirmed)
INSERT INTO Reservations (customer_id, check_in_date, check_out_date, number_of_guests, reservation_status, total_price, pay_at_checkin, booking_source)
VALUES (@chen_id, DATE_SUB(CURDATE(), INTERVAL 2 DAY), CURDATE(), 4, 'Confirmed', 360.00, FALSE, 'Expedia');
SET @res_today_departure = LAST_INSERT_ID();

-- Reservation 4: future, pay at checkin
INSERT INTO Reservations (customer_id, check_in_date, check_out_date, number_of_guests, reservation_status, total_price, pay_at_checkin, booking_source)
VALUES (@john_id, DATE_ADD(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 32 DAY), 2, 'Confirmed', 300.00, TRUE, 'Walk-in');
SET @res_future_pay_at_desk = LAST_INSERT_ID();

-- =====================================================================================
-- 7) Link rooms to reservations (Reservation_Rooms). This will be checked by overlap trigger.
--    We link BEFORE check-in; procedures will update room statuses.
-- =====================================================================================
-- Multi-room reservation (Res 1) linked to 101 and 201
INSERT INTO Reservation_Rooms (reservation_id, room_id) VALUES
(@res_multi_room, @room_101),
(@res_multi_room, @room_201);

-- Today's arrival (Res 2) linked to 102
INSERT INTO Reservation_Rooms (reservation_id, room_id) VALUES
(@res_today_arrival, @room_102);

-- Today's departure (Res 3) linked to 202
INSERT INTO Reservation_Rooms (reservation_id, room_id) VALUES
(@res_today_departure, @room_202);

-- Future reservation (Res 4) linked to 302
INSERT INTO Reservation_Rooms (reservation_id, room_id) VALUES
(@res_future_pay_at_desk, @room_302);

-- =====================================================================================
-- 8) Payments
--    For reservations with pay_at_checkin = FALSE we insert Completed payment (required to check-in).
--    Reservation with pay_at_checkin = TRUE we insert a pending zero or leave absent.
-- =====================================================================================
INSERT INTO Payments (reservation_id, amount, payment_method, status) VALUES
(@res_multi_room, 480.00, 'Credit Card', 'Completed'),
(@res_today_arrival, 150.00, 'Online', 'Completed'),
(@res_today_departure, 360.00, 'Debit Card', 'Completed'),
(@res_future_pay_at_desk, 0.00, 'Cash', 'Pending');

-- =====================================================================================
-- 9) Now run the real workflow tests (check-in / check-out) -- EXPECTED to succeed
-- =====================================================================================

-- Test: Dashboard view before check-ins (arrivals: 1, departures: 0, occupied: 0)
SELECT * FROM vw_dashboard_today;

-- Perform check-in for multi-room reservation (Res 1) -> check in room 101 and 201
CALL PerformRoomCheckIn(@res_multi_room, @room_101);
CALL PerformRoomCheckIn(@res_multi_room, @room_201);

-- Check statuses
SELECT 'Res1 status' AS note, reservation_status FROM Reservations WHERE reservation_id = @res_multi_room;
SELECT 'Room101 status' AS note, current_status FROM Rooms WHERE room_id = @room_101;
SELECT 'Room201 status' AS note, current_status FROM Rooms WHERE room_id = @room_201;

-- Perform check-in for today's arrival (Res 2)
CALL PerformRoomCheckIn(@res_today_arrival, @room_102);
SELECT 'Res2 status' AS note, reservation_status FROM Reservations WHERE reservation_id = @res_today_arrival;
SELECT 'Room102 status' AS note, current_status FROM Rooms WHERE room_id = @room_102;

-- Simulate check-in and check-out for Res 3 (was Confirmed -> check-in -> check-out)
CALL PerformRoomCheckIn(@res_today_departure, @room_202);
SELECT 'Room202 status after check-in' AS note, current_status FROM Rooms WHERE room_id = @room_202;
CALL PerformRoomCheckOut(@res_today_departure, @room_202);
SELECT 'Room202 status after check-out' AS note, current_status FROM Rooms WHERE room_id = @room_202;
SELECT 'Res3 final status' AS note, reservation_status FROM Reservations WHERE reservation_id = @res_today_departure;

-- Now check dashboard (should reflect current reality)
SELECT * FROM vw_dashboard_today;

-- =====================================================================================
-- 10) Error tests (wrapped in transactions and ROLLBACK so they don't pollute data)
--     For each test we SHOW a comment with the expected outcome.
-- =====================================================================================

-- TEST A: Overlapping booking should fail (attempt to link Room 101 to a new reservation with overlapping dates)
START TRANSACTION;
-- create a new reservation that overlaps with @res_multi_room dates
INSERT INTO Reservations (customer_id, check_in_date, check_out_date, number_of_guests, reservation_status, total_price, pay_at_checkin, booking_source)
VALUES (@maria_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 2 DAY), 1, 'Confirmed', 200.00, FALSE, 'Website');
SET @bad_res = LAST_INSERT_ID();

-- Attempt to link the same room 101 which is already booked for overlapping dates.
-- EXPECTED: trigger trg_reservation_room_overlap_check will SIGNAL and this INSERT will fail.
-- The error should be similar to: "Room already booked for overlapping dates."
INSERT INTO Reservation_Rooms (reservation_id, room_id) VALUES (@bad_res, @room_101);
-- If for some reason it doesn't fail, we rollback anyway
ROLLBACK;
-- Expected outcome: the INSERT into Reservation_Rooms should have failed and ROLLBACKed.

-- TEST B: Payment less than total when pay_at_checkin = FALSE should fail on changing to Completed
START TRANSACTION;
-- Create a reservation that requires payment up front
INSERT INTO Reservations (customer_id, check_in_date, check_out_date, number_of_guests, reservation_status, total_price, pay_at_checkin, booking_source)
VALUES (@chen_id, DATE_ADD(CURDATE(), INTERVAL 10 DAY), DATE_ADD(CURDATE(), INTERVAL 12 DAY), 2, 'Confirmed', 500.00, FALSE, 'Website');
SET @paytest_res = LAST_INSERT_ID();

-- Insert a payment with amount less than total_price
INSERT INTO Payments (reservation_id, amount, payment_method, status) VALUES (@paytest_res, 100.00, 'Online', 'Pending');
SET @pay_id = LAST_INSERT_ID();

-- Try to move status to Completed (this will invoke trg_before_payment_complete on UPDATE)
-- EXPECTED: SIGNAL "Payment amount cannot be less than total reservation price."
UPDATE Payments SET status = 'Completed' WHERE payment_id = @pay_id;
ROLLBACK;
-- Expected outcome: UPDATE should have signaled and ROLLBACKed.

-- TEST C: Attempt to delete a Room_Type that has Rooms (should error due to trigger)
START TRANSACTION;
-- There are rooms linked to @king_type_id; delete should be blocked by trigger trg_room_type_delete_check
DELETE FROM Room_Types WHERE room_type_id = @king_type_id;
-- EXPECTED: SIGNAL 'Cannot delete Room Type: rooms exist.'
ROLLBACK;

-- TEST D: Deleting an employee that has Service_Executions (FK ON DELETE RESTRICT) should fail
-- First create a service and execution linked to Clara
START TRANSACTION;
INSERT INTO Services (service_name, description, is_active, available_from, available_to) VALUES
('Test Servicea', 'Temporary test', TRUE, '08:00:00', '20:00:00');
SET @test_service_id = LAST_INSERT_ID();

-- Link Clara as able to perform it
INSERT INTO Employee_Services (employee_id, service_id, can_be_scheduled) VALUES (@clara_id, @test_service_id, TRUE);

-- Create a reservation for the execution
INSERT INTO Reservations (customer_id, check_in_date, check_out_date, number_of_guests, reservation_status, total_price, pay_at_checkin, booking_source)
VALUES (@john_id, DATE_ADD(CURDATE(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 6 DAY), 1, 'Confirmed', 0.00, TRUE, 'Website');
SET @exec_res = LAST_INSERT_ID();

-- Link room to that reservation (use a vacant room)
INSERT INTO Reservation_Rooms (reservation_id, room_id) VALUES (@exec_res, @room_302);

-- Insert a service_execution (history)
INSERT INTO Service_Executions (reservation_id, service_id, employee_id, status, performed_at) VALUES
(@exec_res, @test_service_id, @clara_id, 'Scheduled', NULL);

-- Now attempt to delete Clara (employee)
DELETE FROM Employees WHERE employee_id = @clara_id;
-- EXPECTED: FK ON DELETE RESTRICT should prevent deleting Clara because Service_Executions references her
ROLLBACK;

-- TEST E: Attempt to create two Payments for same reservation (should fail due to UNIQUE)
START TRANSACTION;
-- Create a reservation that expects single payment
INSERT INTO Reservations (customer_id, check_in_date, check_out_date, number_of_guests, reservation_status, total_price, pay_at_checkin, booking_source)
VALUES (@maria_id, DATE_ADD(CURDATE(), INTERVAL 7 DAY), DATE_ADD(CURDATE(), INTERVAL 9 DAY), 2, 'Confirmed', 200.00, FALSE, 'Website');
SET @singlepay_res = LAST_INSERT_ID();

-- Insert first payment (ok)
INSERT INTO Payments (reservation_id, amount, payment_method, status) VALUES (@singlepay_res, 200.00, 'Online', 'Completed');

-- Try to insert a second payment -> EXPECTED: duplicate key error (unique constraint on reservation_id)
INSERT INTO Payments (reservation_id, amount, payment_method, status) VALUES (@singlepay_res, 0.00, 'Cash', 'Pending');
ROLLBACK;

-- =====================================================================================
-- 11) Final verification queries (clean, non-destructive)
-- =====================================================================================

-- How many active reservations:
SELECT COUNT(*) AS active_reservations FROM Reservations WHERE reservation_status IN ('Confirmed','Checked-in');

-- Current occupied rooms:
SELECT room_number, current_status
FROM Rooms
WHERE current_status = 'Occupied';

-- Sample of Service_Executions (if any)
SELECT * FROM Service_Executions LIMIT 50;

SELECT 'Population and error-tests completed' AS note;
