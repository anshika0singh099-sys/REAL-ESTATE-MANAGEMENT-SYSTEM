/* ============================================================================
   REAL ESTATE MANAGEMENT SYSTEM (RESM)
   ============================================================================ */
   
CREATE DATABASE REAL_ESTATE;
USE REAL_ESTATE;

-- 0. Safe re-run: drop child tables before parent tables
DROP TABLE FEEDBACK;
DROP TABLE MAINTENANCE_REQUEST;
DROP TABLE PAYMENT_INSTALLMENT;
DROP TABLE PAYMENT;
DROP TABLE CONTRACT;
DROP TABLE PROPERTY_IMAGE;
DROP TABLE PROPERTY;
DROP TABLE PROPERTY_TYPE;
DROP TABLE AGENT;
DROP TABLE CLIENT;
DROP TABLE OWNER;

-- ---------------------------------------------------------------------------
-- 1. MAIN ENTITIES
-- ---------------------------------------------------------------------------
CREATE TABLE OWNER (
    owner_id INT PRIMARY KEY,
    owner_name VARCHAR(80) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    address VARCHAR(150),
    CONSTRAINT chk_owner_phone CHECK (LENGTH(phone) >= 10)
);

CREATE TABLE AGENT (
    agent_id INT PRIMARY KEY,
    agent_name VARCHAR(80) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100)  UNIQUE,
    commission_rate DECIMAL(4,2) DEFAULT 2.00 CHECK (commission_rate BETWEEN 0 AND 10),
    hire_date DATE DEFAULT (CURRENT_DATE)
);

CREATE TABLE CLIENT (
    client_id     INT           PRIMARY KEY,
    client_name   VARCHAR(80)   NOT NULL,
    phone         VARCHAR(15)   NOT NULL UNIQUE,
    email         VARCHAR(100)  UNIQUE,
    address       VARCHAR(150),
    client_type   VARCHAR(10)   NOT NULL CHECK (client_type IN ('BUYER','TENANT'))
);

CREATE TABLE PROPERTY_TYPE (
    type_id     INT           PRIMARY KEY,
    type_name   VARCHAR(30)   NOT NULL UNIQUE
);

CREATE TABLE PROPERTY (
    property_id   INT             PRIMARY KEY,
    title         VARCHAR(120)    NOT NULL,
    type_id       INT             NOT NULL,
    address       VARCHAR(150)    NOT NULL,
    city          VARCHAR(50)     NOT NULL,
    state         VARCHAR(50)     NOT NULL,
    zip_code      VARCHAR(10),
    area_sqft     DECIMAL(10,2)   CHECK (area_sqft > 0),
    price         DECIMAL(12,2)   NOT NULL CHECK (price > 0),
    status        VARCHAR(12)     DEFAULT 'AVAILABLE'  CHECK (status IN ('AVAILABLE','BOOKED','SOLD','RENTED')),
    listed_date   DATE            DEFAULT  (CURRENT_DATE),
    owner_id      INT             NOT NULL,
    agent_id      INT,
    CONSTRAINT fk_prop_owner FOREIGN KEY (owner_id) REFERENCES OWNER(owner_id) ON DELETE CASCADE,
    CONSTRAINT fk_prop_agent FOREIGN KEY (agent_id) REFERENCES AGENT(agent_id) ON DELETE SET NULL,
    CONSTRAINT fk_prop_type  FOREIGN KEY (type_id)  REFERENCES PROPERTY_TYPE(type_id)
);

