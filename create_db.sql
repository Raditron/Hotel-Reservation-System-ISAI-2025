DROP DATABASE IF EXISTS hotel_management_db;
CREATE DATABASE hotel_management_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hotel_management_db;

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
    amenities JSON NULL,
    images JSON NULL,
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
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

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

CREATE TABLE Rooms (
    room_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    room_type_id INT UNSIGNED NOT NULL,
    current_status ENUM('Vacant', 'Occupied', 'Cleaning', 'Maintenance', 'Not Available', 'Under Renovation') NOT NULL DEFAULT 'Vacant',
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
    total_price DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (total_price >= 0),
    pay_at_checkin BOOLEAN NOT NULL DEFAULT FALSE, 
    booking_source ENUM('Walk-in','Website','Phone','Booking.com','Expedia','Airbnb','Travel Agent','Corporate','Other') NOT NULL DEFAULT 'Walk-in',
    external_reference VARCHAR(50) NULL,
    special_requests TEXT,
    notes TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_reservation_customer FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_dates CHECK (check_out_date > check_in_date)
);

CREATE TABLE Payments (
    payment_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT UNSIGNED NOT NULL UNIQUE,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Bank Transfer', 'Online') NOT NULL,
    status ENUM('Pending', 'Completed', 'Cancelled', 'Refunded') NOT NULL DEFAULT 'Pending',
    notes TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_payment_reservation FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Work_Records (
    work_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id INT UNSIGNED NOT NULL,
    role_id INT UNSIGNED NOT NULL,
    work_date DATE NOT NULL,
    hours_worked DECIMAL(5,2) NOT NULL,
    overtime_hours DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    is_weekend BOOLEAN NOT NULL DEFAULT FALSE,
    is_holiday BOOLEAN NOT NULL DEFAULT FALSE,
    notes TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_work_employee FOREIGN KEY (employee_id) REFERENCES Employees(employee_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_work_role FOREIGN KEY (role_id) REFERENCES Roles(role_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT unique_work_record UNIQUE (employee_id, role_id, work_date)
);

CREATE TABLE Employee_Payroll (
    payroll_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id INT UNSIGNED NOT NULL,
    role_id INT UNSIGNED NOT NULL,
    pay_period_end_date DATE NOT NULL,
    salary_type ENUM('Hourly', 'Monthly') NOT NULL,
    base_rate DECIMAL(10,2) NOT NULL CHECK (base_rate >= 0),
    hours_worked DECIMAL(6,2) NOT NULL DEFAULT 0.00,
    overtime_hours DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    overtime_rate DECIMAL(10,2) NOT NULL,
    gross_pay DECIMAL(10,2) NOT NULL,
    total_tax_deduction DECIMAL(10,2) NOT NULL,
    net_pay DECIMAL(10,2) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_payroll_employee FOREIGN KEY (employee_id) REFERENCES Employees(employee_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_payroll_role FOREIGN KEY (role_id) REFERENCES Roles(role_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT unique_payroll_period UNIQUE (employee_id, pay_period_end_date)
);

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
    customer_id INT UNSIGNED,
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
    FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id)
    ON DELETE CASCADE,
FOREIGN KEY (service_id) REFERENCES Services(service_id)
    ON DELETE RESTRICT,
FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
    ON DELETE RESTRICT

);


CREATE INDEX idx_customer_name_active ON Customers(last_name, first_name, deleted_at);
CREATE INDEX idx_customer_phone ON Customers(phone_number);
CREATE INDEX idx_customer_national_id ON Customers(national_id);

CREATE INDEX idx_reservation_dates_status ON Reservations(reservation_status, check_in_date, check_out_date);
CREATE INDEX idx_res_booking_source ON Reservations(booking_source);

CREATE INDEX idx_room_status_type ON Rooms(current_status, room_type_id);

CREATE INDEX idx_resroom_room_dates ON Reservation_Rooms(room_id, reservation_id);

CREATE INDEX idx_employee_role_status ON Employees(role_id, status);
CREATE INDEX idx_employee_deleted ON Employees(deleted_at);

DELIMITER //
CREATE TRIGGER trg_before_payment_complete
BEFORE UPDATE ON Payments
FOR EACH ROW
BEGIN
    DECLARE reserved_amount DECIMAL(10,2);

    IF NEW.status = 'Completed' AND OLD.status != 'Completed' THEN
        SELECT total_price INTO reserved_amount
        FROM Reservations WHERE reservation_id = NEW.reservation_id;

        IF reserved_amount IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Reservation for payment not found.';
        END IF;

        IF NEW.amount < reserved_amount AND (SELECT pay_at_checkin FROM Reservations WHERE reservation_id = NEW.reservation_id) = FALSE THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Payment amount cannot be less than total reservation price.';
        END IF;
    END IF;
END;
//
DELIMITER ;

DELIMITER //
DROP TRIGGER IF EXISTS trg_reservation_room_overlap_check//
CREATE TRIGGER trg_reservation_room_overlap_check
BEFORE INSERT ON Reservation_Rooms
FOR EACH ROW
BEGIN
    DECLARE new_in DATE;
    DECLARE new_out DATE;
    DECLARE room_stat ENUM('Vacant', 'Occupied', 'Cleaning', 'Maintenance', 'Not Available', 'Under Renovation');

    SELECT current_status INTO room_stat
    FROM Rooms WHERE room_id = NEW.room_id;

    IF room_stat IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Room not found.';
    END IF;

    IF room_stat IN ('Not Available', 'Under Renovation') THEN
         SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT = 'Cannot book room: Room is currently unavailable or under renovation.';
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
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Room already booked for overlapping dates.';
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_room_type_delete_check
BEFORE DELETE ON Room_Types
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM Rooms WHERE room_type_id = OLD.room_type_id) > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete Room Type: rooms exist.';
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE PerformRoomCheckIn(
    IN p_reservation_id INT UNSIGNED,
    IN p_room_id INT UNSIGNED
)
BEGIN
    DECLARE v_res_status ENUM('Confirmed', 'Checked-in', 'Checked-out', 'Cancelled');
    DECLARE v_payment_status ENUM('Pending','Completed','Cancelled','Refunded');
    DECLARE v_room_is_linked INT DEFAULT 0;
    DECLARE v_pay_at_checkin BOOL DEFAULT FALSE;

    SELECT reservation_status, pay_at_checkin INTO v_res_status, v_pay_at_checkin
    FROM Reservations
    WHERE reservation_id = p_reservation_id;

    IF v_res_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Reservation not found.';
    END IF;

    SELECT IFNULL(status, 'Pending') INTO v_payment_status
    FROM Payments WHERE reservation_id = p_reservation_id;

    IF v_res_status NOT IN ('Confirmed','Checked-in') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Reservation is not Confirmed or already Checked-in.';
    END IF;

    IF v_pay_at_checkin = FALSE AND v_payment_status != 'Completed' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment must be Completed before any room check-in.';
    END IF;

    -- Verify room is linked to reservation
    SELECT COUNT(*) INTO v_room_is_linked FROM Reservation_Rooms
    WHERE reservation_id = p_reservation_id AND room_id = p_room_id;

    IF v_room_is_linked = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The provided room is not part of this reservation.';
    END IF;

    UPDATE Rooms
    SET current_status = 'Occupied', updated_at = CURRENT_TIMESTAMP
    WHERE room_id = p_room_id
      AND current_status IN ('Vacant', 'Cleaning');

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Room cannot be set to Occupied (wrong status or not found).';
    END IF;

    UPDATE Reservations
    SET reservation_status = 'Checked-in', updated_at = CURRENT_TIMESTAMP
    WHERE reservation_id = p_reservation_id AND reservation_status = 'Confirmed';

END;
//
DELIMITER ;

DELIMITER //
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
END;
//
DELIMITER ;

CREATE OR REPLACE VIEW vw_dashboard_today AS
SELECT 'Today''s Arrivals' AS info, COUNT(*) AS total FROM Reservations
WHERE check_in_date = CURDATE() AND reservation_status IN ('Confirmed','Checked-in')
UNION ALL
SELECT 'Today''s Departures', COUNT(*) FROM Reservations
WHERE check_out_date = CURDATE() AND reservation_status = 'Checked-in'
UNION ALL
SELECT 'Currently Occupied Rooms', COUNT(DISTINCT rr.room_id)
FROM Reservation_Rooms rr
JOIN Reservations r ON rr.reservation_id = r.reservation_id
WHERE CURDATE() >= r.check_in_date AND CURDATE() < r.check_out_date
  AND r.reservation_status = 'Checked-in';

SELECT 'Optimized MySQL schema created' AS status;
