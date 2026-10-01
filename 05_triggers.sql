/* ============================================================================
   FILE 5 : 05_triggers.sql
   REAL ESTATE MANAGEMENT SYSTEM (RESM) — TRIGGERS (MySQL syntax)
   ============================================================================ */

DROP TRIGGER IF EXISTS trg_property_status_update;
DROP TRIGGER IF EXISTS trg_payment_limit_check;
DROP TRIGGER IF EXISTS trg_default_request_date;

DELIMITER $$

-- Trigger 1: contract creation flips property status automatically
CREATE TRIGGER trg_property_status_update
AFTER INSERT ON CONTRACT
FOR EACH ROW
BEGIN
    UPDATE PROPERTY
    SET status = CASE WHEN NEW.contract_type = 'SALE' THEN 'SOLD' ELSE 'RENTED' END
    WHERE property_id = NEW.property_id;
END$$

-- Trigger 2: block a payment that would exceed the contract's agreed amount
CREATE TRIGGER trg_payment_limit_check
BEFORE INSERT ON PAYMENT
FOR EACH ROW
BEGIN
    DECLARE v_contract_amt DECIMAL(12,2);
    DECLARE v_paid_so_far  DECIMAL(12,2);

    SELECT amount INTO v_contract_amt
    FROM CONTRACT
    WHERE contract_id = NEW.contract_id;

    SELECT IFNULL(SUM(amount), 0) INTO v_paid_so_far
    FROM PAYMENT
    WHERE contract_id = NEW.contract_id;

    IF (v_paid_so_far + NEW.amount) > v_contract_amt THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payment exceeds outstanding contract amount.';
    END IF;
END$$

-- Trigger 3: default a maintenance request's date to today if left blank
CREATE TRIGGER trg_default_request_date
BEFORE INSERT ON MAINTENANCE_REQUEST
FOR EACH ROW
BEGIN
    IF NEW.request_date IS NULL THEN
        SET NEW.request_date = CURDATE();
    END IF;
END$$

DELIMITER ;

SELECT *FROM AGENT;
SELECT *FROM CLIENT;
