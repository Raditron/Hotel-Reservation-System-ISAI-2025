-- ============================================================
-- Hotel Management DB (MySQL) - Deposit + Final Payments
-- Rules:
--   - Reservation can exist with 0 payments.
--   - Full payment is REQUIRED BEFORE check-in (no exceptions).
--   - Payments allowed (max 1 Deposit + max 1 Final due to UNIQUE):
--       A) 1 payment: Final = total_price (full upfront)
--       B) 2 payments: Deposit = deposit_amount, then Final = total_price - deposit_amount
--       C) Deposit-only is allowed (but cannot check in yet)
--   - deposit_amount is computed from assigned rooms:
--       SUM(Room_Types.deposit_required) per room assigned to reservation
--   - Rooms cannot be modified after any Completed payment exists.
-- ============================================================

DROP DATABASE IF EXISTS hotel_management_db1;
CREATE DATABASE hotel_management_db1 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hotel_management_db1;

-- ======================
-- Core Reference Tables
-- ======================

CREATE TABLE Roles (
    role_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Room_Types (
    room_type_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    standard_price DECIMAL(8,2) NOT NULL CHECK (standard_price >= 0),
    capacity TINYINT UNSIGNED NOT NULL CHECK (capacity >= 1 AND capacity <= 10),
    bed_count TINYINT UNSIGNED NOT NULL CHECK (bed_count >= 1 AND bed_count <= 8),
    description TEXT NOT NULL,

    -- Deposit required for this room type (per room)
    deposit_required DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (deposit_required >= 0),

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Customers (
    customer_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    national_id VARCHAR(20) UNIQUE,
    date_of_birth DATE,
    phone_number VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    country VARCHAR(50),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    deleted_at DATETIME NULL DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Services (
    service_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    available_from TIME NOT NULL,
    available_to TIME NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_service_time CHECK (available_to > available_from)
);

-- ======================
-- Employees & HR Tables
-- ======================

CREATE TABLE Employees (
    employee_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    national_id VARCHAR(20) NOT NULL UNIQUE,
    date_of_birth DATE NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    role_id INT UNSIGNED NOT NULL,
    hire_date DATE NOT NULL,
    base_pay_rate DECIMAL(10,2) NOT NULL CHECK (base_pay_rate >= 0),
    status ENUM('Active', 'On Leave', 'Resigned') NOT NULL DEFAULT 'Active',
    deleted_at DATETIME NULL DEFAULT NULL,
    notes TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_employee_role FOREIGN KEY (role_id) REFERENCES Roles(role_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Work_Records (
    work_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id INT UNSIGNED NOT NULL,
    role_id INT UNSIGNED NOT NULL,
    work_date DATE NOT NULL,
    hours_worked DECIMAL(5,2) NOT NULL DEFAULT 0.00 CHECK (hours_worked >= 0),
    overtime_hours DECIMAL(5,2) NOT NULL DEFAULT 0.00 CHECK (overtime_hours >= 0),
    is_weekend BOOLEAN NOT NULL DEFAULT FALSE,
    is_holiday BOOLEAN NOT NULL DEFAULT FALSE,
    notes TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_work_employee FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_work_role FOREIGN KEY (role_id) REFERENCES Roles(role_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT unique_work_record UNIQUE (employee_id, role_id, work_date)
);

CREATE TABLE Employee_Payroll (
    payroll_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id INT UNSIGNED NOT NULL,
    role_id INT UNSIGNED NOT NULL,
    pay_period_end_date DATE NOT NULL,
    salary_type ENUM('Hourly', 'Monthly') NOT NULL,
    base_rate DECIMAL(10,2) NOT NULL CHECK (base_rate >= 0),
    hours_worked DECIMAL(6,2) NOT NULL DEFAULT 0.00 CHECK (hours_worked >= 0),
    overtime_hours DECIMAL(5,2) NOT NULL DEFAULT 0.00 CHECK (overtime_hours >= 0),
    overtime_rate DECIMAL(10,2) NOT NULL CHECK (overtime_rate >= 0),
    gross_pay DECIMAL(10,2) NOT NULL CHECK (gross_pay >= 0),
    total_tax_deduction DECIMAL(10,2) NOT NULL CHECK (total_tax_deduction >= 0),
    net_pay DECIMAL(10,2) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_payroll_employee FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_payroll_role FOREIGN KEY (role_id) REFERENCES Roles(role_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT unique_payroll_period UNIQUE (employee_id, pay_period_end_date)
);

-- ======================
-- Rooms & Reservations
-- ======================

CREATE TABLE Rooms (
    room_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    room_type_id INT UNSIGNED NOT NULL,
    current_status ENUM('Vacant', 'Occupied', 'Cleaning', 'Maintenance', 'Not Available', 'Under Renovation')
        NOT NULL DEFAULT 'Vacant',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_room_type FOREIGN KEY (room_type_id) REFERENCES Room_Types(room_type_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Reservations (
    reservation_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id INT UNSIGNED NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    number_of_guests TINYINT UNSIGNED NOT NULL CHECK (number_of_guests >= 1 AND number_of_guests <= 10),
    reservation_status ENUM('Confirmed', 'Checked-in', 'Checked-out', 'Cancelled') NOT NULL DEFAULT 'Confirmed',

    -- Must be > 0
    total_price DECIMAL(10,2) NOT NULL CHECK (total_price > 0),

    -- Whether customer may pay at check-in (still requires FULL payment before check-in)
    pay_at_checkin BOOLEAN NOT NULL DEFAULT FALSE,

    -- Computed from rooms (sum of Room_Types.deposit_required)
    deposit_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (deposit_amount >= 0),

    booking_source ENUM('Walk-in','Website','Phone','Booking.com','Expedia','Airbnb','Travel Agent','Corporate','Other')
        NOT NULL DEFAULT 'Walk-in',
    external_reference VARCHAR(50) NULL,
    special_requests TEXT,
    notes TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_reservation_customer FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_dates CHECK (check_out_date > check_in_date),
    CONSTRAINT chk_deposit_not_over_total CHECK (deposit_amount <= total_price)
);

-- ======================
-- Payments
-- ======================

CREATE TABLE Payments (
    payment_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT UNSIGNED NOT NULL,
    payment_type ENUM('Deposit','Final') NOT NULL DEFAULT 'Final',
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Bank Transfer', 'Online') NOT NULL,
    status ENUM('Pending', 'Completed', 'Cancelled', 'Refunded') NOT NULL DEFAULT 'Pending',
    notes TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_payment_reservation FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT uq_payment_type_per_res UNIQUE (reservation_id, payment_type)
);

-- ======================
-- Linking Tables
-- ======================

CREATE TABLE Reservation_Guests (
    res_guest_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT UNSIGNED NOT NULL,
    customer_id INT UNSIGNED NOT NULL,
    is_primary_booker BOOLEAN NOT NULL DEFAULT FALSE,
    added_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_resguest_reservation FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_resguest_customer FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT unique_res_guest UNIQUE (reservation_id, customer_id)
);

CREATE TABLE Reservation_Rooms (
    res_room_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT UNSIGNED NOT NULL,
    room_id INT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_resroom_reservation FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_resroom_room FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT unique_room_reservation UNIQUE (room_id, reservation_id)
);

CREATE TABLE Reservation_Services (
    reservation_service_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT UNSIGNED NOT NULL,
    service_id INT UNSIGNED NOT NULL,
    customer_id INT UNSIGNED NULL,
    added_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_resservice_reservation FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_resservice_service FOREIGN KEY (service_id) REFERENCES Services(service_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_resservice_customer FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
        ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE Employee_Services (
    emp_service_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id INT UNSIGNED NOT NULL,
    service_id INT UNSIGNED NOT NULL,
    can_be_scheduled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_empservice_employee FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_empservice_service FOREIGN KEY (service_id) REFERENCES Services(service_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT unique_emp_service UNIQUE (employee_id, service_id)
);

CREATE TABLE Service_Executions (
    execution_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT UNSIGNED NOT NULL,
    service_id INT UNSIGNED NOT NULL,
    employee_id INT UNSIGNED NOT NULL,
    status ENUM('Scheduled','In Progress','Completed','Cancelled') NOT NULL DEFAULT 'Scheduled',
    performed_at DATETIME NULL,
    notes TEXT,
    CONSTRAINT fk_exec_reservation FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_exec_service FOREIGN KEY (service_id) REFERENCES Services(service_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_exec_employee FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
        ON DELETE RESTRICT
);

-- ======================
-- Indexes
-- ======================

CREATE INDEX idx_customer_name_active ON Customers(last_name, first_name, deleted_at);
CREATE INDEX idx_customer_phone ON Customers(phone_number);
CREATE INDEX idx_customer_national_id ON Customers(national_id);

CREATE INDEX idx_reservation_dates_status ON Reservations(reservation_status, check_in_date, check_out_date);
CREATE INDEX idx_res_booking_source ON Reservations(booking_source);

CREATE INDEX idx_room_status_type ON Rooms(current_status, room_type_id);

CREATE INDEX idx_resroom_room_dates ON Reservation_Rooms(room_id, reservation_id);
CREATE INDEX idx_resroom_reservation ON Reservation_Rooms(reservation_id);

CREATE INDEX idx_employee_role_status ON Employees(role_id, status);
CREATE INDEX idx_employee_deleted ON Employees(deleted_at);

CREATE INDEX idx_payments_res_status_type ON Payments(reservation_id, status, payment_type);

CREATE INDEX idx_resguest_reservation ON Reservation_Guests(reservation_id);
CREATE INDEX idx_resservice_reservation ON Reservation_Services(reservation_id);

-- ======================
-- Triggers
-- ======================

DELIMITER //

CREATE TRIGGER trg_reservations_before_insert_guardrails
BEFORE INSERT ON Reservations
FOR EACH ROW
BEGIN
    IF NEW.reservation_status <> 'Confirmed' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'New reservations must start as Confirmed.';
    END IF;
END//

CREATE TRIGGER trg_res_rooms_after_insert_recalc_deposit
AFTER INSERT ON Reservation_Rooms
FOR EACH ROW
BEGIN
    UPDATE Reservations r
    SET r.deposit_amount = (
        SELECT IFNULL(SUM(rt.deposit_required), 0.00)
        FROM Reservation_Rooms rr
        JOIN Rooms rm ON rm.room_id = rr.room_id
        JOIN Room_Types rt ON rt.room_type_id = rm.room_type_id
        WHERE rr.reservation_id = NEW.reservation_id
    ),
    r.updated_at = CURRENT_TIMESTAMP
    WHERE r.reservation_id = NEW.reservation_id;
END//

CREATE TRIGGER trg_res_rooms_after_delete_recalc_deposit
AFTER DELETE ON Reservation_Rooms
FOR EACH ROW
BEGIN
    UPDATE Reservations r
    SET r.deposit_amount = (
        SELECT IFNULL(SUM(rt.deposit_required), 0.00)
        FROM Reservation_Rooms rr
        JOIN Rooms rm ON rm.room_id = rr.room_id
        JOIN Room_Types rt ON rt.room_type_id = rm.room_type_id
        WHERE rr.reservation_id = OLD.reservation_id
    ),
    r.updated_at = CURRENT_TIMESTAMP
    WHERE r.reservation_id = OLD.reservation_id;
END//

CREATE TRIGGER trg_res_rooms_after_update_recalc_deposit
AFTER UPDATE ON Reservation_Rooms
FOR EACH ROW
BEGIN
    IF OLD.reservation_id <> NEW.reservation_id THEN
        UPDATE Reservations r
        SET r.deposit_amount = (
            SELECT IFNULL(SUM(rt.deposit_required), 0.00)
            FROM Reservation_Rooms rr
            JOIN Rooms rm ON rm.room_id = rr.room_id
            JOIN Room_Types rt ON rt.room_type_id = rm.room_type_id
            WHERE rr.reservation_id = OLD.reservation_id
        ),
        r.updated_at = CURRENT_TIMESTAMP
        WHERE r.reservation_id = OLD.reservation_id;
    END IF;

    UPDATE Reservations r
    SET r.deposit_amount = (
        SELECT IFNULL(SUM(rt.deposit_required), 0.00)
        FROM Reservation_Rooms rr
        JOIN Rooms rm ON rm.room_id = rr.room_id
        JOIN Room_Types rt ON rt.room_type_id = rm.room_type_id
        WHERE rr.reservation_id = NEW.reservation_id
    ),
    r.updated_at = CURRENT_TIMESTAMP
    WHERE r.reservation_id = NEW.reservation_id;
END//

CREATE TRIGGER trg_res_rooms_before_insert
BEFORE INSERT ON Reservation_Rooms
FOR EACH ROW
BEGIN
    DECLARE new_in DATE;
    DECLARE new_out DATE;
    DECLARE room_stat VARCHAR(30);

    IF EXISTS (
        SELECT 1 FROM Payments
        WHERE reservation_id = NEW.reservation_id AND status = 'Completed'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot modify reserved rooms after a completed payment exists.';
    END IF;

    SELECT current_status INTO room_stat
    FROM Rooms WHERE room_id = NEW.room_id;

    IF room_stat IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Room not found.';
    END IF;

    IF room_stat IN ('Not Available', 'Under Renovation') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot book room: Room is unavailable or under renovation.';
    END IF;

    SELECT check_in_date, check_out_date INTO new_in, new_out
    FROM Reservations WHERE reservation_id = NEW.reservation_id;

    IF new_in IS NULL OR new_out IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Reservation not found or missing dates.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM Reservation_Rooms rr
        JOIN Reservations r ON rr.reservation_id = r.reservation_id
        WHERE rr.room_id = NEW.room_id
          AND r.reservation_status IN ('Confirmed', 'Checked-in')
          AND new_in < r.check_out_date
          AND new_out > r.check_in_date
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Room already booked for overlapping dates.';
    END IF;
END//

CREATE TRIGGER trg_res_rooms_before_update
BEFORE UPDATE ON Reservation_Rooms
FOR EACH ROW
BEGIN
    DECLARE new_in DATE;
    DECLARE new_out DATE;
    DECLARE room_stat VARCHAR(30);

    IF EXISTS (
        SELECT 1 FROM Payments
        WHERE reservation_id = OLD.reservation_id AND status = 'Completed'
    ) OR EXISTS (
        SELECT 1 FROM Payments
        WHERE reservation_id = NEW.reservation_id AND status = 'Completed'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot modify reserved rooms after a completed payment exists.';
    END IF;

    SELECT current_status INTO room_stat
    FROM Rooms WHERE room_id = NEW.room_id;

    IF room_stat IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Room not found.';
    END IF;

    IF room_stat IN ('Not Available', 'Under Renovation') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot book room: Room is unavailable or under renovation.';
    END IF;

    SELECT check_in_date, check_out_date INTO new_in, new_out
    FROM Reservations WHERE reservation_id = NEW.reservation_id;

    IF new_in IS NULL OR new_out IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Reservation not found or missing dates.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM Reservation_Rooms rr
        JOIN Reservations r ON rr.reservation_id = r.reservation_id
        WHERE rr.room_id = NEW.room_id
          AND rr.res_room_id <> OLD.res_room_id
          AND r.reservation_status IN ('Confirmed', 'Checked-in')
          AND new_in < r.check_out_date
          AND new_out > r.check_in_date
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Room already booked for overlapping dates.';
    END IF;
END//

CREATE TRIGGER trg_res_rooms_before_delete
BEFORE DELETE ON Reservation_Rooms
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM Payments
        WHERE reservation_id = OLD.reservation_id AND status = 'Completed'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot modify reserved rooms after a completed payment exists.';
    END IF;
END//

CREATE TRIGGER trg_room_type_delete_check
BEFORE DELETE ON Room_Types
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM Rooms WHERE room_type_id = OLD.room_type_id) > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete Room Type: rooms exist.';
    END IF;
END//

CREATE TRIGGER trg_reservations_guardrails
BEFORE UPDATE ON Reservations
FOR EACH ROW
BEGIN
    DECLARE v_paid DECIMAL(10,2);

    IF NEW.reservation_status <> OLD.reservation_status THEN
        IF OLD.reservation_status = 'Cancelled' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Cancelled reservations cannot change status.';
        END IF;

        IF OLD.reservation_status = 'Checked-out' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Checked-out reservations cannot change status.';
        END IF;

        IF OLD.reservation_status = 'Confirmed' THEN
            IF NEW.reservation_status NOT IN ('Checked-in', 'Cancelled') THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Invalid status transition from Confirmed.';
            END IF;
        END IF;

        IF OLD.reservation_status = 'Checked-in' THEN
            IF NEW.reservation_status <> 'Checked-out' THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Invalid status transition from Checked-in.';
            END IF;
        END IF;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM Payments
        WHERE reservation_id = OLD.reservation_id
          AND status = 'Completed'
    ) THEN
        IF NEW.total_price <> OLD.total_price THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'total_price cannot change after a Completed payment exists.';
        END IF;

        IF NEW.check_in_date <> OLD.check_in_date OR NEW.check_out_date <> OLD.check_out_date THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Reservation dates cannot change after a Completed payment exists.';
        END IF;
    END IF;

    IF NEW.reservation_status = 'Checked-in'
       AND OLD.reservation_status <> 'Checked-in' THEN

        SELECT IFNULL(SUM(amount), 0.00) INTO v_paid
        FROM Payments
        WHERE reservation_id = NEW.reservation_id
          AND status = 'Completed';

        IF v_paid <> NEW.total_price THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Cannot check in unless Completed payments equal total_price.';
        END IF;
    END IF;
END//

CREATE TRIGGER trg_res_guests_single_primary_ins
BEFORE INSERT ON Reservation_Guests
FOR EACH ROW
BEGIN
    IF NEW.is_primary_booker = TRUE THEN
        IF EXISTS (
            SELECT 1
            FROM Reservation_Guests
            WHERE reservation_id = NEW.reservation_id
              AND is_primary_booker = TRUE
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Only one primary guest is allowed per reservation.';
        END IF;
    END IF;
END//

CREATE TRIGGER trg_res_guests_single_primary_upd
BEFORE UPDATE ON Reservation_Guests
FOR EACH ROW
BEGIN
    IF NEW.is_primary_booker = TRUE THEN
        IF EXISTS (
            SELECT 1
            FROM Reservation_Guests
            WHERE reservation_id = NEW.reservation_id
              AND is_primary_booker = TRUE
              AND res_guest_id <> OLD.res_guest_id
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Only one primary guest is allowed per reservation.';
        END IF;
    END IF;
END//

CREATE TRIGGER trg_payments_validate_ins
BEFORE INSERT ON Payments
FOR EACH ROW
BEGIN
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_deposit DECIMAL(10,2);
    DECLARE v_completed_sum DECIMAL(10,2);
    DECLARE v_dep_completed INT DEFAULT 0;
    DECLARE v_room_count INT DEFAULT 0;

    SELECT total_price, deposit_amount INTO v_total, v_deposit
    FROM Reservations
    WHERE reservation_id = NEW.reservation_id;

    IF v_total IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Reservation for payment not found.';
    END IF;

    IF NEW.amount > v_total THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment amount cannot exceed total reservation price.';
    END IF;

    IF NEW.payment_type = 'Deposit' AND v_deposit = 0.00 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Deposit payment not allowed: reservation has no deposit.';
    END IF;

    IF NEW.status = 'Completed' THEN
        SELECT COUNT(*) INTO v_room_count
        FROM Reservation_Rooms
        WHERE reservation_id = NEW.reservation_id;

        IF v_room_count = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Cannot complete a payment before assigning at least one room.';
        END IF;

        SELECT IFNULL(SUM(amount), 0.00) INTO v_completed_sum
        FROM Payments
        WHERE reservation_id = NEW.reservation_id AND status = 'Completed';

        IF (v_completed_sum + NEW.amount) > v_total THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Completed payments cannot exceed total reservation price.';
        END IF;

        SELECT COUNT(*) INTO v_dep_completed
        FROM Payments
        WHERE reservation_id = NEW.reservation_id
          AND payment_type = 'Deposit'
          AND status = 'Completed';

        IF v_deposit = 0.00 THEN
            IF NEW.payment_type <> 'Final' OR NEW.amount <> v_total THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'When deposit is 0, only a Completed Final equal to total_price is allowed.';
            END IF;
        ELSE
            IF NEW.payment_type = 'Deposit' THEN
                IF NEW.amount <> v_deposit THEN
                    SIGNAL SQLSTATE '45000'
                        SET MESSAGE_TEXT = 'Deposit payment must equal deposit_amount.';
                END IF;
            ELSE
                IF v_dep_completed > 0 THEN
                    IF NEW.amount <> (v_total - v_deposit) THEN
                        SIGNAL SQLSTATE '45000'
                            SET MESSAGE_TEXT = 'Final payment must equal (total_price - deposit_amount) after a Deposit is completed.';
                    END IF;
                    IF (v_completed_sum + NEW.amount) <> v_total THEN
                        SIGNAL SQLSTATE '45000'
                            SET MESSAGE_TEXT = 'Deposit + Final must sum exactly to total price.';
                    END IF;
                ELSE
                    IF NEW.amount <> v_total THEN
                        SIGNAL SQLSTATE '45000'
                            SET MESSAGE_TEXT = 'If no Deposit is completed, Final must be the full total_price.';
                    END IF;
                    IF (v_completed_sum + NEW.amount) <> v_total THEN
                        SIGNAL SQLSTATE '45000'
                            SET MESSAGE_TEXT = 'Completed payments must sum exactly to total price when Final is completed.';
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
END//

CREATE TRIGGER trg_payments_validate_upd
BEFORE UPDATE ON Payments
FOR EACH ROW
BEGIN
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_deposit DECIMAL(10,2);
    DECLARE v_completed_sum_others DECIMAL(10,2);
    DECLARE v_dep_completed_others INT DEFAULT 0;
    DECLARE v_room_count INT DEFAULT 0;

    IF OLD.status = 'Completed' THEN
        IF NEW.status <> OLD.status
           OR NEW.amount <> OLD.amount
           OR NEW.payment_type <> OLD.payment_type
           OR NEW.reservation_id <> OLD.reservation_id
           OR NEW.payment_method <> OLD.payment_method THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Completed payments cannot be modified.';
        END IF;
    END IF;

    SELECT total_price, deposit_amount INTO v_total, v_deposit
    FROM Reservations
    WHERE reservation_id = NEW.reservation_id;

    IF v_total IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Reservation for payment not found.';
    END IF;

    IF NEW.amount > v_total THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment amount cannot exceed total reservation price.';
    END IF;

    IF NEW.payment_type = 'Deposit' AND v_deposit = 0.00 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Deposit payment not allowed: reservation has no deposit.';
    END IF;

    SELECT IFNULL(SUM(amount), 0.00) INTO v_completed_sum_others
    FROM Payments
    WHERE reservation_id = NEW.reservation_id
      AND status = 'Completed'
      AND payment_id <> OLD.payment_id;

    SELECT COUNT(*) INTO v_dep_completed_others
    FROM Payments
    WHERE reservation_id = NEW.reservation_id
      AND payment_type = 'Deposit'
      AND status = 'Completed'
      AND payment_id <> OLD.payment_id;

    IF NEW.status = 'Completed' THEN
        SELECT COUNT(*) INTO v_room_count
        FROM Reservation_Rooms
        WHERE reservation_id = NEW.reservation_id;

        IF v_room_count = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Cannot complete a payment before assigning at least one room.';
        END IF;

        IF (v_completed_sum_others + NEW.amount) > v_total THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Completed payments cannot exceed total reservation price.';
        END IF;

        IF v_deposit = 0.00 THEN
            IF NEW.payment_type <> 'Final' OR NEW.amount <> v_total THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'When deposit is 0, only a Completed Final equal to total_price is allowed.';
            END IF;
        ELSE
            IF NEW.payment_type = 'Deposit' THEN
                IF NEW.amount <> v_deposit THEN
                    SIGNAL SQLSTATE '45000'
                        SET MESSAGE_TEXT = 'Deposit payment must equal deposit_amount.';
                END IF;
            ELSE
                IF v_dep_completed_others > 0 THEN
                    IF NEW.amount <> (v_total - v_deposit) THEN
                        SIGNAL SQLSTATE '45000'
                            SET MESSAGE_TEXT = 'Final payment must equal (total_price - deposit_amount) after a Deposit is completed.';
                    END IF;
                    IF (v_completed_sum_others + NEW.amount) <> v_total THEN
                        SIGNAL SQLSTATE '45000'
                            SET MESSAGE_TEXT = 'Deposit + Final must sum exactly to total price.';
                    END IF;
                ELSE
                    IF NEW.amount <> v_total THEN
                        SIGNAL SQLSTATE '45000'
                            SET MESSAGE_TEXT = 'If no Deposit is completed, Final must be the full total_price.';
                    END IF;
                    IF (v_completed_sum_others + NEW.amount) <> v_total THEN
                        SIGNAL SQLSTATE '45000'
                            SET MESSAGE_TEXT = 'Completed payments must sum exactly to total price when Final is completed.';
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
END//

CREATE TRIGGER trg_payments_block_delete_completed
BEFORE DELETE ON Payments
FOR EACH ROW
BEGIN
    IF OLD.status = 'Completed' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Completed payments cannot be deleted.';
    END IF;
END//

DELIMITER ;

-- ======================
-- Stored Procedures
-- ======================

DELIMITER //

CREATE PROCEDURE PerformRoomCheckIn(
    IN p_reservation_id INT UNSIGNED,
    IN p_room_id INT UNSIGNED
)
BEGIN
    DECLARE v_res_status VARCHAR(20);
    DECLARE v_total_price DECIMAL(10,2);
    DECLARE v_total_paid DECIMAL(10,2);
    DECLARE v_room_is_linked INT DEFAULT 0;
    DECLARE v_in DATE;
    DECLARE v_out DATE;

    SELECT reservation_status, total_price, check_in_date, check_out_date
      INTO v_res_status, v_total_price, v_in, v_out
    FROM Reservations
    WHERE reservation_id = p_reservation_id;

    IF v_res_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Reservation not found.';
    END IF;

    IF v_res_status <> 'Confirmed' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Reservation must be Confirmed to check in.';
    END IF;

    IF CURDATE() < v_in OR CURDATE() >= v_out THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Check-in date is outside the reservation period.';
    END IF;

    SELECT COUNT(*) INTO v_room_is_linked
    FROM Reservation_Rooms
    WHERE reservation_id = p_reservation_id AND room_id = p_room_id;

    IF v_room_is_linked = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The provided room is not part of this reservation.';
    END IF;

    SELECT IFNULL(SUM(amount), 0.00) INTO v_total_paid
    FROM Payments
    WHERE reservation_id = p_reservation_id AND status = 'Completed';

    IF v_total_paid <> v_total_price THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Check-in denied: reservation must be fully paid (Completed payments must equal total price).';
    END IF;

    UPDATE Rooms
    SET current_status = 'Occupied', updated_at = CURRENT_TIMESTAMP
    WHERE room_id = p_room_id
      AND current_status IN ('Vacant', 'Cleaning');

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Room cannot be occupied (wrong status or not found).';
    END IF;

    UPDATE Reservations
    SET reservation_status = 'Checked-in', updated_at = CURRENT_TIMESTAMP
    WHERE reservation_id = p_reservation_id;
END//

CREATE PROCEDURE PerformRoomCheckOut(
    IN p_reservation_id INT UNSIGNED,
    IN p_room_id INT UNSIGNED
)
BEGIN
    DECLARE v_rooms_remaining INT DEFAULT 0;

    UPDATE Rooms
    SET current_status = 'Cleaning', updated_at = CURRENT_TIMESTAMP
    WHERE room_id = p_room_id AND current_status = 'Occupied';

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Room is not currently Occupied or not found.';
    END IF;

    SELECT COUNT(r.room_id) INTO v_rooms_remaining
    FROM Rooms r
    JOIN Reservation_Rooms rr ON r.room_id = rr.room_id
    WHERE rr.reservation_id = p_reservation_id
      AND r.current_status != 'Cleaning';

    IF v_rooms_remaining = 0 THEN
        UPDATE Reservations
        SET reservation_status = 'Checked-out', updated_at = CURRENT_TIMESTAMP
        WHERE reservation_id = p_reservation_id;
    END IF;
END//

DELIMITER ;

-- ======================
-- View: dashboard today (MySQL 5.7 compatible)
-- ======================

DROP VIEW IF EXISTS vw_dashboard_today;

CREATE VIEW vw_dashboard_today AS
SELECT 'Today''s Arrivals' AS info, COUNT(*) AS total
FROM Reservations
WHERE check_in_date = CURDATE() AND reservation_status IN ('Confirmed','Checked-in')
UNION ALL
SELECT 'Today''s Departures', COUNT(*)
FROM Reservations
WHERE check_out_date = CURDATE() AND reservation_status = 'Checked-in'
UNION ALL
SELECT 'Currently Occupied Rooms', COUNT(DISTINCT rr.room_id)
FROM Reservation_Rooms rr
JOIN Reservations r ON rr.reservation_id = r.reservation_id
WHERE CURDATE() >= r.check_in_date AND CURDATE() < r.check_out_date
  AND r.reservation_status = 'Checked-in';

SELECT 'Hotel Management DB created (deposit + final payments + triggers + procedures)' AS status;
