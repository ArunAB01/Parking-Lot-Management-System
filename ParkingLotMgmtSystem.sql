/*
------------------------------------------------------------------------------------------
Park@Ease - Smart parking lot system using IoT. 
Core Tables				: users, vehicles, parking_lots, parking_slots, bookings, payments
IoT & Security  		: parking_sensors, access_control, logs, violations
Revenue & Subscriptions : subscription_plans (lookup), user_subscriptions (intersection), discounts, booking_discounts (intersection)
staff Management		: staff
Audit Tables		        : bookings_audit, payments_audit, parking_sensors_audit 
*/
 
/*
------------------------------------------------------------------------------------------
Create the new Database
*/
CREATE DATABASE ParkinglotMgmtSystem;

-- SHOW TABLES;

USE ParkinglotMgmtSystem;

/*
------------------------------------------------------------------------------------------
Create new tables
*/
/* 1. Users Table - Stores information about registered users (customers and admins).
Author: Amani Alwala
*/
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    password_hash VARCHAR(255),
    user_type ENUM('admin', 'customer') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*2. Vehicles Table - Stores vehicle details linked to users.
Author: Amani Alwala
*/
CREATE TABLE vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    license_plate VARCHAR(20) UNIQUE NOT NULL,
    vehicle_type ENUM('car', 'bike', 'truck', 'electric') NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

/*3. Parking Lots Table - Stores details about parking lots.
Author: Amani Alwala
*/
CREATE TABLE parking_lots (
    lot_id INT AUTO_INCREMENT PRIMARY KEY,
    lot_name VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    total_slots INT NOT NULL,
    available_slots INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*4. Parking Slots Table - Stores details of each parking slot in a parking lot.
Author: Arun Anantharam Bagade
*/
CREATE TABLE parking_slots (
    slot_id INT AUTO_INCREMENT PRIMARY KEY,
    lot_id INT NOT NULL,
    slot_number VARCHAR(10) NOT NULL,
    slot_type ENUM('regular', 'compact', 'handicapped', 'electric') NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (lot_id) REFERENCES parking_lots(lot_id) ON DELETE CASCADE
);

/*5. Parking Sensors Table - Stores IoT sensor details for tracking parking slot status.
Author: Arun Anantharam Bagade
*/
CREATE TABLE parking_sensors (
    sensor_id INT AUTO_INCREMENT PRIMARY KEY,
    slot_id INT NOT NULL,
    status ENUM('occupied', 'vacant') NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (slot_id) REFERENCES parking_slots(slot_id) ON DELETE CASCADE
);

/*6. Bookings Table - Stores parking reservations made by users.
Author: Arun Anantharam Bagade
*/
CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    slot_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    status ENUM('pending', 'active', 'completed', 'canceled') DEFAULT 'pending',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (slot_id) REFERENCES parking_slots(slot_id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE
);

/*7. Payments Table - Stores payment transactions.
Author: Shivangi Jaiswal
*/
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    payment_method ENUM('credit_card', 'debit_card', 'digital_wallet', 'cash') NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE
);
/*8. Access Control Table - Stores details of access authentication (RFID or QR-based).
Author: Shivangi Jaiswal
*/
CREATE TABLE access_control (
    access_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    access_token VARCHAR(100) UNIQUE NOT NULL,
    status ENUM('active', 'expired', 'revoked') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE
);

/*9. Logs Table - Tracks all entry/exit activity in parking lots.
Author: Shivangi Jaiswal
*/
CREATE TABLE logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    lot_id INT NOT NULL,
    entry_time DATETIME NOT NULL,
    exit_time DATETIME,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    FOREIGN KEY (lot_id) REFERENCES parking_lots(lot_id) ON DELETE CASCADE
);

/*10. Violations Table - Stores unauthorized parking attempts.
Author: Yidi Li
*/
CREATE TABLE violations (
    violation_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    lot_id INT NOT NULL,
    violation_type ENUM('overstay', 'no_booking', 'unauthorized_entry', 'sensor_issue') NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    FOREIGN KEY (lot_id) REFERENCES parking_lots(lot_id) ON DELETE CASCADE
);
/*11. Staff Table - Stores details of parking lot staff and administrators.
Author: Yidi Li
*/
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    lot_id INT NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    role ENUM('manager', 'security', 'maintenance') NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(100) UNIQUE,
    FOREIGN KEY (lot_id) REFERENCES parking_lots(lot_id) ON DELETE CASCADE
);

/*12. Subscription Plans Table (Lookup Table)- Stores predefined parking subscription plans.
Author: Yidi Li
*/
CREATE TABLE subscription_plans (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    duration_days INT NOT NULL
);

/*13. User Subscriptions Table (Intersection Table) - Tracks which users are subscribed to a plan.
Author: Parthan Patel
*/
CREATE TABLE user_subscriptions (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('active', 'expired', 'canceled') DEFAULT 'active',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES subscription_plans(plan_id) ON DELETE CASCADE
);

/*14. Discounts Table - Stores promotional discount codes.
Author: Parthan Patel
*/
CREATE TABLE discounts (
    discount_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    discount_percentage DECIMAL(5,2) NOT NULL,
    expiry_date DATE NOT NULL
);

/*15. Booking_Discounts Table (Intersection Table) - Applies discount codes to bookings.
Author: Parthan Patel
*/
CREATE TABLE booking_discounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    discount_id INT NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE,
    FOREIGN KEY (discount_id) REFERENCES discounts(discount_id) ON DELETE CASCADE
);

-- 1) Audit table for all INSERT/UPDATE actions on bookings
CREATE TABLE bookings_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,                      -- the PK from bookings
    user_id INT,
    slot_id INT,
    vehicle_id INT,
    start_time DATETIME,
    end_time DATETIME,
    status ENUM('pending','active','completed','canceled'),
    action VARCHAR(15) NOT NULL,         -- e.g. 'BEFORE_INSERT', 'AFTER_INSERT', 'AFTER_UPDATE'
    action_timestamp DATETIME NOT NULL   -- when the trigger fired
);

-- 2) Audit table for INSERT actions on payments (trg_after_payment_insert)
CREATE TABLE payments_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    payment_id INT,                      -- the PK from payments
    booking_id INT,
    amount DECIMAL(10,2),
    payment_status ENUM('pending','completed','failed','refunded'),
    payment_method ENUM('credit_card','debit_card','digital_wallet','cash'),
    transaction_date TIMESTAMP,
    action VARCHAR(15) NOT NULL,         -- e.g. 'AFTER_INSERT'
    action_timestamp DATETIME NOT NULL
);

-- 3) Audit table for UPDATE actions on parking_sensors (trg_before_sensor_update)
CREATE TABLE parking_sensors_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    sensor_id INT,                       -- the PK from parking_sensors
    slot_id INT,
    old_status ENUM('occupied','vacant'),
    new_status ENUM('occupied','vacant'),
    action VARCHAR(15) NOT NULL,         -- e.g. 'BEFORE_UPDATE'
    action_timestamp DATETIME NOT NULL
);

/*
------------------------------------------------------------------------------------------
Complex Queries
*/

/*
Query 1
/*Peak entry time by hour per lot 
Author: Amani Alwala
*/
 
