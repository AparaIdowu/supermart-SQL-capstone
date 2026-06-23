/*  SUPERMART ANALYTICS CAPSTONE */


--SECTION A — Fundamentals

-- 1a. Customers in Lagos
SELECT first_name, last_name, email
FROM customers
WHERE city = 'Lagos'
ORDER BY last_name ASC, first_name ASC;

-- 1b. Distinct cities shipped to
SELECT DISTINCT shipping_city
FROM orders
WHERE shipping_city IS NOT NULL
ORDER BY shipping_city ASC;

-- 1c. Top 10 most expensive products
SELECT product_name, category_id, unit_price
FROM products
ORDER BY unit_price DESC
LIMIT 10;

-- 1d. Employees hired on/after 2021-01-01
SELECT first_name || ' ' || last_name AS full_name,
       role, hire_date, salary
FROM employees
WHERE hire_date >= '2021-01-01'
ORDER BY hire_date ASC;

-- 1e. Orders placed in December (any year)
SELECT order_id, order_date, status, shipping_city
FROM orders
WHERE EXTRACT(MONTH FROM order_date) = 12
ORDER BY order_date DESC;


/* ============================================================
   SECTION B — Aggregate Functions
   ============================================================ */

-- 2a. Orders per status + percentage of total
SELECT status,
       COUNT(*) AS order_count,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM orders
GROUP BY status
ORDER BY order_count DESC;

-- 2b. Min/Max/Avg unit_price per category
SELECT c.category_name,
       MIN(p.unit_price) AS min_price,
       MAX(p.unit_price) AS max_price,
       ROUND(AVG(p.unit_price), 2) AS avg_price
FROM products p
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY avg_price DESC;

-- 2c. Revenue stats across all order_items  (FORMULA FIXED)
SELECT
    ROUND(SUM(quantity * unit_price * (1 - discount / 100.0)), 2) AS total_revenue,
    ROUND(AVG(quantity * unit_price * (1 - discount / 100.0)), 2) AS avg_revenue,
    ROUND(MAX(quantity * unit_price * (1 - discount / 100.0)), 2) AS max_revenue,
    ROUND(MIN(quantity * unit_price * (1 - discount / 100.0)), 2) AS min_revenue
FROM order_items;

-- 2d. Distinct ordering customers + avg orders per customer
SELECT
    COUNT(DISTINCT customer_id) AS distinct_customers,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT customer_id), 2) AS avg_orders_per_customer
FROM orders;


/* ============================================================
   SECTION C — Grouping (GROUP BY / HAVING)
   ============================================================ */

-- 3a. Customers registered per year (2018-2024)
SELECT EXTRACT(YEAR FROM registration_date) AS registration_year,
       COUNT(*) AS customer_count
FROM customers
WHERE EXTRACT(YEAR FROM registration_date) BETWEEN 2018 AND 2024
GROUP BY registration_year
ORDER BY registration_year ASC;

-- 3b. Shipping cities with > 10 delivered orders
SELECT shipping_city,
       COUNT(*) AS delivered_orders
FROM orders
WHERE status = 'Delivered'
GROUP BY shipping_city
HAVING COUNT(*) > 10
ORDER BY delivered_orders DESC;

-- 3c. Products with total qty sold > 50 (all statuses)
SELECT p.product_id, p.product_name,
       SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(oi.quantity) > 50
ORDER BY total_quantity_sold DESC;

-- 3d. Employees who handled >= 20 orders
--     (INNER JOIN is correct: HAVING >= 20 excludes zero-order staff anyway)
SELECT e.first_name || ' ' || e.last_name AS full_name,
       COUNT(o.order_id) AS total_orders_handled
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
HAVING COUNT(o.order_id) >= 20
ORDER BY total_orders_handled DESC;

-- 3e. Per year: total orders + distinct customers
SELECT EXTRACT(YEAR FROM order_date) AS order_year,
       COUNT(*) AS total_orders,
       COUNT(DISTINCT customer_id) AS distinct_customers
FROM orders
WHERE EXTRACT(YEAR FROM order_date) BETWEEN 2021 AND 2024
GROUP BY order_year
ORDER BY order_year ASC;


/* ============================================================
   SECTION D — LIKE / ILIKE
   ============================================================ */

-- 4a. Gmail customers
SELECT first_name, last_name, email
FROM customers
WHERE email ILIKE '%@gmail.com'
ORDER BY last_name ASC;

-- 4b. Products containing "set"
SELECT product_name, category_id, unit_price
FROM products
WHERE product_name ILIKE '%set%'
ORDER BY unit_price DESC;

