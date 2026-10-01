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