SELECT 
    pl.lot_id,
    pl.lot_name,
    HOUR(l.entry_time) AS peak_hour,
    CASE
        WHEN HOUR(l.entry_time) BETWEEN 0 AND 5 THEN 'Late Night (12AM - 6AM)'
        WHEN HOUR(l.entry_time) BETWEEN 6 AND 11 THEN 'Morning (6AM - 12PM)'
        WHEN HOUR(l.entry_time) BETWEEN 12 AND 17 THEN 'Afternoon (12PM - 6PM)'
        WHEN HOUR(l.entry_time) BETWEEN 18 AND 21 THEN 'Evening (6PM - 10PM)'
        ELSE 'Night (10PM - 12AM)'
    END AS time_period,
    COUNT(*) AS entry_count
FROM logs l
JOIN parking_lots pl ON l.lot_id = pl.lot_id
WHERE l.entry_time IS NOT NULL
GROUP BY pl.lot_id, pl.lot_name, peak_hour, time_period
ORDER BY pl.lot_id, entry_count DESC;
 
/*
Query 2
Description: Displays all active bookings along with the user’s name and vehicle details.
Author: Amani Alwala
*/
 
SELECT b.booking_id, u.first_name, u.last_name, v.license_plate, b.start_time, b.end_time
FROM bookings b
JOIN users u ON b.user_id = u.user_id
JOIN vehicles v ON b.vehicle_id = v.vehicle_id
WHERE b.status = 'active';
 
/*
Query 3
Description: Finds vehicles with recorded parking violations.
Author: Arun Anantharam Bagade
*/
 
SELECT v.vehicle_id, 
	v.license_plate, 
    COUNT(*) AS violation_count
FROM violations vl
JOIN vehicles v ON vl.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_id, v.license_plate
HAVING violation_count > 0;
 
/*
Query 4
/* Query analyzes sensor behavior over the past week 
Author: Arun Anantharam Bagade
*/
SELECT 
    ps.sensor_id,
    ps.slot_id,
    pl.lot_name,
    ps.status,
    ps.last_updated,
    CASE
        WHEN ps.last_updated < NOW() - INTERVAL 1 DAY THEN 'Potential Offline'
        ELSE 'Normal'
    END AS sensor_health_status
FROM parking_sensors ps
JOIN parking_slots pslot ON ps.slot_id = pslot.slot_id
JOIN parking_lots pl ON pslot.lot_id = pl.lot_id
ORDER BY ps.last_updated ASC;
 
 
/*
Query 5
Description: Lists users who currently have active subscriptions along with their plan details.
Author: Shivangi Jaiswal
*/
 
SELECT u.user_id, u.first_name, u.last_name, sp.plan_name, us.start_date, us.end_date
FROM user_subscriptions us
JOIN users u ON us.user_id = u.user_id
JOIN subscription_plans sp ON us.plan_id = sp.plan_id
WHERE us.status = 'active';
 
 
/*
Query 6
Description: Identifies the most frequently parked vehicle type for each parking lot.
Author: Shivangi Jaiswal
*/
 
SELECT pl.lot_id, pl.lot_name, v.vehicle_type, COUNT(*) AS vehicle_count
FROM bookings b
JOIN vehicles v ON b.vehicle_id = v.vehicle_id
JOIN parking_slots ps ON b.slot_id = ps.slot_id
JOIN parking_lots pl ON ps.lot_id = pl.lot_id
GROUP BY pl.lot_id, pl.lot_name, v.vehicle_type
ORDER BY vehicle_count DESC;
 
/*
Query 7
Description: Lists customers who have not made any booking in the last three months.
Author: Yidi Li
*/
 
SELECT u.user_id, u.first_name, u.last_name
FROM users u
LEFT JOIN bookings b ON u.user_id = b.user_id 
AND b.start_time >= CURDATE() - INTERVAL 3 MONTH
WHERE u.user_type = 'customer' AND b.booking_id IS NULL;
 
 
/*
Query 8
Description: Top most booked parking lots in the current year 
Author: Yidi Li
*/
 
SELECT  
    pl.lot_id, 
    pl.lot_name,
    COUNT(b.booking_id) AS total_bookings
FROM bookings b
JOIN parking_slots ps ON b.slot_id = ps.slot_id
JOIN parking_lots pl ON ps.lot_id = pl.lot_id
WHERE YEAR(b.start_time) = YEAR(CURDATE())
GROUP BY pl.lot_id, pl.lot_name
ORDER BY total_bookings DESC
LIMIT 5;
 
/*
Query 9
Description: Calculates the average time vehicles remain parked in each parking lot.
Author: Parthan Patel
*/
 
SELECT pl.lot_id, pl.lot_name, AVG(TIMESTAMPDIFF(MINUTE, l.entry_time, l.exit_time)) AS avg_parking_duration
FROM logs l
JOIN parking_lots pl ON l.lot_id = pl.lot_id
WHERE l.exit_time IS NOT NULL
GROUP BY pl.lot_id, pl.lot_name;
 
/*
Query 10
Description: Shows all discounts applied to completed bookings along with the payment amount.
Author: Parthan Patel
*/
 
SELECT b.booking_id, d.code, d.discount_percentage, p.amount
FROM booking_discounts bd
JOIN bookings b ON bd.booking_id = b.booking_id
JOIN discounts d ON bd.discount_id = d.discount_id
JOIN payments p ON b.booking_id = p.booking_id
WHERE b.status = 'active' AND p.payment_status = 'completed';

-- ----------------------------------------------------------------------------------
-- Stored Procedures 


DELIMITER //
-- 1. ReportMonthlyRevenue
-- Iterates over each lot with a cursor, aggregates revenue, and returns a result set.
-- Author: Amani Alwala
CREATE PROCEDURE ReportMonthlyRevenue(
    IN p_year  INT,
    IN p_month INT
)
BEGIN
  DECLARE done      BOOLEAN DEFAULT FALSE;
  DECLARE v_lot_id   INT;
  DECLARE v_lot_name VARCHAR(100);
  DECLARE v_total    DECIMAL(10,2);

  DECLARE cur_lots CURSOR FOR 
    SELECT lot_id, lot_name 
      FROM parking_lots;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  CREATE TEMPORARY TABLE IF NOT EXISTS tmp_revenue (
    lot_id INT, 
    lot_name VARCHAR(100), 
    total_revenue DECIMAL(10,2)
  );

  OPEN cur_lots;
  read_loop: LOOP
    FETCH cur_lots INTO v_lot_id, v_lot_name;
    IF done THEN 
      LEAVE read_loop;
    END IF;

    SELECT IFNULL(SUM(p.amount),0) 
      INTO v_total
      FROM payments p
      JOIN bookings b ON p.booking_id = b.booking_id
      JOIN parking_slots ps ON b.slot_id = ps.slot_id
      WHERE ps.lot_id = v_lot_id
        AND p.payment_status = 'completed'
        AND YEAR(p.transaction_date) = p_year
        AND MONTH(p.transaction_date) = p_month;

    INSERT INTO tmp_revenue VALUES(v_lot_id, v_lot_name, v_total);
  END LOOP;
  CLOSE cur_lots;

  SELECT * FROM tmp_revenue;
  DROP TEMPORARY TABLE tmp_revenue;
END;
//

