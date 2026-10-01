# REAL-ESTATE-MANAGEMENT-SYSTEM


A database management project designed to manage real estate properties, owners, agents, clients, contracts, payments, maintenance requests, and customer feedback.

## 📌 Project Overview

The Real Estate Management System (RESM) is a database-based project that helps organize and manage real estate information efficiently.

The system stores property details along with information about owners, agents, clients, contracts, payments, maintenance requests, and feedback.

The project also demonstrates important DBMS concepts such as:

- Primary Keys
- Foreign Keys
- Constraints
- Composite Primary Keys
- Weak Entities
- Joins
- Aggregate Functions
- Subqueries
- Views
- Indexes
- Triggers
- Set Operations

## 🎯 Objectives

- Manage property information efficiently.
- Store owner and agent details.
- Maintain buyer and tenant information.
- Manage property sale and rental contracts.
- Track payments and installments.
- Handle maintenance requests.
- Store client feedback.
- Use SQL queries for data analysis and reporting.
- Demonstrate important database concepts practically.

## 🗂️ Main Entities

The database contains the following main tables:

### 1. OWNER
Stores information about property owners.

**Important attributes:**
- owner_id
- owner_name
- phone
- email
- address

### 2. AGENT
Stores real estate agent information.

**Important attributes:**
- agent_id
- agent_name
- phone
- email
- commission_rate
- hire_date

### 3. CLIENT
Stores information about buyers and tenants.

**Important attributes:**
- client_id
- client_name
- phone
- email
- address
- client_type

### 4. PROPERTY_TYPE
Stores different types of properties such as:

- Apartment
- Villa
- Plot
- Commercial

### 5. PROPERTY
Stores complete property information such as title, location, area, price, status, owner, and assigned agent.

### 6. PROPERTY_IMAGE
Stores multiple images associated with a property.

This table uses a composite primary key:

`(property_id, image_seq)`

### 7. CONTRACT
Stores sale and rental contract details.

### 8. PAYMENT
Stores payments made against contracts.

### 9. PAYMENT_INSTALLMENT
Stores installment details for payments.

### 10. MAINTENANCE_REQUEST
Stores maintenance requests raised by clients.

### 11. FEEDBACK
Stores ratings and comments provided by clients.

## 🔗 Database Relationships

The database uses foreign keys to establish relationships between tables.

Examples:

- PROPERTY → OWNER
- PROPERTY → AGENT
- PROPERTY → PROPERTY_TYPE
- CONTRACT → PROPERTY
- CONTRACT → CLIENT
- CONTRACT → AGENT
- PAYMENT → CONTRACT
- PAYMENT_INSTALLMENT → PAYMENT
- MAINTENANCE_REQUEST → PROPERTY
- MAINTENANCE_REQUEST → CLIENT
- FEEDBACK → CLIENT
- FEEDBACK → PROPERTY

## ⚙️ Database Features

### Constraints

The project uses:

- `PRIMARY KEY`
- `FOREIGN KEY`
- `UNIQUE`
- `NOT NULL`
- `CHECK`
- `DEFAULT`

For example, property price must be greater than zero and property status is restricted to predefined values. :contentReference[oaicite:1]{index=1}

### Indexes

Indexes are created on frequently searched or joined columns such as:

- Property city
- Property status
- Property owner
- Contract client
- Contract property
- Payment contract

These indexes are intended to improve query performance. :contentReference[oaicite:2]{index=2}

### Views

The project contains three views:

- `vw_available_properties`
- `vw_agent_performance`
- `vw_tenant_directory`

The available-properties view displays property listing information without exposing owner contact details. :contentReference[oaicite:3]{index=3}

### Triggers

The project contains triggers for:

1. Automatically updating property status when a contract is created.
2. Preventing payments from exceeding the contract amount.
3. Automatically setting the maintenance request date when required.

:contentReference[oaicite:4]{index=4}

## 📊 Sample Data

The database includes sample data for:

- 4 property types
- 2 owners
- 2 agents
- 3 clients
- 4 properties
- Property images
- Sale and rental contracts
- Payments
- Payment installments
- Maintenance requests
- Client feedback

:contentReference[oaicite:5]{index=5}

## 🔍 SQL Queries

The project includes SQL queries demonstrating:

- SELECT and WHERE
- ORDER BY
- Multi-table JOIN
- GROUP BY
- HAVING
- Nested subqueries
- Correlated subqueries
- Set operators
- Conditional expressions
- Views
- Division-style queries

For example, one query retrieves available properties and sorts them by price. :contentReference[oaicite:6]{index=6}

## 📁 Project Structure

```text
REAL-ESTATE-MANAGEMENT-SYSTEM/
│
├── 01_schema.sql
├── 02_sequences_indexes.sql
├── 03_sample_data.sql
├── 04_views.sql
├── 05_triggers.sql
├── 06_queries.sql
└── README.md