-- 4c. Customers whose last name starts with 'Ad'
SELECT first_name || ' ' || last_name AS full_name,
       city, registration_date
FROM customers
WHERE last_name ILIKE 'Ad%'
ORDER BY last_name ASC, first_name ASC;

-- 4d. Products containing combo / kit / pack
SELECT product_name, category_id, unit_price
FROM products
WHERE product_name ILIKE '%combo%'
   OR product_name ILIKE '%kit%'
   OR product_name ILIKE '%pack%'
ORDER BY unit_price DESC;

-- 4e. Customers whose city contains 'an'
SELECT first_name, last_name, city
FROM customers
WHERE city ILIKE '%an%'
ORDER BY city ASC, last_name ASC;


/* ============================================================
   SECTION E — JOINs
   ============================================================ */

-- 5a. 50 most recent orders with customer + employee names
SELECT o.order_id,
       c.first_name || ' ' || c.last_name AS customer_name,
       e.first_name || ' ' || e.last_name AS employee_name,
       o.order_date, o.status, o.shipping_city
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN employees e ON o.employee_id = e.employee_id
ORDER BY o.order_date DESC
LIMIT 50;

-- 5b. All 800 customers with order count (0 if none)
SELECT c.customer_id,
       c.first_name || ' ' || c.last_name AS full_name,
       c.city,
       COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.city
ORDER BY order_count DESC, c.last_name ASC;

-- 5c. Detailed order line report  (FORMULA FIXED)
SELECT oi.order_id,
       o.order_date,
       c.first_name || ' ' || c.last_name AS customer_name,
       p.product_name,
       oi.quantity,
       oi.unit_price,
       oi.discount,
       ROUND(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0), 2) AS line_total
FROM order_items oi
INNER JOIN orders o     ON oi.order_id = o.order_id
INNER JOIN customers c  ON o.customer_id = c.customer_id
INNER JOIN products p   ON oi.product_id = p.product_id
ORDER BY oi.order_id ASC, p.product_name ASC;

-- 5d. All 35 employees with region + total orders handled (0 if none)
SELECT e.first_name || ' ' || e.last_name AS full_name,
       e.role,
       r.region_name,
       COUNT(o.order_id) AS total_orders
FROM employees e
INNER JOIN regions r ON e.region_id = r.region_id
LEFT JOIN orders o   ON e.employee_id = o.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.role, r.region_name
ORDER BY total_orders DESC, e.last_name ASC;

-- 5e. Per category, every product with times_ordered + total_qty_sold
SELECT c.category_name,
       p.product_name,
       COUNT(DISTINCT oi.order_id) AS times_ordered,
       COALESCE(SUM(oi.quantity), 0) AS total_qty_sold
FROM categories c
INNER JOIN products p   ON c.category_id = p.category_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY c.category_id, c.category_name, p.product_id, p.product_name
ORDER BY c.category_name ASC, total_qty_sold DESC;


/* ============================================================
   SECTION F — CASE Expressions
   ============================================================ */

-- 6a. Product price tier
SELECT p.product_name,
       c.category_name,
       p.unit_price,
       CASE
           WHEN p.unit_price < 10000  THEN 'Budget'
           WHEN p.unit_price < 100000 THEN 'Mid-Range'
           ELSE 'Premium'
       END AS price_tier
FROM products p
JOIN categories c ON p.category_id = c.category_id
ORDER BY p.unit_price ASC;

-- 6b. Employee pay band
SELECT first_name || ' ' || last_name AS full_name,
       role, salary,
       CASE
           WHEN salary >= 100000 THEN 'Executive'
           WHEN salary >= 80000  THEN 'Senior'
           ELSE 'Entry Level'
       END AS pay_band
FROM employees
ORDER BY salary DESC;

-- 6c. Per order total value + value category  (FORMULA FIXED)
SELECT o.order_id,
       o.order_date,
       o.status,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)), 2) AS total_order_value,
       CASE
           WHEN SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)) > 500000 THEN 'High Value'
           WHEN SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)) >= 100000 THEN 'Medium Value'
           ELSE 'Low Value'
       END AS value_category
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_date, o.status
ORDER BY total_order_value DESC;

-- 6d. Count of products per category per price tier
SELECT c.category_name,
       COUNT(CASE WHEN p.unit_price < 10000 THEN 1 END) AS budget_count,
       COUNT(CASE WHEN p.unit_price >= 10000 AND p.unit_price < 100000 THEN 1 END) AS mid_range_count,
       COUNT(CASE WHEN p.unit_price >= 100000 THEN 1 END) AS premium_count
