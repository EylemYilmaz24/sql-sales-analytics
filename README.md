# SQL Sales Analytics (Business Reporting)

## Project Overview

This project demonstrates practical SQL skills by answering real-world business questions using a relational database (e.g., Northwind or Chinook).

The focus is on:
- Revenue analysis
- Customer segmentation (RFM-style metrics in SQL)
- Product performance
- Geographic sales insights
- Executive-ready reporting queries

---

##  Business Questions Covered

1. What are the top revenue-generating products?
2. Who are the top customers by total spend?
3. What is monthly revenue trend?
4. Which countries generate the highest revenue?
5. What is the average order value (AOV)?
6. Which customers are at risk (low recency)?

---

##  Skills Demonstrated

- JOINs (INNER, LEFT)
- GROUP BY & Aggregations
- Subqueries
- Window Functions (ROW_NUMBER, RANK)
- Date functions
- CTEs
- Business KPI calculations

---
##  How to Run

- Open `queries.sql` and execute queries in your SQL client.
- The queries are written for a typical sales schema (Northwind-like).
- If your table/column names differ, adjust JOIN keys accordingly.

##  Assumed Tables

- `orders` (order_id, customer_id, employee_id, order_date, shipped_date, ship_via)
- `order_details` (order_id, product_id, unit_price, quantity, discount)
- `products` (product_id, product_name)
- `customers` (customer_id, company_name, country)
- `employees` (employee_id, first_name, last_name)
- `shippers` (shipper_id, company_name)


## Key KPIs

- Total Revenue
- Revenue by Product
- Revenue by Country
- Customer Lifetime Value (CLV)
- Average Order Value (AOV)
- Monthly Growth Rate

---

## Why This Project?

This repository focuses on SQL as a decision-making tool, not just data extraction.  
All queries are written with business interpretation in mind.

---

## Author

Eylem Yılmaz  
Master’s in Computer Engineering (Non-thesis)  
Focused on Data Analytics & Business Intelligence