-- ---------------------------------------------------------------------------
-- 2. WEAK ENTITIES (composite PK = owner entity's key + partial key)
-- ---------------------------------------------------------------------------
CREATE TABLE PROPERTY_IMAGE (
    property_id   INT           NOT NULL,
    image_seq     INT           NOT NULL,       -- partial/discriminator key
    image_url     VARCHAR(200)  NOT NULL,
    uploaded_on   DATE          DEFAULT (CURRENT_DATE),
    CONSTRAINT pk_property_image PRIMARY KEY (property_id, image_seq),
    CONSTRAINT fk_image_property FOREIGN KEY (property_id) REFERENCES PROPERTY(property_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------------
-- 3. TRANSACTIONAL ENTITIES
-- ---------------------------------------------------------------------------
CREATE TABLE CONTRACT (
    contract_id    INT           PRIMARY KEY,
    property_id    INT           NOT NULL,
    client_id      INT           NOT NULL,
    agent_id       INT,
    contract_type  VARCHAR(6)    NOT NULL CHECK (contract_type IN ('SALE','RENT')),
    contract_date  DATE          DEFAULT (CURRENT_DATE),
    amount         DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    status         VARCHAR(10)   DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','CLOSED','CANCELLED')),
    CONSTRAINT fk_contract_property FOREIGN KEY (property_id) REFERENCES PROPERTY(property_id),
    CONSTRAINT fk_contract_client   FOREIGN KEY (client_id)   REFERENCES CLIENT(client_id),
    CONSTRAINT fk_contract_agent    FOREIGN KEY (agent_id)    REFERENCES AGENT(agent_id)
);

CREATE TABLE PAYMENT (
    payment_id     INT           PRIMARY KEY,
    contract_id    INT           NOT NULL,
    payment_date   DATE          DEFAULT (CURRENT_DATE),
    amount         DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    payment_mode   VARCHAR(15)   CHECK (payment_mode IN ('CASH','CARD','BANK_TRANSFER','CHEQUE')),
    CONSTRAINT fk_payment_contract FOREIGN KEY (contract_id) REFERENCES CONTRACT(contract_id) ON DELETE CASCADE
);

CREATE TABLE PAYMENT_INSTALLMENT (
    payment_id       INT           NOT NULL,
    installment_no   INT           NOT NULL,     -- partial key
    due_date         DATE          NOT NULL,
    installment_amt  DECIMAL(12,2) NOT NULL CHECK (installment_amt > 0),
    paid_flag        CHAR(1)       DEFAULT 'N' CHECK (paid_flag IN ('Y','N')),
    CONSTRAINT pk_payment_installment PRIMARY KEY (payment_id, installment_no),
    CONSTRAINT fk_installment_payment FOREIGN KEY (payment_id) REFERENCES PAYMENT(payment_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------------
-- 4. SUPPORTING ENTITIES
-- ---------------------------------------------------------------------------
CREATE TABLE MAINTENANCE_REQUEST (
    request_id     INT           PRIMARY KEY,
    property_id    INT           NOT NULL,
    client_id      INT           NOT NULL,
    request_date   DATE          DEFAULT (CURRENT_DATE),
    description    VARCHAR(250),
    status         VARCHAR(12)   DEFAULT 'OPEN' CHECK (status IN ('OPEN','IN_PROGRESS','CLOSED')),
    CONSTRAINT fk_req_property FOREIGN KEY (property_id) REFERENCES PROPERTY(property_id),
    CONSTRAINT fk_req_client   FOREIGN KEY (client_id)   REFERENCES CLIENT(client_id)
);

CREATE TABLE FEEDBACK (
    feedback_id    INT           PRIMARY KEY,
    client_id      INT           NOT NULL,
    property_id    INT           NOT NULL,
    rating         INT           CHECK (rating BETWEEN 1 AND 5),
    comments       VARCHAR(250),
    feedback_date  DATE       DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_fb_client   FOREIGN KEY (client_id)   REFERENCES CLIENT(client_id),
    CONSTRAINT fk_fb_property FOREIGN KEY (property_id) REFERENCES PROPERTY(property_id)
);

/* ============================================================================
   FILE 2 : 02_sequences_indexes.sql
   REAL ESTATE MANAGEMENT SYSTEM (RESM) — SEQUENCES & INDEXES
   ============================================================================ */

ALTER TABLE PROPERTY AUTO_INCREMENT = 1001;
ALTER TABLE CONTRACT AUTO_INCREMENT = 5001;
ALTER TABLE PAYMENT  AUTO_INCREMENT = 9001;

-- Usage:
-- INSERT INTO PROPERTY (property_id, title, ...) VALUES (seq_property_id.NEXTVAL, 'New Listing', ...);

-- 2. Indexes (speed up frequent WHERE/JOIN columns)
CREATE INDEX idx_property_city     ON PROPERTY(city);
CREATE INDEX idx_property_status   ON PROPERTY(status);
CREATE INDEX idx_property_owner    ON PROPERTY(owner_id);
CREATE INDEX idx_contract_client   ON CONTRACT(client_id);
CREATE INDEX idx_contract_property ON CONTRACT(property_id);
CREATE INDEX idx_payment_contract  ON PAYMENT(contract_id);


/* ============================================================================
   FILE 3 : 03_sample_data.sql
   REAL ESTATE MANAGEMENT SYSTEM (RESM) — SAMPLE DATA (DML)
   ============================================================================ */

INSERT INTO PROPERTY_TYPE VALUES (1,'Apartment');
INSERT INTO PROPERTY_TYPE VALUES (2,'Villa');
INSERT INTO PROPERTY_TYPE VALUES (3,'Plot');
INSERT INTO PROPERTY_TYPE VALUES (4,'Commercial');

INSERT INTO OWNER  VALUES (1,'Rajesh Sharma','9876543210','rajesh@mail.com','MP, India');
INSERT INTO OWNER  VALUES (2,'Sunita Verma','9876500001','sunita@mail.com','MP, India');

INSERT INTO AGENT  VALUES (1,'Amit Patel','9998887771','amit@resm.com',2.5,DATE '2023-01-15');
INSERT INTO AGENT  VALUES (2,'Priya Singh','9998887772','priya@resm.com',3.0,DATE '2022-06-10');

INSERT INTO CLIENT VALUES (1,'Vikram Rao','9111122223','vikram@mail.com','Indore','BUYER');
INSERT INTO CLIENT VALUES (2,'Neha Joshi','9111122224','neha@mail.com','Bhopal','TENANT');
INSERT INTO CLIENT VALUES (3,'Karan Mehta','9111122225','karan@mail.com','Indore','BUYER');

INSERT INTO PROPERTY VALUES (1001,'2BHK Sunrise Apartments',1,'12 MG Road','Indore','MP','452001',950,3500000,'AVAILABLE',DATE '2026-01-10',1,1);
INSERT INTO PROPERTY VALUES (1002,'Green Villa',2,'45 Palm Street','Bhopal','MP','462001',2400,9500000,'AVAILABLE',DATE '2026-02-05',2,2);
INSERT INTO PROPERTY VALUES (1003,'Commercial Plaza Unit 5',4,'Station Road','Indore','MP','452002',1200,7200000,'BOOKED',DATE '2026-03-01',1,1);
INSERT INTO PROPERTY VALUES (1004,'Open Plot Sector 9',3,'Sector 9','Indore','MP','452010',3000,2100000,'AVAILABLE',DATE '2026-03-15',2,NULL);

INSERT INTO PROPERTY_IMAGE VALUES (1001,1,'img/1001_front.jpg',DATE '2026-01-11');
INSERT INTO PROPERTY_IMAGE VALUES (1001,2,'img/1001_hall.jpg',DATE '2026-01-11');
INSERT INTO PROPERTY_IMAGE VALUES (1002,1,'img/1002_front.jpg',DATE '2026-02-06');

INSERT INTO CONTRACT VALUES (5001,1003,1,1,'SALE',DATE '2026-04-01',7200000,'ACTIVE');
INSERT INTO CONTRACT VALUES (5002,1002,3,2,'RENT',DATE '2026-04-10',95000,'ACTIVE');

INSERT INTO PAYMENT VALUES (9001,5001,DATE '2026-04-05',2000000,'BANK_TRANSFER');
INSERT INTO PAYMENT VALUES (9002,5002,DATE '2026-04-10',95000,'CARD');

INSERT INTO PAYMENT_INSTALLMENT VALUES (9001,1,DATE '2026-05-05',1500000,'N');
INSERT INTO PAYMENT_INSTALLMENT VALUES (9001,2,DATE '2026-06-05',1500000,'N');

INSERT INTO MAINTENANCE_REQUEST VALUES (1,1003,1,DATE '2026-04-10','AC unit not cooling','OPEN');
INSERT INTO FEEDBACK VALUES (1,1,1003,4,'Good location, minor delay in handover',DATE '2026-04-12');

COMMIT;



/* ============================================================================
   FILE 4 : 04_views.sql
   REAL ESTATE MANAGEMENT SYSTEM (RESM) — VIEWS
   ============================================================================ */

DROP VIEW vw_available_properties;
DROP VIEW vw_agent_performance;
DROP VIEW vw_tenant_directory;

-- View 1: Public listing feed — hides owner contact details entirely (security)
CREATE VIEW vw_available_properties AS
SELECT p.property_id, p.title, pt.type_name, p.city, p.area_sqft, p.price
FROM PROPERTY p
JOIN PROPERTY_TYPE pt ON p.type_id = pt.type_id
WHERE p.status = 'AVAILABLE';

-- View 2: Aggregated agent performance report
-- NOT updatable (GROUP BY + aggregates) — illustrates table-vs-view limits
CREATE VIEW vw_agent_performance AS
SELECT a.agent_id, a.agent_name,
       COUNT(c.contract_id) AS total_contracts,
       SUM(c.amount)        AS total_business_value
FROM AGENT a
LEFT JOIN CONTRACT c ON a.agent_id = c.agent_id
GROUP BY a.agent_id, a.agent_name;

-- View 3: Simple single-table view — IS updatable, passes through to CLIENT
-- e.g. UPDATE vw_tenant_directory SET phone = '9000000000' WHERE client_id = 2;
CREATE VIEW vw_tenant_directory AS
SELECT client_id, client_name, phone, email
FROM CLIENT
WHERE client_type = 'TENANT';

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