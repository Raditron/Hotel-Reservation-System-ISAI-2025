# Hotel Reservation System Database

This project provides a comprehensive database schema for a Hotel Reservation System. It includes tables for managing roles, room types, customers, employees, reservations, payments, and services. The database is designed to be robust and scalable, with features like data validation, triggers for automatic actions, and stored procedures for common operations.

## ER Diagram

![Entity-Relationship Diagram](ER_Diagram.svg)

## Database Schema

The database `hotel_management_db1` consists of the following tables:

*   **`Roles`**: Stores employee roles and their descriptions (e.g., Manager, Receptionist).
*   **`Room_Types`**: Defines different types of rooms, including standard price, capacity, and amenities.
*   **`Rooms`**: Represents individual rooms in the hotel, their type, and current status.
*   **`Customers`**: Stores customer information, including personal details and contact information.
*   **`Employees`**: Manages employee data, such as personal information, role, and salary.
*   **`Reservations`**: Contains details of all room bookings, including check-in/out dates, number of guests, and total price.
*   **`Reservation_Guests`**: Links customers to a reservation, indicating the primary booker.
*   **`Reservation_Rooms`**: A junction table that assigns specific rooms to a reservation.
*   **`Services`**: Lists additional services offered by the hotel (e.g., spa, laundry).
*   **`Reservation_Services`**: Records services requested by customers for a specific reservation.
*   **`Employee_Services`**: Maps employees to the services they are qualified to perform.
*   **`Service_Executions`**: Tracks the execution of services by employees for a reservation.
*   **`Payments`**: Manages payment details for each reservation.
*   **`Work_Records`**: Logs the hours worked by employees.
*   **`Employee_Payroll`**: Calculates payroll for each employee based on work records and pay rates.

## Key Features

### Triggers

*   **`trg_reservations_before_insert_guardrails`**: Ensures new reservations start with a 'Confirmed' status.
*   **`trg_res_rooms_after_insert_recalc_deposit`**: Recalculates the deposit amount for a reservation after a new room is added.
*   **`trg_res_rooms_after_delete_recalc_deposit`**: Recalculates the deposit amount for a reservation after a room is removed.
*   **`trg_res_rooms_after_update_recalc_deposit`**: Recalculates the deposit amount for a reservation after a room is updated.
*   **`trg_res_rooms_before_insert`**: Prevents booking a room that is unavailable or already booked for overlapping dates.
*   **`trg_res_rooms_before_update`**: Prevents updating a reservation to a room that is unavailable or already booked.
*   **`trg_res_rooms_before_delete`**: Prevents the deletion of a reserved room if a completed payment exists.
*   **`trg_room_type_delete_check`**: Prevents the deletion of a room type if there are still rooms of that type.
*   **`trg_reservations_guardrails`**: Enforces rules for updating reservation status and details.
*   **`trg_res_guests_single_primary_ins`**: Ensures only one primary guest is allowed per reservation on insert.
*   **`trg_res_guests_single_primary_upd`**: Ensures only one primary guest is allowed per reservation on update.
*   **`trg_payments_validate_ins`**: Validates payments on insert, ensuring amounts are correct and rules are followed.
*   **`trg_payments_validate_upd`**: Validates payments on update.
*   **`trg_payments_block_delete_completed`**: Prevents the deletion of completed payments.

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
