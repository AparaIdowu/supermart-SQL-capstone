
# SuperMart Analytics  SQL Capstone

A complete SQL analytics project on **SuperMart**, a Nigerian retail chain. It works through a realistic retail database from basic queries to multi-stage analytical questions,  answering ten business problems with clean, commented PostgreSQL.

**Author:** Idowu Blessing Apara
**Engine:** PostgreSQL · **Currency:** Nigerian Naira (₦)

---

## Overview

The project is organised as a single, fully commented script (`SUPERMART ANALYTICS CAPSTONE.sql`) divided into ten sections (A–J) that progress from SQL fundamentals to advanced analytical queries. Each query is preceded by a comment stating the business question it answers.

The core revenue measure used throughout is:

```sql
quantity * unit_price * (1 - discount / 100.0)
```

reported on **delivered** orders unless a question states otherwise.

---

## Skills demonstrated

| Section | Topic | Examples answered |
|---|---|---|
| **A** | Fundamentals — `SELECT`, `WHERE`, `ORDER BY`, `LIMIT` | Customers in Lagos; distinct shipping cities; top 10 priciest products; recent hires; December orders |
| **B** | Aggregate functions | Order status mix with % of total; price stats per category; revenue statistics; distinct customers & avg orders |
| **C** | Grouping — `GROUP BY` / `HAVING` | Registrations per year; cities with >10 delivered orders; products with >50 units sold; busy employees; yearly orders & customers |
| **D** | Pattern matching — `LIKE` / `ILIKE` | Gmail customers; product name searches (set / combo / kit / pack); name and city patterns |
| **E** | Joins (`INNER` / `LEFT`) | Recent orders with names; all 800 customers with order counts; detailed line-item report; employees with regions; products per category |
| **F** | `CASE` expressions | Product price tiers; employee pay bands; per-order value categories; product counts by tier |
| **G** | Subqueries | Above-average priced products; customers with orders; never-ordered products (`NOT EXISTS`); top customers; above-average spenders |
| **H** | Common Table Expressions (CTEs) | Revenue per customer; best seller per category; chained CTEs for monthly vs average revenue; frequency segmentation; year-over-year revenue |
| **I** | **Capstone Q9** — Employee Sales Performance | Per-rep delivered orders, revenue, AOV, best order, and an Elite/Strong/Developing/Inactive performance band (2021–2024) |
| **J** | **Bonus Q10** — Customer Lifetime Value | Per-customer lifetime revenue and a VIP / Loyal / One-Time / No-Conversion / Inactive segmentation |

Techniques on display include window functions (`SUM() OVER ()`), conditional aggregation (`FILTER`), derived tables, scalar and correlated subqueries, multi-stage CTE pipelines, and `CASE`-based segmentation.

---

## Database schema

The queries run against a seven-table relational retail model:

| Table | Description |
|---|---|
| `regions` | Sales regions |
| `categories` | Product categories |
| `employees` | Sales staff (role, region, hire date, salary) |
| `products` | Catalogue (price, stock, category) |
| `customers` | Customers (city, registration date) |
| `orders` | Orders (status, dates, shipping city) |
| `order_items` | Line items (quantity, unit price, discount) |

---

## Repository contents

```
.
├── SUPERMART ANALYTICS CAPSTONE.sql   # all 10 sections of solutions
└── README.md
```

---

## How to run

1. Create a PostgreSQL database and load the SuperMart schema and data (the seven tables above).
2. Connect to that database, e.g.:
   ```bash
   psql -d supermart
   ```
3. Run the script, or copy individual queries into your SQL client:
   ```sql
   \i SUPERMART ANALYTICS CAPSTONE-_Idowu_Blessing_Apara.sql
   ```

> The script contains the **analytical queries only**. It expects the SuperMart tables to already exist and be populated.

---

## Notes

- All revenue is net of discount and, unless a question specifies otherwise, based on `Delivered` orders.
- The reporting window for time-bounded questions is **2021-01-01 to 2024-06-30**.
- Queries are written for PostgreSQL (uses `EXTRACT`, `FILTER`, `||` concatenation, `ILIKE`).

---

## Author

**Idowu Blessing Apara** — data-analytics capstone project.
