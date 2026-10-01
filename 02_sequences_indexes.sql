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