FROM categories c
JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY c.category_name ASC;


/* ============================================================
   SECTION G — Subqueries
   ============================================================ */

-- 7a. Products priced above the catalogue average (scalar subquery)
SELECT product_name, category_id, unit_price
FROM products
WHERE unit_price > (SELECT AVG(unit_price) FROM products)
ORDER BY unit_price DESC;

-- 7b. Customers with >= 1 order (subquery with IN, no JOIN)
SELECT first_name || ' ' || last_name AS full_name, city
FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders);

-- 7c. Products that never appeared in any order (NOT EXISTS)
SELECT product_id, product_name, category_id, unit_price
FROM products p
WHERE NOT EXISTS (
    SELECT 1 FROM order_items oi WHERE oi.product_id = p.product_id
);

-- 7d. Top 5 customers by lifetime revenue (derived table, no CTE)
SELECT cust.full_name, cust.city, cust.total_revenue
FROM (
    SELECT c.customer_id,
           c.first_name || ' ' || c.last_name AS full_name,
           c.city,
           ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)), 2) AS total_revenue
    FROM customers c
    JOIN orders o      ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.city
) AS cust
ORDER BY cust.total_revenue DESC
LIMIT 5;

-- 7e. Customers whose lifetime revenue exceeds the average (subquery in FROM + scalar subquery)
SELECT cust.full_name, cust.city, cust.total_revenue
FROM (
    SELECT c.customer_id,
           c.first_name || ' ' || c.last_name AS full_name,
           c.city,
           ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)), 2) AS total_revenue
    FROM customers c
    JOIN orders o       ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.city
) AS cust
WHERE cust.total_revenue > (
    SELECT AVG(per_cust.rev)
    FROM (
        SELECT SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)) AS rev
        FROM customers c
        JOIN orders o       ON c.customer_id = o.customer_id
        JOIN order_items oi ON o.order_id = oi.order_id
        GROUP BY c.customer_id
    ) AS per_cust
)
ORDER BY cust.total_revenue DESC;


/* ============================================================
   SECTION H — CTEs
   ============================================================ */

-- 8a. Single CTE: total revenue per customer, return top 10
WITH customer_revenue AS (
    SELECT c.customer_id,
           c.first_name || ' ' || c.last_name AS full_name,
           c.city,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)) AS total_revenue
    FROM customers c
    JOIN orders o       ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.city
)
SELECT customer_id, full_name, city,
       ROUND(total_revenue, 2) AS total_revenue
FROM customer_revenue
ORDER BY total_revenue DESC
LIMIT 10;

-- 8b. CTE: best-selling product (by qty) in each category
WITH product_sales AS (
    SELECT c.category_name,
           p.product_name,
           SUM(oi.quantity) AS total_qty_sold
    FROM categories c
    JOIN products p     ON c.category_id = p.category_id
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY c.category_name, p.product_name
)
SELECT category_name, product_name, total_qty_sold
FROM (
    SELECT category_name, product_name, total_qty_sold,
           RANK() OVER (PARTITION BY category_name ORDER BY total_qty_sold DESC) AS rnk
    FROM product_sales
) ranked
WHERE rnk = 1
ORDER BY category_name ASC;

-- 8c. Two chained CTEs: 2023 monthly revenue vs the 2023 monthly average
WITH monthly_revenue AS (
    SELECT EXTRACT(MONTH FROM o.order_date) AS month_num,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE EXTRACT(YEAR FROM o.order_date) = 2023
    GROUP BY EXTRACT(MONTH FROM o.order_date)
),
avg_monthly AS (
    SELECT AVG(revenue) AS avg_revenue FROM monthly_revenue
)
SELECT m.month_num,
       ROUND(m.revenue, 2) AS total_revenue,
       CASE WHEN m.revenue > a.avg_revenue THEN 'Above Average'
            ELSE 'Below Average' END AS vs_average
FROM monthly_revenue m
CROSS JOIN avg_monthly a
ORDER BY m.month_num ASC;

-- 8d. Customer frequency segmentation (CTE + CASE)
WITH customer_orders AS (
    SELECT c.customer_id,
           COUNT(o.order_id) AS order_count
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
)
SELECT
    CASE
        WHEN order_count >= 8           THEN 'High Frequency'
        WHEN order_count BETWEEN 4 AND 7 THEN 'Regular'
        WHEN order_count BETWEEN 1 AND 3 THEN 'Occasional'
        ELSE 'Inactive'
    END AS segment,
    COUNT(*) AS customer_count
