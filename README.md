# Hotel Reservation System Database

This project provides a comprehensive database schema for a Hotel Reservation System. It includes tables for managing roles, room types, customers, employees, reservations, payments, and services. The database is designed to be robust and scalable, with features like data validation, triggers for automatic actions, and stored procedures for common operations.

## ER Diagram

![Entity-Relationship Diagram](ER_Diagram.svg)

## Database Schema

The database `hotel_management_db1` consists of the following tables:

### 1. Roles
This table contains information about the different roles that work in the hotel.

| Column | Description |
|--------|-------------|
| role_id | Unique number for the role (Primary Key) |
| role_name | Name of the role (must be unique) |
| description | Short info about the role |
| created_at | Tracks when the record was created |
| updated_at | Tracks when the row was last modified |

---
### 2. Room_Types
Defines the different types of rooms available in the hotel with their standard pricing and amenities.

| Column | Description |
|--------|-------------|
| room_type_id | Unique identifier for the room type (Primary Key) |
| type_name | Name of the room type (must be unique) |
| standard_price | Base price for this room type (must be ≥ 0) |
| capacity | Maximum number of guests (1-10) |
| bed_count | Number of beds in the room (1-8) |
| description | Detailed description of the room type |
| deposit_required | Deposit amount required for this room type |
| created_at | Tracks when the record was created |
| updated_at | Tracks when the row was last modified |

---
### 3. Customers
Stores information about hotel guests and customers.

| Column | Description |
|--------|-------------|
| customer_id | Unique identifier for the customer (Primary Key) |
| first_name | Customer's first name |
| last_name | Customer's last name |
| national_id | National identification number (unique) |
| date_of_birth | Customer's date of birth |
| phone_number | Contact phone number |
| email | Email address (unique) |
| country | Country of residence |
| is_active | Indicates if customer account is active |
| deleted_at | Soft delete timestamp (NULL if not deleted) |
| created_at | Tracks when the record was created |
| updated_at | Tracks when the row was last modified |

---
### 4. Services
Contains all additional services offered by the hotel (spa, room service, laundry, etc.).

| Column | Description |
|--------|-------------|
| service_id | Unique identifier for the service (Primary Key) |
| service_name | Name of the service (must be unique) |
| description | Detailed description of the service |
| is_active | Indicates if service is currently available |
| available_from | Service availability start time |
| available_to | Service availability end time |
| created_at | Tracks when the record was created |
| updated_at | Tracks when the row was last modified |

---
### 5. Employees
Stores information about hotel staff members.

| Column | Description |
|--------|-------------|
| employee_id | Unique identifier for the employee (Primary Key) |
| first_name | Employee's first name |
| last_name | Employee's last name |
| national_id | National identification number (unique) |
| date_of_birth | Employee's date of birth |
| phone_number | Contact phone number |
| email | Email address (unique) |
| role_id | References the employee's role (Foreign Key → Roles) |
| hire_date | Date when employee was hired |
| base_pay_rate | Base hourly/monthly pay rate (must be ≥ 0) |
| status | Employment status: 'Active', 'On Leave', 'Resigned' |
| deleted_at | Soft delete timestamp (NULL if not deleted) |
| notes | Additional notes about the employee |
| created_at | Tracks when the record was created |
| updated_at | Tracks when the row was last modified |

---
### 6. Rooms
Contains information about individual room units in the hotel.

| Column | Description |
|--------|-------------|
| room_id | Unique identifier for the room (Primary Key) |
| room_number | Room number displayed to guests (unique) |
| room_type_id | References the room type (Foreign Key → Room_Types) |
| current_status | Current room status: 'Vacant', 'Occupied', 'Cleaning', 'Maintenance', 'Not Available', 'Under Renovation' |
| created_at | Tracks when the record was created |
| updated_at | Tracks when the row was last modified |

---
### 7. Reservations
Main table for booking information and reservation management.

