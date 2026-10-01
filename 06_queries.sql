/* ============================================================================
   FILE 6 OF 6 : 06_queries.sql
   REAL ESTATE MANAGEMENT SYSTEM (RESM) — SAMPLE QUERIES
   ============================================================================ */

-- ---------------------------------------------------------------------------
-- 1. Basic SELECT + WHERE + ORDER BY
-- ---------------------------------------------------------------------------
SELECT title, city, price
FROM PROPERTY
WHERE status = 'AVAILABLE'
ORDER BY price DESC;

-- ---------------------------------------------------------------------------
-- 2. Multi-table JOIN (Property + Owner + Type + Agent)
-- ---------------------------------------------------------------------------
SELECT p.title, pt.type_name, o.owner_name, a.agent_name, p.price
FROM PROPERTY p
JOIN OWNER o          ON p.owner_id = o.owner_id
JOIN PROPERTY_TYPE pt ON p.type_id  = pt.type_id
LEFT JOIN AGENT a     ON p.agent_id = a.agent_id;

-- ---------------------------------------------------------------------------
-- 3. Aggregate functions + GROUP BY + HAVING
-- ---------------------------------------------------------------------------
SELECT city, COUNT(*) AS property_count, AVG(price) AS avg_price
FROM PROPERTY
GROUP BY city
HAVING COUNT(*) > 1;

-- ---------------------------------------------------------------------------
-- 4. Nested subquery
-- ---------------------------------------------------------------------------
SELECT client_name
FROM CLIENT
WHERE client_id IN (
    SELECT c.client_id
    FROM CONTRACT c
    JOIN PAYMENT p ON c.contract_id = p.contract_id
    GROUP BY c.client_id
    HAVING SUM(p.amount) > (SELECT AVG(amount) FROM PAYMENT)
);

-- ---------------------------------------------------------------------------
-- 5. Correlated subquery
-- ---------------------------------------------------------------------------
SELECT p1.title, p1.type_id, p1.price
FROM PROPERTY p1
WHERE p1.price > (
    SELECT AVG(p2.price) FROM PROPERTY p2 WHERE p2.type_id = p1.type_id
);

-- ---------------------------------------------------------------------------
-- 6. Set operators: INTERSECT / MINUS / UNION
-- ---------------------------------------------------------------------------
-- 6a. Clients with an active contract AND a maintenance request
SELECT client_id FROM CONTRACT WHERE status = 'ACTIVE'
INTERSECT
SELECT client_id FROM MAINTENANCE_REQUEST;

-- 6b. Clients with a contract but NO maintenance request
--     NOTE: use EXCEPT instead of MINUS on PostgreSQL/SQL Server
SELECT client_id FROM CONTRACT
MINUS
SELECT client_id FROM MAINTENANCE_REQUEST;

-- 6c. Combined contact directory of owners and agents
SELECT owner_name AS person_name, phone, 'OWNER' AS role FROM OWNER
UNION
SELECT agent_name, phone, 'AGENT' FROM AGENT;

-- ---------------------------------------------------------------------------
-- 7. Conversion / conditional expression functions
-- ---------------------------------------------------------------------------
SELECT title,
       TO_CHAR(price, '999,999,999') AS formatted_price,
       CASE
           WHEN price < 3000000 THEN 'Budget'
           WHEN price BETWEEN 3000000 AND 8000000 THEN 'Mid-range'
           ELSE 'Premium'
       END AS price_segment
FROM PROPERTY;

-- ---------------------------------------------------------------------------
-- 8. Reporting aggregated data via a view
-- ---------------------------------------------------------------------------
SELECT * FROM vw_agent_performance ORDER BY total_business_value DESC;

-- ---------------------------------------------------------------------------
-- 9. Division-style query
-- ---------------------------------------------------------------------------
SELECT a.agent_id, a.agent_name
FROM AGENT a
WHERE NOT EXISTS (
    SELECT pt.type_id FROM PROPERTY_TYPE pt
    MINUS
    SELECT p.type_id
    FROM CONTRACT c JOIN PROPERTY p ON c.property_id = p.property_id
    WHERE c.agent_id = a.agent_id
);
