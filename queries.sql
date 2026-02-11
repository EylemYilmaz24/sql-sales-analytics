/* =========================================================
   SQL Sales Analytics - Business Reporting Queries
   Target schema (typical): orders, order_details, products,
   customers, employees, shippers
   ========================================================= */

/* 1) Total Revenue */
SELECT
  ROUND(SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0))), 2) AS total_revenue
FROM order_details od;

/* 2) Monthly Revenue Trend */
SELECT
  DATE_TRUNC('month', o.order_date) AS month,
  ROUND(SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0))), 2) AS revenue
FROM orders o
JOIN order_details od ON od.order_id = o.order_id
GROUP BY 1
ORDER BY 1;

/* 3) Top 10 Products by Revenue */
SELECT
  p.product_name,
  ROUND(SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0))), 2) AS revenue
FROM order_details od
JOIN products p ON p.product_id = od.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 10;

/* 4) Top 10 Customers by Total Spend */
SELECT
  c.customer_id,
  c.company_name,
  ROUND(SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0))), 2) AS total_spend
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_details od ON od.order_id = o.order_id
GROUP BY c.customer_id, c.company_name
ORDER BY total_spend DESC
LIMIT 10;

/* 5) Revenue by Country */
SELECT
  c.country,
  ROUND(SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0))), 2) AS revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_details od ON od.order_id = o.order_id
GROUP BY c.country
ORDER BY revenue DESC;

/* 6) Average Order Value (AOV) */
WITH order_totals AS (
  SELECT
    o.order_id,
    SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0))) AS order_total
  FROM orders o
  JOIN order_details od ON od.order_id = o.order_id
  GROUP BY o.order_id
)
SELECT
  ROUND(AVG(order_total), 2) AS avg_order_value
FROM order_totals;

/* 7) Repeat Purchase Customers (>= 3 orders) */
SELECT
  c.customer_id,
  c.company_name,
  COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.company_name
HAVING COUNT(o.order_id) >= 3
ORDER BY order_count DESC;

/* 8) Top Employees by Revenue */
SELECT
  e.employee_id,
  (e.first_name || ' ' || e.last_name) AS employee_name,
  ROUND(SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0))), 2) AS revenue
FROM employees e
JOIN orders o ON o.employee_id = e.employee_id
JOIN order_details od ON od.order_id = o.order_id
GROUP BY e.employee_id, employee_name
ORDER BY revenue DESC;

/* 9) Shipping Performance: Avg Days to Ship */
SELECT
  s.company_name AS shipper,
  ROUND(AVG(EXTRACT(DAY FROM (o.shipped_date - o.order_date))), 2) AS avg_days_to_ship
FROM orders o
JOIN shippers s ON s.shipper_id = o.ship_via
WHERE o.shipped_date IS NOT NULL
GROUP BY s.company_name
ORDER BY avg_days_to_ship;

/* 10) RFM-style Customer Segmentation (SQL)
   - Recency: days since last order
   - Frequency: number of orders
   - Monetary: total spend
*/
WITH customer_metrics AS (
  SELECT
    c.customer_id,
    c.company_name,
    MAX(o.order_date) AS last_order_date,
    COUNT(DISTINCT o.order_id) AS frequency,
    SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0))) AS monetary
  FROM customers c
  JOIN orders o ON o.customer_id = c.customer_id
  JOIN order_details od ON od.order_id = o.order_id
  GROUP BY c.customer_id, c.company_name
),
scored AS (
  SELECT
    *,
    /* Recency: smaller is better */
    EXTRACT(DAY FROM (CURRENT_DATE - last_order_date)) AS recency_days,
    NTILE(4) OVER (ORDER BY EXTRACT(DAY FROM (CURRENT_DATE - last_order_date)) ASC) AS r_score,
    NTILE(4) OVER (ORDER BY frequency DESC) AS f_score,
    NTILE(4) OVER (ORDER BY monetary DESC) AS m_score
  FROM customer_metrics
)
SELECT
  customer_id,
  company_name,
  recency_days,
  frequency,
  ROUND(monetary, 2) AS monetary,
  r_score, f_score, m_score,
  (r_score::text || f_score::text || m_score::text) AS rfm_segment
FROM scored
ORDER BY monetary DESC
LIMIT 50;

/* 11) Monthly Revenue Growth Rate (%) */

WITH monthly_revenue AS (
  SELECT
    DATE_TRUNC('month', o.order_date) AS month,
    SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0))) AS revenue
  FROM orders o
  JOIN order_details od ON od.order_id = o.order_id
  GROUP BY 1
),
growth_calc AS (
  SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue
  FROM monthly_revenue
)
SELECT
  month,
  ROUND(revenue, 2) AS revenue,
  ROUND(
    ((revenue - prev_month_revenue) / prev_month_revenue) * 100,
    2
  ) AS growth_percentage
FROM growth_calc
ORDER BY month;

/* 12) Customer Revenue Ranking */

SELECT
  c.customer_id,
  c.company_name,
  SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0))) AS total_revenue,
  RANK() OVER (
    ORDER BY SUM(od.unit_price * od.quantity * (1 - COALESCE(od.discount, 0))) DESC
  ) AS revenue_rank
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_details od ON od.order_id = o.order_id
GROUP BY c.customer_id, c.company_name
ORDER BY revenue_rank
LIMIT 20;