| Column | Description |
|--------|-------------|
| reservation_id | Unique identifier for the reservation (Primary Key) |
| customer_id | References the customer making the booking (Foreign Key → Customers) |
| check_in_date | Date when guests will check in |
| check_out_date | Date when guests will check out (must be after check_in_date) |
| number_of_guests | Total number of guests (1-10) |
| reservation_status | Status: 'Confirmed', 'Checked-in', 'Checked-out', 'Cancelled' |
| total_price | Total cost of the reservation (must be > 0) |
| pay_at_checkin | Indicates if payment is deferred until check-in |
| deposit_amount | The amount of deposit required for the reservation |
| booking_source | Source of booking: 'Walk-in', 'Website', 'Phone', 'Booking.com', 'Expedia', 'Airbnb', 'Travel Agent', 'Corporate', 'Other' |
| external_reference | Reference number from external booking platforms |
| special_requests | Guest's special requests or preferences |
| notes | Additional notes about the reservation |
| created_at | Tracks when the record was created |
| updated_at | Tracks when the row was last modified |

---
### 8. Payments
Tracks all payment transactions for reservations.

| Column | Description |
|--------|-------------|
| payment_id | Unique identifier for the payment (Primary Key) |
| reservation_id | References the reservation being paid (Foreign Key → Reservations) |
| payment_type | Type of payment: 'Deposit' or 'Final' |
| amount | Payment amount (must be ≥ 0) |
| payment_date | Date and time when payment was made |
| payment_method | Method used: 'Cash', 'Credit Card', 'Debit Card', 'Bank Transfer', 'Online' |
| status | Payment status: 'Pending', 'Completed', 'Cancelled', 'Refunded' |
| notes | Additional payment notes |
| created_at | Tracks when the record was created |
| updated_at | Tracks when the row was last modified |

**Unique Constraint:** A reservation can have a unique payment type (e.g., one 'Deposit' and one 'Final' payment).

---
### 9. Work_Records
Tracks daily work hours for employees.

| Column | Description |
|--------|-------------|
| work_id | Unique identifier for the work record (Primary Key) |
| employee_id | References the employee (Foreign Key → Employees) |
| role_id | References the role performed (Foreign Key → Roles) |
| work_date | Date of work performed |
| hours_worked | Regular hours worked |
| overtime_hours | Overtime hours worked (default 0.00) |
| is_weekend | Indicates if work was on a weekend |
| is_holiday | Indicates if work was on a holiday |
| notes | Additional notes about the work record |
| created_at | Tracks when the record was created |
| updated_at | Tracks when the row was last modified |

**Unique Constraint:** One record per employee, role, and work date combination.

---
### 10. Employee_Payroll
Stores payroll calculations and payment records for employees.

| Column | Description |
|--------|-------------|
| payroll_id | Unique identifier for the payroll record (Primary Key) |
| employee_id | References the employee (Foreign Key → Employees) |
| role_id | References the role (Foreign Key → Roles) |
| pay_period_end_date | End date of the pay period |
| salary_type | Type of salary: 'Hourly' or 'Monthly' |
| base_rate | Base pay rate (must be ≥ 0) |
| hours_worked | Total regular hours worked (default 0.00) |
| overtime_hours | Total overtime hours (default 0.00) |
| overtime_rate | Rate for overtime hours |
| gross_pay | Total pay before deductions |
| total_tax_deduction | Total tax amount deducted |
| net_pay | Final pay after deductions |
| created_at | Tracks when the record was created |
| updated_at | Tracks when the row was last modified |

**Unique Constraint:** One payroll record per employee per pay period.

---
### 11. Reservation_Guests
Links multiple guests to a single reservation (many-to-many relationship).

| Column | Description |
|--------|-------------|
| res_guest_id | Unique identifier for the record (Primary Key) |
| reservation_id | References the reservation (Foreign Key → Reservations) |
| customer_id | References the guest (Foreign Key → Customers) |
| is_primary_booker | Indicates if this guest is the primary person who made the booking |
| added_at | Timestamp when guest was added to reservation |

**Unique Constraint:** Each customer can only be added once per reservation.

---
### 12. Reservation_Rooms
Links rooms to reservations (many-to-many relationship).

| Column | Description |
|--------|-------------|
| res_room_id | Unique identifier for the record (Primary Key) |
| reservation_id | References the reservation (Foreign Key → Reservations) |
| room_id | References the room (Foreign Key → Rooms) |
| created_at | Tracks when the record was created |
| updated_at | Tracks when the row was last modified |

**Unique Constraint:** Each room can only be assigned once per reservation.

---
### 13. Reservation_Services
Links services to reservations and optionally to specific customers.

