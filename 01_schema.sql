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