-- 2. AllocateNearestAvailableSlot
-- Finds the closest available slot in a lot and creates a booking.
-- Author: Arun Anantharam Bagade
CREATE PROCEDURE AllocateNearestAvailableSlot(
    IN  p_vehicle_id   INT,
    IN  p_lot_id       INT,
    IN  p_user_id      INT,
    IN  p_start_time   DATETIME,
    IN  p_end_time     DATETIME,
    OUT p_booking_id   INT,
    OUT v_slot_id INT
)
BEGIN

  START TRANSACTION;

  -- pick the nearest vacant slot in this lot (assumes slot_number encodes proximity)
  SELECT slot_id
    INTO v_slot_id
    FROM parking_slots
    WHERE lot_id = p_lot_id
      AND is_available = 0
      AND IsSlotAvailable(slot_id, p_start_time, p_end_time) = TRUE
    ORDER BY CAST(slot_number AS UNSIGNED) ASC
    LIMIT 1
    FOR UPDATE;

  IF v_slot_id IS NULL THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' 
      SET MESSAGE_TEXT = 'No available slots found';
  END IF;

  -- create booking
  INSERT INTO bookings (user_id, slot_id, vehicle_id, start_time, end_time, status)
  VALUES (p_user_id, v_slot_id, p_vehicle_id, p_start_time, p_end_time, 'pending');
  SET p_booking_id = LAST_INSERT_ID();

  -- mark slot unavailable
  UPDATE parking_slots
    SET is_available = FALSE
    WHERE slot_id = v_slot_id;

  COMMIT;
END;
//

-- 3. CleanupStaleBookings
-- Expires pending bookings older than 1 hour and logs a 'no_booking' violation for each.
-- Author: Shivangi Jaiswal
CREATE PROCEDURE CleanupStaleBookings()
BEGIN
  DECLARE done        BOOLEAN DEFAULT FALSE;
  DECLARE v_booking   INT;

  DECLARE cur_old CURSOR FOR
    SELECT booking_id 
      FROM bookings
      WHERE start_time < DATE_SUB(NOW(), INTERVAL 1 HOUR)
        AND status = 'pending';
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur_old;
  stale_loop: LOOP
    FETCH cur_old INTO v_booking;
    IF done THEN 
      LEAVE stale_loop;
    END IF;

    UPDATE bookings
      SET status = 'canceled'
      WHERE booking_id = v_booking;

    INSERT INTO violations (vehicle_id, lot_id, violation_type)
    SELECT b.vehicle_id, ps.lot_id, 'no_booking'
      FROM bookings b
      JOIN parking_slots ps ON b.slot_id = ps.slot_id
      WHERE b.booking_id = v_booking;
  END LOOP;
  CLOSE cur_old;
END;
//

-- 4. UpgradeUserSubscription
-- Auto‑upgrades a heavy‑use customer to the next plan tier, extending their end_date.
-- Author: Parthan Patel
DELIMITER //
/* calling UpgradeUserSubscription */
 
 
CREATE PROCEDURE UpgradeUserSubscription(
    IN  p_user_id   INT,
    OUT p_message   VARCHAR(255)
)
BEGIN
  DECLARE v_plan_id       INT;
  DECLARE v_usage_count   INT;
  DECLARE v_current_price DECIMAL(10,2);
  DECLARE v_new_plan_id   INT;
 
  -- Label block to allow LEAVE
  proc: BEGIN
 
    -- Step 1: Find the current active subscription
    SELECT plan_id
      INTO v_plan_id
      FROM user_subscriptions
      WHERE user_id = p_user_id
        AND end_date > CURDATE()
      ORDER BY start_date DESC
      LIMIT 1;
 
    IF v_plan_id IS NULL THEN
      SET p_message = 'No active subscription found for the user.';
      LEAVE proc;
    END IF;
 
    -- Step 2: Count user's bookings in last 30 days
    SELECT COUNT(*) 
      INTO v_usage_count
      FROM bookings
      WHERE user_id = p_user_id
        AND start_time >= DATE_SUB(NOW(), INTERVAL 30 DAY);
 
    -- If usage is too low, send nice message
    IF v_usage_count <= 20 THEN
      SET p_message = 'User does not meet upgrade criteria yet. Keep using more!';
      LEAVE proc;
    END IF;
 
    -- Step 3: Look up current plan price
    SELECT price
      INTO v_current_price
      FROM subscription_plans
      WHERE plan_id = v_plan_id;
 
    -- Step 4: Find next higher priced plan
    SELECT plan_id
      INTO v_new_plan_id
      FROM subscription_plans
      WHERE price > v_current_price
      ORDER BY price ASC
      LIMIT 1;
 
    IF v_new_plan_id IS NULL THEN
      SET p_message = 'User is already on the highest available plan.';
    ELSE
      -- Step 5: Upgrade subscription
      UPDATE user_subscriptions
        SET plan_id   = v_new_plan_id,
            end_date = DATE_ADD(end_date, INTERVAL 30 DAY)
        WHERE user_id = p_user_id
          AND plan_id = v_plan_id;
 
      SET p_message = CONCAT('Upgrade successful! Moved to plan ID ', v_new_plan_id, '.');
    END IF;
 
  END proc;
 
END
//
 DELIMITER ;

-- 5. AuditSensorAnomalies
-- Scans sensors and flags any 'vacant' sensor that still has an active booking.
-- Author: Yidi Li

DELIMITER //
CREATE PROCEDURE AuditSensorAnomalies()
BEGIN
  DECLARE done       BOOLEAN DEFAULT FALSE;
  DECLARE v_slot     INT;
  DECLARE v_status   ENUM('occupied','vacant');
  DECLARE v_lot      INT;

  DECLARE cur_sens CURSOR FOR 
    SELECT slot_id, status FROM parking_sensors;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur_sens;
  anomaly_loop: LOOP
    FETCH cur_sens INTO v_slot, v_status;
    IF done THEN 
      LEAVE anomaly_loop;
    END IF;

    IF v_status = 'vacant' AND
       EXISTS(
         SELECT 1 FROM bookings b
          WHERE b.slot_id = v_slot AND b.status = 'active'
       )
    THEN
      SELECT lot_id INTO v_lot
        FROM parking_slots
        WHERE slot_id = v_slot;

      INSERT INTO violations (vehicle_id, lot_id, violation_type)
      SELECT b.vehicle_id, v_lot, 'sensor_issue'
        FROM bookings b
        WHERE b.slot_id = v_slot
          AND b.status = 'active'
        LIMIT 1;
    END IF;
  END LOOP;
  CLOSE cur_sens;
END;
//
DELIMITER ;

-- ----------------------------------------------------------------------------------
-- ---------------------Functions----------------------------

-- 1. GetOccupancyRate
-- Calculates occupancy rate (%) for a lot on a given date.
-- Author: Arun Anantharam Bagade

DELIMITER //
CREATE FUNCTION GetOccupancyRate(
    p_lot_id INT,
    p_date   DATE
)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
  DECLARE v_total   INT;
  DECLARE v_occupied INT;

  SELECT COUNT(*) INTO v_total
    FROM parking_slots
    WHERE lot_id = p_lot_id;

  SELECT COUNT(*) INTO v_occupied
    FROM bookings b
    JOIN parking_slots ps ON b.slot_id = ps.slot_id
    WHERE ps.lot_id = p_lot_id
      AND DATE(b.start_time) = p_date
      AND b.status = 'active';

  RETURN ROUND((v_occupied / v_total) * 100, 2);
END;
//
DELIMITER ;

-- 2. GetBookingDuration
-- Returns the duration in hours (decimal) for a booking.
-- Author: Amani Alwala