| Column | Description |
|--------|-------------|
| reservation_service_id | Unique identifier for the record (Primary Key) |
| reservation_id | References the reservation (Foreign Key → Reservations) |
| service_id | References the service (Foreign Key → Services) |
| customer_id | References the specific customer using the service (optional, Foreign Key → Customers) |
| added_at | Timestamp when service was added |
| updated_at | Tracks when the row was last modified |

---
### 14. Employee_Services
Links employees to services they can provide (many-to-many relationship).

| Column | Description |
|--------|-------------|
| emp_service_id | Unique identifier for the record (Primary Key) |
| employee_id | References the employee (Foreign Key → Employees) |
| service_id | References the service (Foreign Key → Services) |
| can_be_scheduled | Indicates if employee can be scheduled for this service |
| created_at | Tracks when the record was created |
| updated_at | Tracks when the row was last modified |

**Unique Constraint:** Each employee-service combination is unique.

---
### 15. Service_Executions
Tracks the actual execution of services by employees for reservations.

| Column | Description |
|--------|-------------|
| execution_id | Unique identifier for the execution record (Primary Key) |
| reservation_id | References the reservation (Foreign Key → Reservations) |
| service_id | References the service being performed (Foreign Key → Services) |
| employee_id | References the employee performing the service (Foreign Key → Employees) |
| status | Execution status: 'Scheduled', 'In Progress', 'Completed', 'Cancelled' |
| performed_at | Timestamp when service was performed |
| notes | Additional notes about the service execution |

---
## Indexes

### Customer Indexes
- **idx_customer_name_active**: Composite index on `(last_name, first_name, deleted_at)` - Optimizes customer searches by name and active status
- **idx_customer_phone**: Index on `phone_number` - Speeds up customer lookups by phone
- **idx_customer_national_id**: Index on `national_id` - Optimizes searches by national ID

### Reservation Indexes
- **idx_reservation_dates_status**: Composite index on `(reservation_status, check_in_date, check_out_date)` - Optimizes queries filtering by status and date ranges
- **idx_res_booking_source**: Index on `booking_source` - Speeds up reporting by booking channel

### Room Indexes
- **idx_room_status_type**: Composite index on `(current_status, room_type_id)` - Optimizes room availability queries

### Reservation_Rooms Indexes
- **idx_resroom_room_dates**: Composite index on `(room_id, reservation_id)` - Optimizes room booking lookups
- **idx_resroom_reservation**: Index on `(reservation_id)` - Optimizes queries that filter by reservation.

### Employee Indexes
- **idx_employee_role_status**: Composite index on `(role_id, status)` - Optimizes employee queries by role and employment status
- **idx_employee_deleted**: Index on `deleted_at` - Speeds up filtering active vs deleted employees

---
## Key Features

### Triggers

*   **`trg_reservations_before_insert_guardrails`**:
    *   **Type:** BEFORE INSERT on `Reservations`
    *   **Purpose:** Ensures new reservations start with a 'Confirmed' status.
*   **`trg_res_rooms_after_insert_recalc_deposit`**:
    *   **Type:** AFTER INSERT on `Reservation_Rooms`
    *   **Purpose:** Recalculates the deposit amount for a reservation after a new room is added.
*   **`trg_res_rooms_after_delete_recalc_deposit`**:
    *   **Type:** AFTER DELETE on `Reservation_Rooms`
    *   **Purpose:** Recalculates the deposit amount for a reservation after a room is removed.
*   **`trg_res_rooms_after_update_recalc_deposit`**:
    *   **Type:** AFTER UPDATE on `Reservation_Rooms`
    *   **Purpose:** Recalculates the deposit amount for a reservation after a room is updated.
*   **`trg_res_rooms_before_insert`**:
    *   **Type:** BEFORE INSERT on `Reservation_Rooms`
    *   **Purpose:** Prevents booking rooms that are unavailable or already booked for overlapping dates. Also prevents modification after a completed payment exists.
*   **`trg_res_rooms_before_update`**:
    *   **Type:** BEFORE UPDATE on `Reservation_Rooms`
    *   **Purpose:** Prevents updating room reservations to create booking conflicts or after a completed payment exists.
