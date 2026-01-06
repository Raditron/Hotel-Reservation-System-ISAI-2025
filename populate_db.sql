
USE hotel_management_db1;

-- If re-running: clear in FK-safe order (won't touch Completed payments if you have them)
SET FOREIGN_KEY_CHECKS
= 0;
TRUNCATE TABLE Service_Executions;
TRUNCATE TABLE Reservation_Services;
TRUNCATE TABLE Reservation_Guests;
TRUNCATE TABLE Reservation_Rooms;
TRUNCATE TABLE Payments;
TRUNCATE TABLE Reservations;
TRUNCATE TABLE Employee_Services;
TRUNCATE TABLE Work_Records;
TRUNCATE TABLE Employee_Payroll;
TRUNCATE TABLE Employees;
TRUNCATE TABLE Rooms;
TRUNCATE TABLE Services;
TRUNCATE TABLE Customers;
TRUNCATE TABLE Room_Types;
TRUNCATE TABLE Roles;
SET FOREIGN_KEY_CHECKS
= 1;

-- ----------------------
-- Roles (6)
-- ----------------------
INSERT INTO Roles
    (role_name, description)
VALUES
    ('Manager', 'Oversees hotel operations'),
    ('Receptionist', 'Front desk / check-in / check-out'),
    ('Housekeeping', 'Room cleaning and preparation'),
    ('Maintenance', 'Repairs and maintenance'),
    ('Chef', 'Kitchen and food preparation'),
    ('Security', 'Security and monitoring');

-- ----------------------
-- Room Types (6)
-- ----------------------
INSERT INTO Room_Types
    (type_name, standard_price, capacity, bed_count, description, deposit_required)
VALUES
    ('Budget Single', 60.00, 1, 1, 'Small single room', 0.00),
    ('Standard Double', 120.00, 2, 1, 'Standard double room', 50.00),
    ('Deluxe Double', 180.00, 2, 1, 'Deluxe double room', 75.00),
    ('Family Room', 210.00, 4, 3, 'Family room', 60.00),
    ('Suite', 320.00, 3, 2, 'Suite with living area', 120.00),
    ('Business Twin', 140.00, 2, 2, 'Two-bed business room', 30.00);

-- ----------------------
-- Customers (10)
-- ----------------------
INSERT INTO Customers
    (first_name,last_name,national_id,date_of_birth,phone_number,email,country)
VALUES
    ('Ivan', 'Petrov', 'BG-C-1001', '1998-01-05', '+359888000101', 'ivan.petrov@example.com', 'Bulgaria'),
    ('Maria', 'Georgieva', 'BG-C-1002', '1999-03-12', '+359888000102', 'maria.georgieva@example.com', 'Bulgaria'),
    ('Georgi', 'Dimitrov', 'BG-C-1003', '1997-07-21', '+359888000103', 'georgi.dimitrov@example.com', 'Bulgaria'),
    ('Elena', 'Ivanova', 'BG-C-1004', '2000-11-02', '+359888000104', 'elena.ivanova@example.com', 'Bulgaria'),
    ('Nikolay', 'Stoyanov', 'BG-C-1005', '1996-09-30', '+359888000105', 'nikolay.stoyanov@example.com', 'Bulgaria'),
    ('Teodora', 'Koleva', 'BG-C-1006', '2001-06-18', '+359888000106', 'teodora.koleva@example.com', 'Bulgaria'),
    ('Martin', 'Vasilev', 'BG-C-1007', '1995-02-14', '+359888000107', 'martin.vasilev@example.com', 'Bulgaria'),
    ('Ani', 'Nikolova', 'BG-C-1008', '1994-12-25', '+359888000108', 'ani.nikolova@example.com', 'Bulgaria'),
    ('Petya', 'Todorova', 'BG-C-1009', '1993-10-10', '+359888000109', 'petya.todorova@example.com', 'Bulgaria'),
    ('Dimitar', 'Kostov', 'BG-C-1010', '1992-08-08', '+359888000110', 'dimitar.kostov@example.com', 'Bulgaria');

-- ----------------------
-- Services (8)
-- ----------------------
INSERT INTO Services
    (service_name, description, available_from, available_to)
VALUES
    ('Breakfast', 'Buffet breakfast', '06:30:00', '10:30:00'),
    ('Airport Shuttle', 'Transfer service', '00:00:00', '23:59:00'),
    ('Spa Access', 'Spa & sauna access', '10:00:00', '20:00:00'),
    ('Laundry', 'Laundry service', '08:00:00', '18:00:00'),
    ('Room Cleaning', 'Extra cleaning request', '09:00:00', '17:00:00'),
    ('Late Check-out', 'Late check-out', '00:00:00', '23:59:00'),
    ('Mini Bar Refill', 'Mini bar refill', '10:00:00', '22:00:00'),
    ('Room Service', 'Food delivery to room', '11:00:00', '23:00:00');

-- ----------------------
-- Employees (8)
-- ----------------------
INSERT INTO Employees
    (first_name,last_name,national_id,date_of_birth,phone_number,email,role_id,hire_date,base_pay_rate,status,notes)
SELECT 'Alice', 'Mihaylova', 'BG-E-2001', '1988-05-10', '+359899000201', 'alice.mihaylova@hotel.test', role_id, '2022-01-10', 2600.00, 'Active', 'Seed'
FROM Roles
WHERE role_name='Manager';

INSERT INTO Employees
    (first_name,last_name,national_id,date_of_birth,phone_number,email,role_id,hire_date,base_pay_rate,status,notes)
SELECT 'Boris', 'Ivanov', 'BG-E-2002', '1990-02-20', '+359899000202', 'boris.ivanov@hotel.test', role_id, '2022-02-15', 1800.00, 'Active', 'Seed'
FROM Roles
WHERE role_name='Receptionist';

INSERT INTO Employees
    (first_name,last_name,national_id,date_of_birth,phone_number,email,role_id,hire_date,base_pay_rate,status,notes)
SELECT 'Cvetelina', 'Petrova', 'BG-E-2003', '1992-09-01', '+359899000203', 'cvetelina.petrova@hotel.test', role_id, '2022-03-01', 1650.00, 'Active', 'Seed'
FROM Roles
WHERE role_name='Housekeeping';

INSERT INTO Employees
    (first_name,last_name,national_id,date_of_birth,phone_number,email,role_id,hire_date,base_pay_rate,status,notes)
SELECT 'Deyan', 'Kirilov', 'BG-E-2004', '1985-12-12', '+359899000204', 'deyan.kirilov@hotel.test', role_id, '2022-04-01', 2100.00, 'Active', 'Seed'
FROM Roles
WHERE role_name='Maintenance';

INSERT INTO Employees
    (first_name,last_name,national_id,date_of_birth,phone_number,email,role_id,hire_date,base_pay_rate,status,notes)
SELECT 'Emil', 'Stanchev', 'BG-E-2005', '1987-07-07', '+359899000205', 'emil.stanchev@hotel.test', role_id, '2022-05-01', 2400.00, 'Active', 'Seed'
FROM Roles
WHERE role_name='Chef';

INSERT INTO Employees
    (first_name,last_name,national_id,date_of_birth,phone_number,email,role_id,hire_date,base_pay_rate,status,notes)
SELECT 'Fani', 'Dobreva', 'BG-E-2006', '1991-03-03', '+359899000206', 'fani.dobreva@hotel.test', role_id, '2022-06-01', 1700.00, 'Active', 'Seed'
FROM Roles
WHERE role_name='Receptionist';

INSERT INTO Employees
    (first_name,last_name,national_id,date_of_birth,phone_number,email,role_id,hire_date,base_pay_rate,status,notes)
SELECT 'Galin', 'Radev', 'BG-E-2007', '1989-01-17', '+359899000207', 'galin.radev@hotel.test', role_id, '2022-07-01', 1750.00, 'Active', 'Seed'
FROM Roles
WHERE role_name='Security';

INSERT INTO Employees
    (first_name,last_name,national_id,date_of_birth,phone_number,email,role_id,hire_date,base_pay_rate,status,notes)
SELECT 'Hristo', 'Manolov', 'BG-E-2008', '1993-10-22', '+359899000208', 'hristo.manolov@hotel.test', role_id, '2022-08-01', 1600.00, 'Active', 'Seed'
FROM Roles
WHERE role_name='Housekeeping';

-- ----------------------
-- Work_Records (>=6) -> 12 rows (unique per employee+role+date)
-- ----------------------
INSERT INTO Work_Records
    (employee_id, role_id, work_date, hours_worked, overtime_hours, is_weekend, is_holiday, notes)
SELECT employee_id, role_id, DATE_SUB(CURDATE(), INTERVAL
3 DAY), 8.00, 0.00, 0, 0, 'Seed'
FROM Employees;

INSERT INTO Work_Records
    (employee_id, role_id, work_date, hours_worked, overtime_hours, is_weekend, is_holiday, notes)
SELECT employee_id, role_id, DATE_SUB(CURDATE(), INTERVAL
2 DAY), 8.00, 1.50, 0, 0, 'Seed'
FROM Employees
WHERE email IN
('boris.ivanov@hotel.test','cvetelina.petrova@hotel.test','deyan.kirilov@hotel.test','fani.dobreva@hotel.test');

-- ----------------------
-- Employee_Payroll (>=6) -> 8 rows
-- ----------------------
INSERT INTO Employee_Payroll
    (employee_id, role_id, pay_period_end_date, salary_type, base_rate, hours_worked, overtime_hours, overtime_rate, gross_pay, total_tax_deduction, net_pay)
SELECT employee_id, role_id, CURDATE(), 'Monthly', base_pay_rate, 0, 0, 0,
    base_pay_rate, base_pay_rate*0.20, base_pay_rate*0.80
FROM Employees;

-- ----------------------
-- Rooms (12)
-- ----------------------
INSERT INTO Rooms
    (room_number, room_type_id, current_status)
SELECT '101', room_type_id, 'Vacant'
FROM Room_Types
WHERE type_name='Budget Single';
INSERT INTO Rooms
    (room_number, room_type_id, current_status)
SELECT '102', room_type_id, 'Vacant'
FROM Room_Types
WHERE type_name='Budget Single';
INSERT INTO Rooms
    (room_number, room_type_id, current_status)
SELECT '103', room_type_id, 'Vacant'
FROM Room_Types
WHERE type_name='Standard Double';
INSERT INTO Rooms
    (room_number, room_type_id, current_status)
SELECT '104', room_type_id, 'Vacant'
FROM Room_Types
WHERE type_name='Standard Double';
INSERT INTO Rooms
    (room_number, room_type_id, current_status)
SELECT '201', room_type_id, 'Vacant'
FROM Room_Types
WHERE type_name='Deluxe Double';
INSERT INTO Rooms
    (room_number, room_type_id, current_status)
SELECT '202', room_type_id, 'Vacant'
FROM Room_Types
WHERE type_name='Deluxe Double';
INSERT INTO Rooms
    (room_number, room_type_id, current_status)
SELECT '301', room_type_id, 'Vacant'
FROM Room_Types
WHERE type_name='Family Room';
INSERT INTO Rooms
    (room_number, room_type_id, current_status)
SELECT '302', room_type_id, 'Vacant'
FROM Room_Types
WHERE type_name='Family Room';
INSERT INTO Rooms
    (room_number, room_type_id, current_status)
SELECT '401', room_type_id, 'Vacant'
FROM Room_Types
WHERE type_name='Suite';
INSERT INTO Rooms
    (room_number, room_type_id, current_status)
SELECT '402', room_type_id, 'Vacant'
FROM Room_Types
WHERE type_name='Suite';
INSERT INTO Rooms
    (room_number, room_type_id, current_status)
SELECT '501', room_type_id, 'Vacant'
FROM Room_Types
WHERE type_name='Business Twin';
INSERT INTO Rooms
    (room_number, room_type_id, current_status)
SELECT '502', room_type_id, 'Under Renovation'
FROM Room_Types
WHERE type_name='Business Twin';

-- ----------------------
-- Reservations (8) - must start Confirmed (your trigger enforces)
-- ----------------------
INSERT INTO Reservations
    (customer_id, check_in_date, check_out_date, number_of_guests, total_price, pay_at_checkin, booking_source, external_reference, special_requests, notes)
SELECT c.customer_id, DATE_ADD(CURDATE(), INTERVAL
10 DAY), DATE_ADD(CURDATE(), INTERVAL 12 DAY), 1, 300.00, 0, 'Website', NULL, 'High floor', 'SEED_R1'
FROM Customers c WHERE c.email='ivan.petrov@example.com';

INSERT INTO Reservations
    (customer_id, check_in_date, check_out_date, number_of_guests, total_price, pay_at_checkin, booking_source, external_reference, special_requests, notes)
SELECT c.customer_id, DATE_ADD(CURDATE(), INTERVAL
13 DAY), DATE_ADD(CURDATE(), INTERVAL 16 DAY), 2, 500.00, 1, 'Phone', NULL, NULL, 'SEED_R2'
FROM Customers c WHERE c.email='maria.georgieva@example.com';

INSERT INTO Reservations
    (customer_id, check_in_date, check_out_date, number_of_guests, total_price, pay_at_checkin, booking_source, external_reference, special_requests, notes)
SELECT c.customer_id, DATE_ADD(CURDATE(), INTERVAL
20 DAY), DATE_ADD(CURDATE(), INTERVAL 23 DAY), 2, 800.00, 0, 'Walk-in', NULL, 'Quiet room', 'SEED_R3'
FROM Customers c WHERE c.email='georgi.dimitrov@example.com';

INSERT INTO Reservations
    (customer_id, check_in_date, check_out_date, number_of_guests, total_price, pay_at_checkin, booking_source, external_reference, special_requests, notes)
SELECT c.customer_id, DATE_ADD(CURDATE(), INTERVAL
25 DAY), DATE_ADD(CURDATE(), INTERVAL 27 DAY), 4, 600.00, 0, 'Expedia', 'EXP-7788', NULL, 'SEED_R4'
FROM Customers c WHERE c.email='elena.ivanova@example.com';

INSERT INTO Reservations
    (customer_id, check_in_date, check_out_date, number_of_guests, total_price, pay_at_checkin, booking_source, external_reference, special_requests, notes)
SELECT c.customer_id, DATE_ADD(CURDATE(), INTERVAL
30 DAY), DATE_ADD(CURDATE(), INTERVAL 33 DAY), 1, 400.00, 1, 'Booking.com', 'BK-9191', NULL, 'SEED_R5'
FROM Customers c WHERE c.email='nikolay.stoyanov@example.com';

INSERT INTO Reservations
    (customer_id, check_in_date, check_out_date, number_of_guests, total_price, pay_at_checkin, booking_source, external_reference, special_requests, notes)
SELECT c.customer_id, DATE_ADD(CURDATE(), INTERVAL
35 DAY), DATE_ADD(CURDATE(), INTERVAL 37 DAY), 2, 450.00, 0, 'Airbnb', 'AB-1212', NULL, 'SEED_R6'
FROM Customers c WHERE c.email='teodora.koleva@example.com';

INSERT INTO Reservations
    (customer_id, check_in_date, check_out_date, number_of_guests, total_price, pay_at_checkin, booking_source, external_reference, special_requests, notes)
SELECT c.customer_id, DATE_ADD(CURDATE(), INTERVAL
40 DAY), DATE_ADD(CURDATE(), INTERVAL 42 DAY), 2, 550.00, 0, 'Corporate', 'CORP-33', NULL, 'SEED_R7'
FROM Customers c WHERE c.email='martin.vasilev@example.com';

INSERT INTO Reservations
    (customer_id, check_in_date, check_out_date, number_of_guests, total_price, pay_at_checkin, booking_source, external_reference, special_requests, notes)
SELECT c.customer_id, DATE_ADD(CURDATE(), INTERVAL
45 DAY), DATE_ADD(CURDATE(), INTERVAL 48 DAY), 3, 900.00, 0, 'Other', NULL, NULL, 'SEED_R8'
FROM Customers c WHERE c.email='ani.nikolova@example.com';

-- ----------------------
-- Reservation_Rooms (8) -> FIXED: no SELECT from Reservations in same statement
-- ----------------------
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
SET @r4 :=
(SELECT reservation_id
FROM Reservations
WHERE notes='SEED_R4');
SET @r5 :=
(SELECT reservation_id
FROM Reservations
WHERE notes='SEED_R5');
SET @r6 :=
(SELECT reservation_id
FROM Reservations
WHERE notes='SEED_R6');
SET @r7 :=
(SELECT reservation_id
FROM Reservations
WHERE notes='SEED_R7');
SET @r8 :=
(SELECT reservation_id
FROM Reservations
WHERE notes='SEED_R8');

SET @room101 :=
(SELECT room_id
FROM Rooms
WHERE room_number='101');
SET @room103 :=
(SELECT room_id
FROM Rooms
WHERE room_number='103');
SET @room201 :=
(SELECT room_id
FROM Rooms
WHERE room_number='201');
SET @room301 :=
(SELECT room_id
FROM Rooms
WHERE room_number='301');
SET @room104 :=
(SELECT room_id
FROM Rooms
WHERE room_number='104');
SET @room501 :=
(SELECT room_id
FROM Rooms
WHERE room_number='501');
SET @room202 :=
(SELECT room_id
FROM Rooms
WHERE room_number='202');
SET @room401 :=
(SELECT room_id
FROM Rooms
WHERE room_number='401');

INSERT INTO Reservation_Rooms
    (reservation_id, room_id)
VALUES
    (@r1, @room101),
    (@r2, @room103),
    (@r3, @room201),
    (@r4, @room301),
    (@r5, @room104),
    (@r6, @room501),
    (@r7, @room202),
    (@r8, @room401);

-- ----------------------
-- Reservation_Guests (>=6) -> 8 primary + extra guests (no duplicates)
-- ----------------------
INSERT INTO Reservation_Guests
    (reservation_id, customer_id, is_primary_booker)
SELECT reservation_id, customer_id, TRUE
FROM Reservations;

-- Add extra guests:
INSERT INTO Reservation_Guests
    (reservation_id, customer_id, is_primary_booker)
VALUES
    ((SELECT reservation_id
        FROM Reservations
        WHERE notes='SEED_R4'),
        (SELECT customer_id
        FROM Customers
        WHERE email='petya.todorova@example.com'),
        FALSE);

INSERT INTO Reservation_Guests
    (reservation_id, customer_id, is_primary_booker)
VALUES
    ((SELECT reservation_id
        FROM Reservations
        WHERE notes='SEED_R7'),
        (SELECT customer_id
        FROM Customers
        WHERE email='dimitar.kostov@example.com'),
        FALSE);

INSERT INTO Reservation_Guests
    (reservation_id, customer_id, is_primary_booker)
VALUES
    ((SELECT reservation_id
        FROM Reservations
        WHERE notes='SEED_R8'),
        (SELECT customer_id
        FROM Customers
        WHERE email='martin.vasilev@example.com'),
        FALSE);

-- ----------------------
-- Reservation_Services (>=6) -> 10 rows
-- (kept as-is; does not touch Reservations triggers)
-- ----------------------
INSERT INTO Reservation_Services
    (reservation_id, service_id, customer_id)
SELECT r.reservation_id, s.service_id, r.customer_id
FROM Reservations r JOIN Services s 
WHERE r.notes='SEED_R1' AND s.service_name IN ('Breakfast','Room Cleaning');

INSERT INTO Reservation_Services
    (reservation_id, service_id, customer_id)
SELECT r.reservation_id, s.service_id, r.customer_id
FROM Reservations r JOIN Services s 
WHERE r.notes='SEED_R2' AND s.service_name IN ('Airport Shuttle','Breakfast');

INSERT INTO Reservation_Services
    (reservation_id, service_id, customer_id)
SELECT r.reservation_id, s.service_id, r.customer_id
FROM Reservations r JOIN Services s 
WHERE r.notes='SEED_R3' AND s.service_name IN ('Spa Access','Mini Bar Refill');

INSERT INTO Reservation_Services
    (reservation_id, service_id, customer_id)
SELECT r.reservation_id, s.service_id, r.customer_id
FROM Reservations r JOIN Services s 
WHERE r.notes='SEED_R4' AND s.service_name IN ('Laundry','Late Check-out');

INSERT INTO Reservation_Services
    (reservation_id, service_id, customer_id)
SELECT r.reservation_id, s.service_id, r.customer_id
FROM Reservations r JOIN Services s 
WHERE r.notes='SEED_R5' AND s.service_name IN ('Room Service','Breakfast');

-- ----------------------
-- Employee_Services (>=6) -> 12 rows
-- ----------------------
INSERT INTO Employee_Services
    (employee_id, service_id)
SELECT e.employee_id, s.service_id
FROM Employees e JOIN Services s 
WHERE e.email='emil.stanchev@hotel.test' AND s.service_name IN ('Breakfast','Room Service');

INSERT INTO Employee_Services
    (employee_id, service_id)
SELECT e.employee_id, s.service_id
FROM Employees e JOIN Services s 
WHERE e.email='cvetelina.petrova@hotel.test' AND s.service_name IN ('Room Cleaning','Laundry','Mini Bar Refill');

INSERT INTO Employee_Services
    (employee_id, service_id)
SELECT e.employee_id, s.service_id
FROM Employees e JOIN Services s 
WHERE e.email='deyan.kirilov@hotel.test' AND s.service_name IN ('Airport Shuttle');

INSERT INTO Employee_Services
    (employee_id, service_id)
SELECT e.employee_id, s.service_id
FROM Employees e JOIN Services s 
WHERE e.email='boris.ivanov@hotel.test' AND s.service_name IN ('Late Check-out','Airport Shuttle');

INSERT INTO Employee_Services
    (employee_id, service_id)
SELECT e.employee_id, s.service_id
FROM Employees e JOIN Services s 
WHERE e.email='alice.mihaylova@hotel.test' AND s.service_name IN ('Spa Access');

INSERT INTO Employee_Services
    (employee_id, service_id)
SELECT e.employee_id, s.service_id
FROM Employees e JOIN Services s 
WHERE e.email='hristo.manolov@hotel.test' AND s.service_name IN ('Room Cleaning','Laundry');

-- ----------------------
-- Service_Executions (>=6)
-- ----------------------
INSERT INTO Service_Executions
    (reservation_id, service_id, employee_id, status, performed_at, notes)
SELECT r.reservation_id, s.service_id, e.employee_id, 'Scheduled', NULL, 'Seed'
FROM Reservations r
    JOIN Services s ON s.service_name='Breakfast'
    JOIN Employees e ON e.email='emil.stanchev@hotel.test'
WHERE r.notes='SEED_R1';

INSERT INTO Service_Executions
    (reservation_id, service_id, employee_id, status, performed_at, notes)
SELECT r.reservation_id, s.service_id, e.employee_id, 'Completed', NOW(), 'Seed'
FROM Reservations r
    JOIN Services s ON s.service_name='Room Cleaning'
    JOIN Employees e ON e.email='cvetelina.petrova@hotel.test'
WHERE r.notes='SEED_R1';

INSERT INTO Service_Executions
    (reservation_id, service_id, employee_id, status, performed_at, notes)
SELECT r.reservation_id, s.service_id, e.employee_id, 'Scheduled', NULL, 'Seed'
FROM Reservations r
    JOIN Services s ON s.service_name='Airport Shuttle'
    JOIN Employees e ON e.email='boris.ivanov@hotel.test'
WHERE r.notes='SEED_R2';

INSERT INTO Service_Executions
    (reservation_id, service_id, employee_id, status, performed_at, notes)
SELECT r.reservation_id, s.service_id, e.employee_id, 'Scheduled', NULL, 'Seed'
FROM Reservations r
    JOIN Services s ON s.service_name='Spa Access'
    JOIN Employees e ON e.email='alice.mihaylova@hotel.test'
WHERE r.notes='SEED_R3';

INSERT INTO Service_Executions
    (reservation_id, service_id, employee_id, status, performed_at, notes)
SELECT r.reservation_id, s.service_id, e.employee_id, 'In Progress', NULL, 'Seed'
FROM Reservations r
    JOIN Services s ON s.service_name='Laundry'
    JOIN Employees e ON e.email='hristo.manolov@hotel.test'
WHERE r.notes='SEED_R4';

INSERT INTO Service_Executions
    (reservation_id, service_id, employee_id, status, performed_at, notes)
SELECT r.reservation_id, s.service_id, e.employee_id, 'Scheduled', NULL, 'Seed'
FROM Reservations r
    JOIN Services s ON s.service_name='Room Service'
    JOIN Employees e ON e.email='emil.stanchev@hotel.test'
WHERE r.notes='SEED_R5';

-- ----------------------
-- Payments (>=6) obeying your triggers
-- ----------------------

-- R1: deposit=0 => only Completed Final == total_price
INSERT INTO Payments
    (reservation_id, payment_type, amount, payment_method, status, notes)
SELECT reservation_id, 'Final', total_price, 'Online', 'Completed', 'Seed full upfront'
FROM Reservations
WHERE notes='SEED_R1';

-- R2: deposit>0 => Completed Deposit + Completed Final remainder
INSERT INTO Payments
    (reservation_id, payment_type, amount, payment_method, status, notes)
SELECT reservation_id, 'Deposit', deposit_amount, 'Cash', 'Completed', 'Seed deposit'
FROM Reservations
WHERE notes='SEED_R2';

INSERT INTO Payments
    (reservation_id, payment_type, amount, payment_method, status, notes)
SELECT reservation_id, 'Final', (total_price - deposit_amount), 'Credit Card', 'Completed', 'Seed final remainder'
FROM Reservations
WHERE notes='SEED_R2';

-- R3: deposit>0 => Deposit-only completed allowed
INSERT INTO Payments
    (reservation_id, payment_type, amount, payment_method, status, notes)
SELECT reservation_id, 'Deposit', deposit_amount, 'Debit Card', 'Completed', 'Seed deposit only'
FROM Reservations
WHERE notes='SEED_R3';

-- R4: deposit>0 but no deposit completed => full upfront Final Completed allowed
INSERT INTO Payments
    (reservation_id, payment_type, amount, payment_method, status, notes)
SELECT reservation_id, 'Final', total_price, 'Bank Transfer', 'Completed', 'Seed full upfront'
FROM Reservations
WHERE notes='SEED_R4';

-- R5: pending payment (allowed) -> gives 6th payment row
INSERT INTO Payments
    (reservation_id, payment_type, amount, payment_method, status, notes)
SELECT reservation_id, 'Final', total_price, 'Online', 'Pending', 'Seed pending'
FROM Reservations
WHERE notes='SEED_R5';

-- ----------------------
-- Counts: every table must be > 5
-- ----------------------
SELECT 
    'Roles' tbl, COUNT(*) cnt
FROM
    Roles 
UNION ALL SELECT 
    'Room_Types', COUNT(*)
FROM
    Room_Types 
UNION ALL SELECT 
    'Customers', COUNT(*)
FROM
    Customers 
UNION ALL SELECT 
    'Services', COUNT(*)
FROM
    Services 
UNION ALL SELECT 
    'Employees', COUNT(*)
FROM
    Employees 
UNION ALL SELECT 
    'Work_Records', COUNT(*)
FROM
    Work_Records 
UNION ALL SELECT 
    'Employee_Payroll', COUNT(*)
FROM
    Employee_Payroll 
UNION ALL SELECT 
    'Rooms', COUNT(*)
FROM
    Rooms 
UNION ALL SELECT 
    'Reservations', COUNT(*)
FROM
    Reservations 
UNION ALL SELECT 
    'Payments', COUNT(*)
FROM
    Payments 
UNION ALL SELECT 
    'Reservation_Guests', COUNT(*)
FROM
    Reservation_Guests 
UNION ALL SELECT 
    'Reservation_Rooms', COUNT(*)
FROM
    Reservation_Rooms 
UNION ALL SELECT 
    'Reservation_Services', COUNT(*)
FROM
    Reservation_Services 
UNION ALL SELECT 
    'Employee_Services', COUNT(*)
FROM
    Employee_Services 
UNION ALL SELECT 
    'Service_Executions', COUNT(*)
FROM
    Service_Executions;

-- Proof deposit trigger works: stored vs computed
SELECT 
    r.reservation_id,
    r.notes,
    r.deposit_amount AS stored_deposit,
    (SELECT 
            IFNULL(SUM(rt.deposit_required), 0.00)
        FROM
            Reservation_Rooms rr
                JOIN
            Rooms rm ON rm.room_id = rr.room_id
                JOIN
            Room_Types rt ON rt.room_type_id = rm.room_type_id
        WHERE
            rr.reservation_id = r.reservation_id) AS expected_deposit
FROM
    Reservations r
ORDER BY r.reservation_id;