DELIMITER //
CREATE FUNCTION GetBookingDuration(p_booking_id INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
  DECLARE v_start DATETIME;
  DECLARE v_end   DATETIME;
  DECLARE v_hours DECIMAL(5,2);

  SELECT start_time, end_time
    INTO v_start, v_end
    FROM bookings
    WHERE booking_id = p_booking_id;

  SET v_hours = TIMESTAMPDIFF(MINUTE, v_start, v_end) / 60;
  RETURN ROUND(v_hours, 2);
END;
//
DELIMITER ;

-- 3. IsSlotAvailable
-- Checks for any overlapping booking on a slot.
-- Author: Shivangi Jaiswal

DELIMITER //
CREATE FUNCTION IsSlotAvailable(
    p_slot_id INT,
    p_start   DATETIME,
    p_end     DATETIME
)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
  DECLARE v_conflicts INT;

  SELECT COUNT(*)
     INTO v_conflicts
    FROM bookings
    WHERE slot_id = p_slot_id
      AND status IN ('pending','active')
      AND NOT (end_time <= p_start OR start_time >= p_end);

  RETURN (v_conflicts = 0);
END;
//
DELIMITER ;


-- 4. CalculateUserMonthlyExpenditure
-- Sums completed payments for a user in a given month.
-- Author: Parthan Patel

DELIMITER //
CREATE FUNCTION CalculateUserMonthlyExpenditure(
    p_user_id INT,
    p_year    INT,
    p_month   INT
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE v_total DECIMAL(10,2);

  SELECT IFNULL(SUM(p.amount),0)
    INTO v_total
    FROM payments p
    JOIN bookings b ON p.booking_id = b.booking_id
    WHERE b.user_id = p_user_id
      AND p.payment_status = 'completed'
      AND YEAR(p.transaction_date) = p_year
      AND MONTH(p.transaction_date) = p_month;

  RETURN ROUND(v_total, 2);
END;
//
DELIMITER ;


-- 5. GetPeakBookingStartHour
-- Returns the hour (0–23) when most bookings start in a lot.
-- Author: Yidi Li

DELIMITER //
CREATE FUNCTION GetPeakBookingStartHour(p_lot_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE v_hour INT;

  SELECT HOUR(b.start_time)
    INTO v_hour
    FROM bookings b
    JOIN parking_slots ps ON b.slot_id = ps.slot_id
    WHERE ps.lot_id = p_lot_id
    GROUP BY HOUR(b.start_time)
    ORDER BY COUNT(*) DESC
    LIMIT 1;

  RETURN v_hour;
END;
//
DELIMITER ;

-- ----------------------------------------------------------------------------------
-- ---------------------------Triggers--------------------
-- 1. After a booking is created, mark the slot & sensor and decrement availability
-- Author: Arun Anantharam Bagade

DELIMITER //
CREATE TRIGGER trg_after_booking_insert
AFTER INSERT ON bookings
FOR EACH ROW
BEGIN
  -- audit the successful insert
  INSERT INTO bookings_audit
    (booking_id, user_id, slot_id, vehicle_id, start_time, end_time, status, action, action_timestamp)
  VALUES
    (NEW.booking_id,
     NEW.user_id,
     NEW.slot_id,
     NEW.vehicle_id,
     NEW.start_time,
     NEW.end_time,
     NEW.status,
     'AFTER_INSERT',
     NOW());

  -- post‐insert logic
  UPDATE parking_slots
    SET is_available = FALSE
    WHERE slot_id = NEW.slot_id;

  UPDATE parking_lots pl
    JOIN parking_slots ps ON pl.lot_id = ps.lot_id
    SET pl.available_slots = pl.available_slots - 1
    WHERE ps.slot_id = NEW.slot_id;

  UPDATE parking_sensors
    SET status = 'occupied',
		last_updated = now()
    WHERE slot_id = NEW.slot_id;
END;
//
DELIMITER ;


-- 2. When a sensor flips from occupied→vacant, finalize any active booking
-- Author: Amani Alwala

DELIMITER //
CREATE TRIGGER trg_before_sensor_update
BEFORE UPDATE ON parking_sensors
FOR EACH ROW
BEGIN
  -- audit the sensor status change
  INSERT INTO parking_sensors_audit
    (sensor_id, slot_id, old_status, new_status, action, action_timestamp)
  VALUES
    (OLD.sensor_id,
     OLD.slot_id,
     OLD.status,
     NEW.status,
     'BEFORE_UPDATE',
     NOW());

  -- complete any active booking
  IF OLD.status = 'occupied' AND NEW.status = 'vacant' THEN
    UPDATE bookings
      SET end_time = NOW(),
          status   = 'completed'
      WHERE slot_id = OLD.slot_id
        AND status  = 'active';
  END IF;
END;
//

DELIMITER ;

-- 3. Scan for unauthorized parking, log into violations.
-- Author: Shivangi Jaiswal

DELIMITER //
CREATE TRIGGER trg_after_sensor_update_violation
AFTER UPDATE ON parking_sensors
FOR EACH ROW
BEGIN
  DECLARE activeBookingCount INT DEFAULT 0;

  -- Only check if the slot is occupied
  IF NEW.status = 'occupied' THEN
    
    -- Check if there is an active or pending booking for the slot
    SELECT COUNT(*)
    INTO activeBookingCount
    FROM bookings
    WHERE slot_id = NEW.slot_id
      AND status IN ('pending', 'active')
      AND NOW() BETWEEN start_time AND end_time;
    
    -- If no active booking, insert an unauthorized parking violation
    IF activeBookingCount = 0 THEN
      INSERT INTO violations
        (vehicle_id, lot_id, violation_type, timestamp)
      VALUES
        ( 1,  -- vehicle_id unknown if no booking
         1,
         'unauthorized_entry',
         NOW());
    END IF;
    
  END IF;
END;
DELIMITER ;

-- 4. When a booking’s status flips to reserved, for post-paid, auto‑insert a pending payment record
-- Author: Parthan Patel

DELIMITER //
CREATE TRIGGER trg_after_booking_complete
AFTER UPDATE ON bookings
FOR EACH ROW
BEGIN
  IF ( @skip_booking_complete IS NULL OR @skip_booking_complete = FALSE )
     AND OLD.status <> 'reserved'
     AND NEW.status = 'reserved'
  THEN
    INSERT INTO payments (
      booking_id,
      amount,
      payment_status,
      payment_method
    )
    VALUES (
      NEW.booking_id,
      GetBookingDuration(NEW.booking_id) * 1,
      'pending',
      'digital_wallet'
    );
  END IF;
END;
//
DELIMITER ;

-- 5. For case where booking is done, but payment is made some time later, update the corresponding booking
-- Author: Yidi Li

DELIMITER //
CREATE TRIGGER trg_after_payment_insert
AFTER INSERT ON payments
FOR EACH ROW
BEGIN
  -- audit the insertion
  INSERT INTO payments_audit
    (payment_id, booking_id, amount,
     payment_status, payment_method,
     transaction_date, action, action_timestamp)
  VALUES
    (NEW.payment_id,
     NEW.booking_id,
     NEW.amount,
     NEW.payment_status,
     NEW.payment_method,
     NEW.transaction_date,
     'AFTER_INSERT',
     NOW());

  -- update booking status, but tell the booking trigger not to fire its own payments‑insert
  IF NEW.payment_status = 'completed' THEN
    SET @skip_booking_complete = TRUE;
      UPDATE bookings
        SET status = 'active'
      WHERE booking_id = NEW.booking_id;
    SET @skip_booking_complete = FALSE;
  ELSEIF NEW.payment_status = 'failed' THEN
    SET @skip_booking_complete = TRUE;
      UPDATE bookings
        SET status = 'canceled'
      WHERE booking_id = NEW.booking_id;
    SET @skip_booking_complete = FALSE;
  END IF;
END;
//
DELIMITER ;
-- ------------------------------------------------------------------------
-- ------------------------------------------------------------------------

/*
------------------------------------------------------------------------------------------
Insert Data into new tables
*/
/* Author: Amani Alwala */
INSERT INTO users (first_name, last_name, email, phone, password_hash, user_type)
VALUES
('John', 'Doe', 'johndoe@mail.com', '1234567890', '1234567890', 'customer'),
('Jane', 'Smith', 'janesmith@mail.com', '0987654321', '0987654321', 'customer'),
('Alice', 'Johnson', 'alicej@mail.com', '1231231234', '1231231234', 'customer'),
('Bob', 'Brown', 'bobb@mail.com', '2342342345', '2342342345', 'customer'),
('Charlie', 'Davis', 'charlied@mail.com', '3453453456', '3453453456', 'customer'),
('Michael', 'Smith', 'michael@parkatease.com', '5551234567', '5551234567', 'admin'),
('Kevin', 'Matt', 'kevin@parkatease.com', '5554567891', '5554567891', 'admin')
;

/* Author: Amani Alwala */
INSERT INTO vehicles (user_id, license_plate, vehicle_type)
VALUES
(1, 'AB123CD', 'car'),
(2, 'XY456ZP', 'bike'),
(3, 'LM789OP', 'electric'),
(4, 'ST012UV', 'truck'),
(5, 'GH345IJ', 'car')
;

/* Author: Amani Alwala */
INSERT INTO parking_lots (lot_name, location, total_slots, available_slots)
VALUES
('Lot A', '123 Elm Street', 100, 80),
('Lot B', '456 Pine Avenue', 150, 120),
('Lot C', '789 Maple Drive', 200, 150)
;

/* Author: Arun Anantharam Bagade */
INSERT INTO parking_slots (lot_id, slot_number, slot_type, is_available)
VALUES
(1, '1', 'regular', TRUE),
(1, '2', 'compact', FALSE),
(1, '3', 'electric', TRUE),
(1, '4', 'regular', TRUE),
(1, '5', 'handicapped', FALSE)
;

/* Author: Arun Anantharam Bagade */
INSERT INTO bookings (user_id, slot_id, vehicle_id, start_time, end_time, status)
VALUES
(1, 1, 1, '2025-04-28 09:00:00', '2025-04-28 12:00:00', 'completed'),
(2, 2, 2, '2025-04-28 10:00:00', '2025-04-28 14:00:00', 'active'),
(3, 3, 3, '2025-04-28 11:00:00', '2025-04-28 13:00:00', 'pending'),
(4, 4, 3, '2025-04-28 11:00:00', '2025-04-28 14:00:00', 'pending'),
(5, 5, 5, '2025-04-28 12:00:00', '2025-04-28 15:00:00', 'active')  
;

/* Author: Arun Anantharam Bagade */
INSERT INTO parking_sensors (slot_id, status, last_updated)
VALUES
(1, 'vacant', '2025-03-21 12:00:00'),
(2, 'occupied', '2025-03-21 12:30:00'),
(3, 'vacant', '2025-03-21 13:00:00'),
(4, 'vacant', '2025-03-21 14:00:00'),
(5, 'occupied', '2025-03-21 15:00:00')
;

/* Author: Shivangi Jaiswal */
INSERT INTO payments (booking_id, amount, payment_status, payment_method)
VALUES
(1, 25.00, 'completed', 'credit_card'),
(2, 40.00, 'pending', 'debit_card'),
(3, 50.00, 'failed', 'digital_wallet'),
(4, 30.00, 'completed', 'cash'),
(5, 20.00, 'refunded', 'credit_card')
;

/* Author: Shivangi Jaiswal */
INSERT INTO access_control (user_id, vehicle_id, access_token, status)
VALUES
(1, 1, 'TOKEN12345', 'active'),
(2, 2, 'TOKEN67890', 'expired'),
(3, 3, 'TOKEN11223', 'revoked'),
(4, 4, 'TOKEN44556', 'active'),
(5, 5, 'TOKEN78901', 'active')
;

/* Author: Shivangi Jaiswal */
INSERT INTO logs (vehicle_id, lot_id, entry_time, exit_time)
VALUES
(1, 1, '2025-03-21 09:00:00', '2025-03-21 12:00:00'),
(2, 1, '2025-03-21 10:00:00', NULL),
(3, 2, '2025-03-21 11:00:00', '2025-03-21 14:00:00'),
(4, 3, '2025-03-21 12:00:00', NULL),
(5, 1, '2025-03-21 13:00:00', '2025-03-21 15:00:00') 
;

/* Author: Yidi Li */
INSERT INTO violations (vehicle_id, lot_id, violation_type, timestamp)
VALUES
(1, 1, 'no_booking', '2025-03-21 09:30:00'),
(2, 2, 'unauthorized_entry', '2025-03-21 10:15:00'),
(3, 3, 'overstay', '2025-03-21 14:10:00'),
(4, 1, 'no_booking', '2025-03-21 15:00:00'),
(5, 2, 'unauthorized_entry', '2025-03-21 15:30:00') 
;

/* Author: Yidi Li */
INSERT INTO staff (lot_id, first_name, last_name, role, phone, email)
VALUES
(1, 'Michael', 'Smith', 'manager', '5551234567', 'michael@parkatease.com'),
(1, 'Jim', 'Scott', 'security', '5559876543', 'jim@parkatease.com'),
(1, 'Pam', 'Brook', 'maintenance', '5555432167', 'pam@parkatease.com'),
(1, 'Dwight', 'Ponting', 'security', '5556781234', 'dwight@parkatease.com'),
(1, 'Kevin', 'Matt', 'manager', '5554567891', 'kevin@parkatease.com')
;

/* Author: Yidi Li */
INSERT INTO subscription_plans (plan_name, price, duration_days)
VALUES
('Basic Plan', 50.00, 30),
('Standard Plan', 100.00, 60),
('Premium Plan', 150.00, 90),
('Family Plan', 200.00, 120),
('Corporate Plan', 300.00, 180)
;

/* Author: Parthan Patel */
INSERT INTO user_subscriptions (user_id, plan_id, start_date, end_date, status)
VALUES
(1, 1, '2025-03-01', '2025-03-31', 'active'),
(2, 2, '2025-02-01', '2025-03-31', 'expired'),
(3, 3, '2025-01-01', '2025-04-01', 'canceled'),
(4, 4, '2025-03-15', '2025-07-15', 'active'),
(5, 5, '2025-01-01', '2025-06-30', 'active')
;

/* Author: Parthan Patel */
INSERT INTO discounts (code, discount_percentage, expiry_date)
VALUES
('DISC10', 10.00, '2025-12-31'),
('SAVE20', 20.00, '2025-06-30'),
('PROMO30', 30.00, '2025-03-31'),
('OFF50', 50.00, '2025-04-30'),
('SPRING15', 15.00, '2025-05-15')
;

/* Author: Parthan Patel */
INSERT INTO booking_discounts (booking_id, discount_id)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5)
;

INSERT INTO users (first_name, last_name, email, phone, password_hash, user_type, created_at) VALUES ('Mike', 'Williams', 'mike.williams81@mail.com', '+1-479-485-5795', 'dummyhash1', 'admin', '2024-09-19 00:55:49');
INSERT INTO users (first_name, last_name, email, phone, password_hash, user_type, created_at) VALUES ('Tom', 'Wilson', 'tom.wilson75@parkatease.com', '+1-348-578-6727', 'dummyhash2', 'admin', '2024-08-03 00:55:49');
INSERT INTO users (first_name, last_name, email, phone, password_hash, user_type, created_at) VALUES ('Jane', 'Miller', 'jane.miller79@parkatease.com', '+1-766-510-8121', 'dummyhash3', 'admin', '2024-05-09 00:55:49');
INSERT INTO users (first_name, last_name, email, phone, password_hash, user_type, created_at) VALUES ('Robert', 'Smith', 'robert.smith89@mail.com', '+1-345-986-6021', 'dummyhash4', 'customer', '2024-11-21 00:55:49');
INSERT INTO users (first_name, last_name, email, phone, password_hash, user_type, created_at) VALUES ('John', 'Miller', 'john.miller99@parkatease.com', '+1-561-345-6158', 'dummyhash5', 'admin', '2024-11-29 00:55:49');
INSERT INTO users (first_name, last_name, email, phone, password_hash, user_type, created_at) VALUES ('Sara', 'Johnson', 'sara.johnson20@parkatease.com', '+1-852-764-9216', 'dummyhash6', 'admin', '2024-08-11 00:55:49');
INSERT INTO users (first_name, last_name, email, phone, password_hash, user_type, created_at) VALUES ('Sara', 'Brown', 'sara.brown23@mail.com', '+1-847-835-8122', 'dummyhash7', 'customer', '2024-06-05 00:55:49');
INSERT INTO users (first_name, last_name, email, phone, password_hash, user_type, created_at) VALUES ('Chris', 'Smith', 'chris.smith8@mail.com', '+1-595-572-1405', 'dummyhash8', 'customer', '2024-06-20 00:55:49');
INSERT INTO users (first_name, last_name, email, phone, password_hash, user_type, created_at) VALUES ('Jane', 'Smith', 'jane.smith39@parkatease.com', '+1-561-216-4494', 'dummyhash9', 'admin', '2024-09-21 00:55:49');
INSERT INTO users (first_name, last_name, email, phone, password_hash, user_type, created_at) VALUES ('John', 'Smith', 'john.smith97@parkatease.com', '+1-949-448-2924', 'dummyhash10', 'admin', '2024-12-01 00:55:49');
INSERT INTO vehicles (user_id, license_plate, vehicle_type) VALUES (10, 'XYZ2318', 'bike');
INSERT INTO vehicles (user_id, license_plate, vehicle_type) VALUES (8, 'XYZ3395', 'truck');
INSERT INTO vehicles (user_id, license_plate, vehicle_type) VALUES (6, 'XYZ9021', 'bike');
INSERT INTO vehicles (user_id, license_plate, vehicle_type) VALUES (8, 'XYZ2205', 'bike');
INSERT INTO vehicles (user_id, license_plate, vehicle_type) VALUES (2, 'XYZ7388', 'truck');
INSERT INTO vehicles (user_id, license_plate, vehicle_type) VALUES (3, 'XYZ1525', 'truck');
INSERT INTO vehicles (user_id, license_plate, vehicle_type) VALUES (7, 'XYZ3036', 'bike');
INSERT INTO vehicles (user_id, license_plate, vehicle_type) VALUES (7, 'XYZ7674', 'electric');
INSERT INTO vehicles (user_id, license_plate, vehicle_type) VALUES (9, 'XYZ4826', 'car');
INSERT INTO vehicles (user_id, license_plate, vehicle_type) VALUES (10, 'XYZ9661', 'car');
INSERT INTO parking_slots (lot_id, slot_number, slot_type, is_available) VALUES (2, '6', 'handicapped', 1);
INSERT INTO parking_slots (lot_id, slot_number, slot_type, is_available) VALUES (2, '7', 'handicapped', 1);
INSERT INTO parking_slots (lot_id, slot_number, slot_type, is_available) VALUES (2, '8', 'handicapped', 1);
INSERT INTO parking_slots (lot_id, slot_number, slot_type, is_available) VALUES (2, '9', 'compact', 0);
INSERT INTO parking_slots (lot_id, slot_number, slot_type, is_available) VALUES (2, '10', 'compact', 1);
INSERT INTO parking_slots (lot_id, slot_number, slot_type, is_available) VALUES (3, '11', 'compact', 1);
INSERT INTO parking_slots (lot_id, slot_number, slot_type, is_available) VALUES (3, '12', 'compact', 1);
INSERT INTO parking_slots (lot_id, slot_number, slot_type, is_available) VALUES (3, '13', 'electric', 0);
INSERT INTO parking_slots (lot_id, slot_number, slot_type, is_available) VALUES (3, '14', 'regular', 0);
INSERT INTO parking_slots (lot_id, slot_number, slot_type, is_available) VALUES (3, '15', 'regular', 0);
INSERT INTO parking_sensors (slot_id, status, last_updated) VALUES (5, 'occupied', '2025-02-20 00:55:49');
INSERT INTO parking_sensors (slot_id, status, last_updated) VALUES (7, 'occupied', '2025-04-09 00:55:49');
INSERT INTO parking_sensors (slot_id, status, last_updated) VALUES (9, 'occupied', '2025-03-20 00:55:49');
INSERT INTO parking_sensors (slot_id, status, last_updated) VALUES (8, 'vacant', '2024-05-29 00:55:49');
INSERT INTO parking_sensors (slot_id, status, last_updated) VALUES (1, 'vacant', '2024-09-09 00:55:49');
INSERT INTO parking_sensors (slot_id, status, last_updated) VALUES (10, 'occupied', '2024-08-11 00:55:49');
INSERT INTO parking_sensors (slot_id, status, last_updated) VALUES (5, 'occupied', '2024-07-28 00:55:49');
INSERT INTO parking_sensors (slot_id, status, last_updated) VALUES (1, 'vacant', '2024-05-20 00:55:49');
INSERT INTO parking_sensors (slot_id, status, last_updated) VALUES (2, 'vacant', '2024-07-15 00:55:49');
INSERT INTO parking_sensors (slot_id, status, last_updated) VALUES (4, 'occupied', '2025-02-20 00:55:49');
INSERT INTO bookings (user_id, slot_id, vehicle_id, start_time, end_time, status) VALUES (9, 6, 6, '2024-05-29 00:55:49', '2025-04-26 02:55:49', 'active');
INSERT INTO bookings (user_id, slot_id, vehicle_id, start_time, end_time, status) VALUES (5, 7, 4, '2025-04-10 00:55:49', '2025-04-26 01:55:49', 'completed');
INSERT INTO bookings (user_id, slot_id, vehicle_id, start_time, end_time, status) VALUES (7, 8, 7, '2025-01-13 00:55:49', '2025-04-26 05:55:49', 'canceled');
INSERT INTO bookings (user_id, slot_id, vehicle_id, start_time, end_time, status) VALUES (2, 9, 4, '2025-04-10 00:55:49', '2025-04-26 01:55:49', 'pending');
INSERT INTO bookings (user_id, slot_id, vehicle_id, start_time, end_time, status) VALUES (5, 10, 8, '2025-03-17 00:55:49', '2025-04-26 01:55:49', 'pending');
INSERT INTO bookings (user_id, slot_id, vehicle_id, start_time, end_time, status) VALUES (4, 11, 4, '2024-06-12 00:55:49', '2025-04-26 04:55:49', 'completed');
INSERT INTO bookings (user_id, slot_id, vehicle_id, start_time, end_time, status) VALUES (7, 12, 5, '2025-03-20 00:55:49', '2025-04-26 04:55:49', 'pending');
INSERT INTO bookings (user_id, slot_id, vehicle_id, start_time, end_time, status) VALUES (9, 13, 6, '2025-04-11 00:55:49', '2025-04-26 03:55:49', 'active');
INSERT INTO bookings (user_id, slot_id, vehicle_id, start_time, end_time, status) VALUES (4, 14, 10, '2025-01-24 00:55:49', '2025-04-26 04:55:49', 'active');
INSERT INTO payments (booking_id, amount, payment_status, payment_method, transaction_date) VALUES (6, 15.49, 'failed', 'cash', '2024-09-24 00:55:49');
INSERT INTO payments (booking_id, amount, payment_status, payment_method, transaction_date) VALUES (7, 69.16, 'completed', 'digital_wallet', '2025-04-17 00:55:49');
INSERT INTO payments (booking_id, amount, payment_status, payment_method, transaction_date) VALUES (8, 59.41, 'pending', 'debit_card', '2024-05-09 00:55:49');
INSERT INTO payments (booking_id, amount, payment_status, payment_method, transaction_date) VALUES (9, 37.97, 'completed', 'digital_wallet', '2024-04-26 00:55:49');
INSERT INTO payments (booking_id, amount, payment_status, payment_method, transaction_date) VALUES (10, 48.2, 'completed', 'digital_wallet', '2024-07-14 00:55:49');
INSERT INTO payments (booking_id, amount, payment_status, payment_method, transaction_date) VALUES (11, 89.04, 'completed', 'credit_card', '2025-03-18 00:55:49');
INSERT INTO payments (booking_id, amount, payment_status, payment_method, transaction_date) VALUES (12, 50.8, 'completed', 'debit_card', '2025-03-21 00:55:49');
INSERT INTO payments (booking_id, amount, payment_status, payment_method, transaction_date) VALUES (13, 17.8, 'completed', 'credit_card', '2024-11-04 00:55:49');
INSERT INTO payments (booking_id, amount, payment_status, payment_method, transaction_date) VALUES (14, 70.17, 'completed', 'cash', '2025-04-09 00:55:49');
INSERT INTO access_control (user_id, vehicle_id, access_token, status, created_at) VALUES (2, 6, 'token_6686', 'expired', '2024-08-29 00:55:49');
INSERT INTO access_control (user_id, vehicle_id, access_token, status, created_at) VALUES (3, 4, 'token_1530', 'expired', '2024-08-09 00:55:49');
INSERT INTO access_control (user_id, vehicle_id, access_token, status, created_at) VALUES (1, 4, 'token_2777', 'active', '2025-03-24 00:55:49');
INSERT INTO access_control (user_id, vehicle_id, access_token, status, created_at) VALUES (1, 3, 'token_2635', 'active', '2024-08-08 00:55:49');
INSERT INTO access_control (user_id, vehicle_id, access_token, status, created_at) VALUES (5, 8, 'token_2970', 'expired', '2024-10-04 00:55:49');
INSERT INTO access_control (user_id, vehicle_id, access_token, status, created_at) VALUES (3, 10, 'token_9267', 'active', '2024-11-25 00:55:49');
INSERT INTO access_control (user_id, vehicle_id, access_token, status, created_at) VALUES (9, 4, 'token_9981', 'expired', '2024-05-04 00:55:49');
INSERT INTO access_control (user_id, vehicle_id, access_token, status, created_at) VALUES (6, 8, 'token_7545', 'active', '2025-03-27 00:55:49');
INSERT INTO access_control (user_id, vehicle_id, access_token, status, created_at) VALUES (5, 4, 'token_3927', 'active', '2025-03-22 00:55:49');
INSERT INTO access_control (user_id, vehicle_id, access_token, status, created_at) VALUES (9, 2, 'token_8346', 'revoked', '2024-10-18 00:55:49');
INSERT INTO logs (vehicle_id, lot_id, entry_time, exit_time) VALUES (7, 3, '2025-01-18 00:55:49', '2025-04-26 02:55:49');
INSERT INTO logs (vehicle_id, lot_id, entry_time, exit_time) VALUES (9, 3, '2025-02-04 00:55:49', '2025-04-26 05:55:49');
INSERT INTO logs (vehicle_id, lot_id, entry_time, exit_time) VALUES (10, 2, '2024-08-17 00:55:49', '2025-04-26 04:55:49');
INSERT INTO logs (vehicle_id, lot_id, entry_time, exit_time) VALUES (5, 1, '2024-09-10 00:55:49', '2025-04-26 03:55:49');
INSERT INTO logs (vehicle_id, lot_id, entry_time, exit_time) VALUES (5, 2, '2025-01-13 00:55:49', '2025-04-26 03:55:49');
INSERT INTO logs (vehicle_id, lot_id, entry_time, exit_time) VALUES (2, 1, '2025-04-12 00:55:49', '2025-04-26 03:55:49');
INSERT INTO logs (vehicle_id, lot_id, entry_time, exit_time) VALUES (8, 3, '2025-02-24 00:55:49', '2025-04-26 03:55:49');
INSERT INTO logs (vehicle_id, lot_id, entry_time, exit_time) VALUES (5, 2, '2024-11-19 00:55:49', '2025-04-26 03:55:49');
INSERT INTO logs (vehicle_id, lot_id, entry_time, exit_time) VALUES (10, 3, '2025-03-22 00:55:49', '2025-04-26 03:55:49');
INSERT INTO logs (vehicle_id, lot_id, entry_time, exit_time) VALUES (9, 1, '2024-11-22 00:55:49', '2025-04-26 02:55:49');
INSERT INTO violations (vehicle_id, lot_id, violation_type, timestamp) VALUES (3, 1, 'unauthorized_entry', '2024-08-11 00:55:49');
INSERT INTO violations (vehicle_id, lot_id, violation_type, timestamp) VALUES (9, 2, 'no_booking', '2025-01-12 00:55:49');
INSERT INTO violations (vehicle_id, lot_id, violation_type, timestamp) VALUES (8, 2, 'overstay', '2024-07-16 00:55:49');
INSERT INTO violations (vehicle_id, lot_id, violation_type, timestamp) VALUES (7, 3, 'overstay', '2025-04-22 00:55:49');
INSERT INTO violations (vehicle_id, lot_id, violation_type, timestamp) VALUES (10, 1, 'no_booking', '2024-04-28 00:55:49');
INSERT INTO violations (vehicle_id, lot_id, violation_type, timestamp) VALUES (5, 3, 'no_booking', '2024-10-17 00:55:49');
INSERT INTO violations (vehicle_id, lot_id, violation_type, timestamp) VALUES (4, 1, 'unauthorized_entry', '2024-06-30 00:55:49');
INSERT INTO violations (vehicle_id, lot_id, violation_type, timestamp) VALUES (5, 2, 'no_booking', '2024-09-15 00:55:49');
INSERT INTO violations (vehicle_id, lot_id, violation_type, timestamp) VALUES (9, 2, 'overstay', '2024-05-17 00:55:49');
INSERT INTO violations (vehicle_id, lot_id, violation_type, timestamp) VALUES (9, 2, 'no_booking', '2024-11-16 00:55:49');
INSERT INTO staff (lot_id, first_name, last_name, role, phone, email) VALUES (2, 'John', 'Smith', 'maintenance', '+1-940-412-8475', 'john.smith59@parkatease.com');
INSERT INTO staff (lot_id, first_name, last_name, role, phone, email) VALUES (2, 'Lily', 'Jones', 'Security', '+1-573-245-9180', 'lily.jones72@parkatease.com');
INSERT INTO staff (lot_id, first_name, last_name, role, phone, email) VALUES (2, 'Sara', 'Jones', 'Security', '+1-509-602-8567', 'sara.jones28@parkatease.com');
INSERT INTO staff (lot_id, first_name, last_name, role, phone, email) VALUES (2, 'Robert', 'Taylor', 'maintenance', '+1-542-448-4086', 'robert.taylor26@parkatease.com');
INSERT INTO staff (lot_id, first_name, last_name, role, phone, email) VALUES (2, 'Emma', 'Jones', 'Manager', '+1-453-218-3515', 'emma.jones39@parkatease.com');
INSERT INTO staff (lot_id, first_name, last_name, role, phone, email) VALUES (3, 'Chris', 'Williams', 'maintenance', '+1-311-159-8155', 'chris.williams45@parkatease.com');
INSERT INTO staff (lot_id, first_name, last_name, role, phone, email) VALUES (3, 'Mike', 'Johnson', 'Manager', '+1-893-554-4250', 'mike.johnson94@parkatease.com');
INSERT INTO staff (lot_id, first_name, last_name, role, phone, email) VALUES (3, 'Robert', 'Brown', 'Manager', '+1-252-420-4571', 'robert.brown72@parkatease.com');
INSERT INTO staff (lot_id, first_name, last_name, role, phone, email) VALUES (3, 'Tom', 'Smith', 'Security', '+1-476-271-7999', 'tom.smith77@parkatease.com');
INSERT INTO staff (lot_id, first_name, last_name, role, phone, email) VALUES (3, 'Robert', 'Davis', 'maintenance', '+1-808-185-7174', 'robert.davis51@parkatease.com');
INSERT INTO subscription_plans (plan_name, price, duration_days) VALUES ('Basic', 91, 365);
INSERT INTO subscription_plans (plan_name, price, duration_days) VALUES ('Premium', 37, 30);
INSERT INTO subscription_plans (plan_name, price, duration_days) VALUES ('VIP', 171, 180);
INSERT INTO subscription_plans (plan_name, price, duration_days) VALUES ('Weekend', 143, 365);
INSERT INTO subscription_plans (plan_name, price, duration_days) VALUES ('Monthly', 70, 180);
INSERT INTO subscription_plans (plan_name, price, duration_days) VALUES ('Quarterly', 26, 30);
INSERT INTO subscription_plans (plan_name, price, duration_days) VALUES ('Yearly', 141, 365);
INSERT INTO subscription_plans (plan_name, price, duration_days) VALUES ('Family', 47, 365);
INSERT INTO subscription_plans (plan_name, price, duration_days) VALUES ('Business', 193, 365);
INSERT INTO subscription_plans (plan_name, price, duration_days) VALUES ('Student', 102, 365);
INSERT INTO user_subscriptions (user_id, plan_id, start_date, end_date, status) VALUES (2, 5, '2024-05-13', '2025-07-16', 'active');
INSERT INTO user_subscriptions (user_id, plan_id, start_date, end_date, status) VALUES (4, 4, '2024-09-26', '2025-09-26', 'canceled');
INSERT INTO user_subscriptions (user_id, plan_id, start_date, end_date, status) VALUES (3, 4, '2024-12-08', '2026-04-19', 'canceled');
INSERT INTO user_subscriptions (user_id, plan_id, start_date, end_date, status) VALUES (7, 1, '2025-01-26', '2025-05-29', 'active');
INSERT INTO user_subscriptions (user_id, plan_id, start_date, end_date, status) VALUES (10, 8, '2025-04-17', '2026-01-02', 'expired');
INSERT INTO user_subscriptions (user_id, plan_id, start_date, end_date, status) VALUES (1, 3, '2024-11-02', '2025-10-27', 'active');
INSERT INTO user_subscriptions (user_id, plan_id, start_date, end_date, status) VALUES (9, 4, '2025-01-01', '2025-06-06', 'active');
INSERT INTO user_subscriptions (user_id, plan_id, start_date, end_date, status) VALUES (9, 6, '2024-07-22', '2025-08-01', 'active');
INSERT INTO user_subscriptions (user_id, plan_id, start_date, end_date, status) VALUES (6, 1, '2024-06-27', '2026-02-10', 'expired');
INSERT INTO user_subscriptions (user_id, plan_id, start_date, end_date, status) VALUES (4, 8, '2025-01-19', '2025-06-21', 'expired');
INSERT INTO discounts (code, discount_percentage, expiry_date) VALUES ('DISC5', 55, '2025-07-29');
INSERT INTO discounts (code, discount_percentage, expiry_date) VALUES ('SAVE10', 25, '2026-01-22');
INSERT INTO discounts (code, discount_percentage, expiry_date) VALUES ('HOLIDAY15', 10, '2025-11-18');
INSERT INTO discounts (code, discount_percentage, expiry_date) VALUES ('SPRING20', 46, '2025-12-04');
INSERT INTO discounts (code, discount_percentage, expiry_date) VALUES ('FALL25', 22, '2025-12-16');
INSERT INTO discounts (code, discount_percentage, expiry_date) VALUES ('WINTER30', 61, '2026-02-20');
INSERT INTO discounts (code, discount_percentage, expiry_date) VALUES ('BLACKFRIDAY40', 69, '2026-02-24');
INSERT INTO discounts (code, discount_percentage, expiry_date) VALUES ('CYBER50', 64, '2025-07-14');
INSERT INTO discounts (code, discount_percentage, expiry_date) VALUES ('NEWYEAR60', 26, '2025-08-02');
INSERT INTO discounts (code, discount_percentage, expiry_date) VALUES ('WELCOME70', 27, '2026-02-19');
INSERT INTO booking_discounts (booking_id, discount_id) VALUES (6, 9);
INSERT INTO booking_discounts (booking_id, discount_id) VALUES (4, 10);
INSERT INTO booking_discounts (booking_id, discount_id) VALUES (10, 7);
INSERT INTO booking_discounts (booking_id, discount_id) VALUES (5, 9);
INSERT INTO booking_discounts (booking_id, discount_id) VALUES (7, 7);
INSERT INTO booking_discounts (booking_id, discount_id) VALUES (8, 9);
INSERT INTO booking_discounts (booking_id, discount_id) VALUES (3, 10);
INSERT INTO booking_discounts (booking_id, discount_id) VALUES (5, 2);
INSERT INTO booking_discounts (booking_id, discount_id) VALUES (4, 10);
INSERT INTO booking_discounts (booking_id, discount_id) VALUES (3, 6);