FROM customer_orders
GROUP BY segment
ORDER BY customer_count DESC;

-- 8e. Year-over-year revenue from DELIVERED orders (CTE)
WITH delivered_revenue AS (
    SELECT EXTRACT(YEAR FROM o.order_date) AS order_year,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY EXTRACT(YEAR FROM o.order_date)
)
SELECT order_year,
       ROUND(revenue, 2) AS total_revenue
FROM delivered_revenue
ORDER BY order_year ASC;


/* ============================================================
   SECTION I — CAPSTONE
   Q9. Employee Sales Performance (delivered orders 2021-01-01..2024-06-30)
   ============================================================ */
WITH order_totals AS (
    -- revenue of each DELIVERED order in range
    SELECT o.order_id,
           o.employee_id,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)) AS order_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
      AND o.order_date BETWEEN '2021-01-01' AND '2024-06-30'
    GROUP BY o.order_id, o.employee_id
),
employee_stats AS (
    -- aggregate per employee
    SELECT employee_id,
           COUNT(order_id)     AS total_delivered_orders,
           SUM(order_revenue)  AS total_revenue,
           AVG(order_revenue)  AS avg_order_value,
           MAX(order_revenue)  AS best_single_order
    FROM order_totals
    GROUP BY employee_id
)
SELECT e.first_name || ' ' || e.last_name AS employee_name,
       e.role,
       r.region_name,
       COALESCE(s.total_delivered_orders, 0)        AS total_delivered_orders,
       ROUND(COALESCE(s.total_revenue, 0), 2)       AS total_revenue,
       ROUND(COALESCE(s.avg_order_value, 0), 2)     AS avg_order_value,
       ROUND(COALESCE(s.best_single_order, 0), 2)   AS best_single_order,
       CASE
           WHEN COALESCE(s.total_revenue, 0) > 5000000  THEN 'Elite'
           WHEN COALESCE(s.total_revenue, 0) >= 1000000 THEN 'Strong'
           WHEN COALESCE(s.total_revenue, 0) >= 100000  THEN 'Developing'
           ELSE 'Inactive'
       END AS performance_band
FROM employees e
INNER JOIN regions r       ON e.region_id = r.region_id
LEFT JOIN employee_stats s ON e.employee_id = s.employee_id
ORDER BY total_revenue DESC, employee_name ASC;


/* ============================================================
   SECTION J — BONUS
   Q10. Customer Lifetime Value (customers registered before 2024)
   ============================================================ */
WITH per_order AS (
    -- revenue of every order (LEFT JOIN keeps orders even with no items)
    SELECT o.order_id, o.customer_id, o.status,
           COALESCE(SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)), 0) AS order_revenue
    FROM orders o
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.customer_id, o.status
),
customer_summary AS (
    SELECT c.customer_id,
           c.first_name || ' ' || c.last_name AS customer_name,
           c.city,
           EXTRACT(YEAR FROM c.registration_date) AS registration_year,
           COUNT(po.order_id)                                           AS total_orders,
           COUNT(po.order_id) FILTER (WHERE po.status = 'Delivered')    AS delivered_orders,
           COUNT(po.order_id) FILTER (WHERE po.status = 'Cancelled')    AS cancelled_orders,
           COALESCE(SUM(po.order_revenue) FILTER (WHERE po.status = 'Delivered'), 0) AS lifetime_revenue,
           COALESCE(AVG(po.order_revenue) FILTER (WHERE po.status = 'Delivered'), 0) AS avg_order_value
    FROM customers c
    LEFT JOIN per_order po ON c.customer_id = po.customer_id
    WHERE c.registration_date < '2024-01-01'
    GROUP BY c.customer_id, c.first_name, c.last_name, c.city, c.registration_date
)
SELECT customer_name,
       city,
       registration_year,
       total_orders,
       delivered_orders,
       cancelled_orders,
       ROUND(lifetime_revenue, 2) AS lifetime_revenue,
       ROUND(avg_order_value, 2)  AS avg_order_value,
       CASE
           WHEN lifetime_revenue > 500000 AND delivered_orders >= 5 THEN 'VIP'
           WHEN (lifetime_revenue BETWEEN 100000 AND 500000)
                OR (delivered_orders BETWEEN 2 AND 4)               THEN 'Loyal'
           WHEN delivered_orders = 1                                THEN 'One-Time Buyer'
           WHEN delivered_orders = 0 AND total_orders >= 1          THEN 'No Conversions'
           ELSE 'Inactive'
       END AS customer_segment
FROM customer_summary
ORDER BY lifetime_revenue DESC, customer_name ASC;