*   **`trg_res_rooms_before_delete`**:
    *   **Type:** BEFORE DELETE on `Reservation_Rooms`
    *   **Purpose:** Prevents the deletion of a reserved room if a completed payment exists.
*   **`trg_room_type_delete_check`**:
    *   **Type:** BEFORE DELETE on `Room_Types`
    *   **Purpose:** Prevents deletion of a room type if it is still referenced by existing rooms.
*   **`trg_reservations_guardrails`**:
    *   **Type:** BEFORE UPDATE on `Reservations`
    *   **Purpose:** Enforces rules for updating reservation status and details, preventing changes after payments are made and ensuring full payment before check-in.
*   **`trg_res_guests_single_primary_ins`**:
    *   **Type:** BEFORE INSERT on `Reservation_Guests`
    *   **Purpose:** Ensures only one primary guest is allowed per reservation.
*   **`trg_res_guests_single_primary_upd`**:
    *   **Type:** BEFORE UPDATE on `Reservation_Guests`
    *   **Purpose:** Ensures only one primary guest is allowed per reservation.
*   **`trg_payments_validate_ins`**:
    *   **Type:** BEFORE INSERT on `Payments`
    *   **Purpose:** Validates payments on insert, ensuring amounts are correct and follow deposit/final payment rules.
*   **`trg_payments_validate_upd`**:
    *   **Type:** BEFORE UPDATE on `Payments`
    *   **Purpose:** Validates payments on update and prevents modification of completed payments.
*   **`trg_payments_block_delete_completed`**:
    *   **Type:** BEFORE DELETE on `Payments`
    *   **Purpose:** Prevents the deletion of completed payments.

### Stored Procedures

*   **`PerformRoomCheckIn(p_reservation_id, p_room_id)`**: Handles the check-in process for a specific room within a reservation. It updates the room status to 'Occupied' and the reservation status to 'Checked-in'.
*   **`PerformRoomCheckOut(p_reservation_id, p_room_id)`**: Manages the check-out process. It changes the room status to 'Cleaning' and, if all rooms in the reservation are checked out, updates the reservation status to 'Checked-out'.

### Views

*   **`vw_dashboard_today`**: A view that provides a summary of today's hotel activity, including arrivals, departures, and currently occupied rooms.

## Workflow

The typical workflow for a hotel reservation using this database schema is as follows:

1.  **Reservation**: A `Customer` makes a `Reservation`. The reservation details, such as check-in/out dates and number of guests, are stored in the `Reservations` table.
2.  **Room Assignment**: Specific `Rooms` of a certain `Room_Type` are assigned to the reservation and recorded in the `Reservation_Rooms` table. The `trg_res_rooms_before_insert` trigger prevents any overlapping bookings for the same room.
3.  **Payment**: A `Payment` is made for the reservation. The `trg_payments_validate_ins` trigger ensures the payment amount is correct before the payment status can be set to 'Completed'.
4.  **Check-In**: On the day of arrival, the `PerformRoomCheckIn` stored procedure is executed for each room in the reservation. This updates the `Rooms` status to 'Occupied' and the `Reservations` status to 'Checked-in'.
5.  **Services**: During their stay, guests can request additional `Services`. These are recorded in the `Reservation_Services` table, and the execution of these services by employees is tracked in the `Service_Executions` table.
6.  **Check-Out**: Upon departure, the `PerformRoomCheckOut` stored procedure is called for each room. This updates the room status to 'Cleaning' and, once all rooms are checked out, sets the reservation status to 'Checked-out'.

## Setup and Usage

To set up and populate the database, follow these steps:

1.  **Create the Database and Schema**:
    Execute the `create_db.sql` script to create the `hotel_management_db1` database and all its tables, triggers, and stored procedures.

    ```bash
    mysql -u [your_username] -p < create_db.sql
    ```

2.  **Populate the Database with Sample Data**:
    Run the `populate_db.sql` script to insert sample data into the tables. This script also includes a series of tests to verify the functionality of the triggers and stored procedures.

    ```bash
    mysql -u [your_username] -p < populate_db.sql
    ```

3.  **Run Unit Tests**:
    Execute the `unit_tests.sql` script to run a series of tests against the database to verify its integrity and functionality.
    
    ```bash
    mysql -u [your_username] -p < unit_tests.sql
    ```

After completing these steps, the database will be ready for use.
