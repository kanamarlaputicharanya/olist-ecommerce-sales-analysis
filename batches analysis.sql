-- ============================================================
-- BATCH 6: SELLER & PERFORMANCE ANALYSIS
-- ============================================================


-- 1. Total number of sellers
SELECT
    COUNT(DISTINCT seller_id) AS total_sellers
FROM sellers;


-- 2. Top 10 sellers by revenue
SELECT
    oi.seller_id,
    ROUND(SUM(oi.total_amount), 2) AS seller_revenue
FROM order_items oi
GROUP BY oi.seller_id
ORDER BY seller_revenue DESC
LIMIT 10;


-- 3. Top 10 sellers by number of orders
SELECT
    seller_id,
    COUNT(DISTINCT order_id) AS total_orders
FROM order_items
GROUP BY seller_id
ORDER BY total_orders DESC
LIMIT 10;


-- 4. Average Order Value by seller
SELECT
    seller_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(total_amount), 2) AS revenue,
    ROUND(
        SUM(total_amount) / COUNT(DISTINCT order_id),
        2
    ) AS seller_aov
FROM order_items
GROUP BY seller_id
ORDER BY seller_aov DESC
LIMIT 10;


-- 5. Seller revenue contribution %
SELECT
    seller_id,
    ROUND(SUM(total_amount), 2) AS seller_revenue,
    ROUND(
        SUM(total_amount) /
        (SELECT SUM(total_amount) FROM order_items) * 100,
        2
    ) AS revenue_contribution_pct
FROM order_items
GROUP BY seller_id
ORDER BY seller_revenue DESC
LIMIT 10;


-- 6. Seller performance distribution
-- Categorize sellers based on total revenue

SELECT
    CASE
        WHEN seller_revenue >= 100000 THEN 'High Revenue'
        WHEN seller_revenue >= 50000 THEN 'Medium Revenue'
        ELSE 'Low Revenue'
    END AS seller_segment,

    COUNT(*) AS sellers,
    ROUND(SUM(seller_revenue), 2) AS revenue

FROM (
    SELECT
        seller_id,
        SUM(total_amount) AS seller_revenue
    FROM order_items
    GROUP BY seller_id
) AS seller_totals

GROUP BY seller_segment
ORDER BY revenue DESC;


-- 7. Seller order volume distribution

SELECT
    CASE
        WHEN total_orders >= 100 THEN 'High Volume'
        WHEN total_orders >= 50 THEN 'Medium Volume'
        ELSE 'Low Volume'
    END AS seller_volume_segment,

    COUNT(*) AS sellers,
    SUM(total_orders) AS total_orders

FROM (
    SELECT
        seller_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM order_items
    GROUP BY seller_id
) AS seller_orders

GROUP BY seller_volume_segment
ORDER BY total_orders DESC;


-- 8. Top sellers by number of items sold

SELECT
    seller_id,
    COUNT(*) AS items_sold,
    ROUND(SUM(total_amount), 2) AS revenue
FROM order_items
GROUP BY seller_id
ORDER BY items_sold DESC
LIMIT 10;


-- 9. Sellers with high revenue but low number of orders
-- Useful for identifying premium/high-value sellers

SELECT
    seller_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(total_amount), 2) AS revenue,
    ROUND(
        SUM(total_amount) / COUNT(DISTINCT order_id),
        2
    ) AS seller_aov
FROM order_items
GROUP BY seller_id
HAVING COUNT(DISTINCT order_id) >= 10
ORDER BY seller_aov DESC
LIMIT 10;


-- 10. Seller freight performance

SELECT
    seller_id,
    ROUND(SUM(freight_value), 2) AS total_freight,
    ROUND(AVG(freight_value), 2) AS avg_freight
FROM order_items
GROUP BY seller_id
ORDER BY total_freight DESC
LIMIT 10;


-- 11. Seller revenue vs freight cost

SELECT
    seller_id,
    ROUND(SUM(total_amount), 2) AS revenue,
    ROUND(SUM(freight_value), 2) AS freight,
    ROUND(
        SUM(freight_value) /
        NULLIF(SUM(total_amount), 0) * 100,
        2
    ) AS freight_to_revenue_pct
FROM order_items
GROUP BY seller_id
ORDER BY freight_to_revenue_pct DESC
LIMIT 10;


-- 12. Seller review performance
-- Average review score for each seller

SELECT
    oi.seller_id,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    COUNT(DISTINCT oi.order_id) AS orders
FROM order_items oi
JOIN reviews r
    ON oi.order_id = r.order_id
GROUP BY oi.seller_id
HAVING COUNT(DISTINCT oi.order_id) >= 10
ORDER BY avg_review_score DESC
LIMIT 10;


-- 13. Sellers with poor reviews

SELECT
    oi.seller_id,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    COUNT(DISTINCT oi.order_id) AS orders
FROM order_items oi
JOIN reviews r
    ON oi.order_id = r.order_id
GROUP BY oi.seller_id
HAVING COUNT(DISTINCT oi.order_id) >= 10
ORDER BY avg_review_score ASC
LIMIT 10;


-- 14. Sellers with high revenue but poor ratings
-- Important business-risk analysis

SELECT
    oi.seller_id,
    ROUND(SUM(oi.total_amount), 2) AS revenue,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    COUNT(DISTINCT oi.order_id) AS orders
FROM order_items oi
JOIN reviews r
    ON oi.order_id = r.order_id
GROUP BY oi.seller_id
HAVING
    COUNT(DISTINCT oi.order_id) >= 10
    AND AVG(r.review_score) < 3
ORDER BY revenue DESC;


-- 15. Seller concentration
-- How much revenue comes from the top 10 sellers?

WITH seller_revenue AS (
    SELECT
        seller_id,
        SUM(total_amount) AS revenue
    FROM order_items
    GROUP BY seller_id
),

top_sellers AS (
    SELECT
        seller_id,
        revenue
    FROM seller_revenue
    ORDER BY revenue DESC
    LIMIT 10
)

SELECT
    ROUND(
        SUM(revenue) /
        (SELECT SUM(revenue) FROM seller_revenue)
        * 100,
        2
    ) AS top_10_seller_revenue_pct
FROM top_sellers;


-- 16. Seller revenue ranking
-- Demonstrates SQL window functions

SELECT
    seller_id,
    ROUND(seller_revenue, 2) AS seller_revenue,
    DENSE_RANK() OVER (
        ORDER BY seller_revenue DESC
    ) AS revenue_rank
FROM (
    SELECT
        seller_id,
        SUM(total_amount) AS seller_revenue
    FROM order_items
    GROUP BY seller_id
) AS seller_totals
ORDER BY revenue_rank
LIMIT 20;




-- ============================================================
-- BATCH 5: PRODUCT & CATEGORY ANALYSIS
-- ============================================================


/* ============================================================
1. TOTAL NUMBER OF PRODUCTS

Shows the total number of unique products available in the
product catalog.
============================================================ */

SELECT
    COUNT(DISTINCT product_id) AS total_products
FROM products;


/* ============================================================
2. TOTAL NUMBER OF PRODUCT CATEGORIES

Shows how many different product categories exist in the
catalog.
============================================================ */

SELECT
    COUNT(DISTINCT product_category_name) AS total_categories
FROM products;


/* ============================================================
3. TOP 10 PRODUCTS BY REVENUE

Identifies the products generating the highest total revenue.
============================================================ */

SELECT
    oi.product_id,
    ROUND(SUM(oi.total_amount), 2) AS product_revenue
FROM order_items oi
GROUP BY oi.product_id
ORDER BY product_revenue DESC
LIMIT 10;


/* ============================================================
4. TOP 10 PRODUCTS BY UNITS SOLD

Identifies the products with the highest number of units sold.
============================================================ */

SELECT
    oi.product_id,
    COUNT(*) AS units_sold
FROM order_items oi
GROUP BY oi.product_id
ORDER BY units_sold DESC
LIMIT 10;


/* ============================================================
5. PRODUCT REVENUE AND UNITS SOLD

Shows both revenue and sales volume for each product.
Useful for comparing product demand and financial performance.
============================================================ */

SELECT
    oi.product_id,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.total_amount), 2) AS revenue
FROM order_items oi
GROUP BY oi.product_id
ORDER BY revenue DESC
LIMIT 20;


/* ============================================================
6. AVERAGE SELLING PRICE BY PRODUCT

Calculates the average selling price for each product.
Helps identify expensive and low-priced products.
============================================================ */

SELECT
    product_id,
    ROUND(AVG(price), 2) AS avg_product_price
FROM order_items
GROUP BY product_id
ORDER BY avg_product_price DESC
LIMIT 20;


/* ============================================================
7. PRODUCT CATEGORY REVENUE

Shows the total revenue generated by each product category.
============================================================ */

SELECT
    p.product_category_name,
    ROUND(SUM(oi.total_amount), 2) AS category_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY category_revenue DESC;


/* ============================================================
8. TOP 10 PRODUCT CATEGORIES BY REVENUE

Identifies the top-performing product categories based on
total revenue.
============================================================ */

SELECT
    p.product_category_name,
    ROUND(SUM(oi.total_amount), 2) AS category_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY category_revenue DESC
LIMIT 10;


/* ============================================================
9. PRODUCT CATEGORY BY UNITS SOLD

Shows which product categories have the highest sales volume.
============================================================ */

SELECT
    p.product_category_name,
    COUNT(*) AS units_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY units_sold DESC
LIMIT 10;


/* ============================================================
10. CATEGORY REVENUE AND UNITS SOLD

Combines revenue and sales volume to understand category
performance from both demand and revenue perspectives.
============================================================ */

SELECT
    p.product_category_name,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.total_amount), 2) AS revenue,
    ROUND(AVG(oi.price), 2) AS avg_price
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC
LIMIT 20;


/* ============================================================
11. CATEGORY AVERAGE ORDER VALUE

Calculates the average revenue generated per order for each
product category.
============================================================ */

SELECT
    p.product_category_name,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.total_amount), 2) AS revenue,
    ROUND(
        SUM(oi.total_amount) /
        COUNT(DISTINCT oi.order_id),
        2
    ) AS category_aov
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY category_aov DESC
LIMIT 20;


/* ============================================================
12. CATEGORY REVENUE CONTRIBUTION %

Shows what percentage of total marketplace revenue comes
from each product category.
============================================================ */

SELECT
    p.product_category_name,
    ROUND(SUM(oi.total_amount), 2) AS category_revenue,
    ROUND(
        SUM(oi.total_amount) /
        (SELECT SUM(total_amount)
         FROM order_items) * 100,
        2
    ) AS revenue_contribution_pct
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY category_revenue DESC
LIMIT 20;


/* ============================================================
13. TOP PRODUCTS WITH HIGH SALES VOLUME BUT LOW PRICE

Identifies products that sell many units but have relatively
low average prices.
Useful for volume-driven products.
============================================================ */

SELECT
    product_id,
    COUNT(*) AS units_sold,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(SUM(total_amount), 2) AS revenue
FROM order_items
GROUP BY product_id
HAVING COUNT(*) >= 50
ORDER BY units_sold DESC
LIMIT 20;


/* ============================================================
14. HIGH-VALUE PRODUCTS

Identifies products with a high average selling price.
Only products with at least 5 sales are considered to avoid
products with very few transactions affecting the result.
============================================================ */

SELECT
    product_id,
    COUNT(*) AS units_sold,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(SUM(total_amount), 2) AS revenue
FROM order_items
GROUP BY product_id
HAVING COUNT(*) >= 5
ORDER BY avg_price DESC
LIMIT 20;


/* ============================================================
15. PRODUCTS WITH HIGH REVENUE BUT LOW SALES VOLUME

Identifies premium products that generate significant revenue
despite having relatively few units sold.
============================================================ */

SELECT
    product_id,
    COUNT(*) AS units_sold,
    ROUND(SUM(total_amount), 2) AS revenue,
    ROUND(AVG(price), 2) AS avg_price
FROM order_items
GROUP BY product_id
HAVING COUNT(*) >= 5
ORDER BY revenue DESC, units_sold ASC
LIMIT 20;


/* ============================================================
16. PRODUCT CATEGORY PERFORMANCE SEGMENTATION

Classifies categories into High, Medium and Low revenue
segments based on their total revenue.
============================================================ */

SELECT
    CASE
        WHEN category_revenue >= 1000000 THEN 'High Revenue'
        WHEN category_revenue >= 500000 THEN 'Medium Revenue'
        ELSE 'Low Revenue'
    END AS category_segment,

    COUNT(*) AS categories,

    ROUND(
        SUM(category_revenue),
        2
    ) AS total_revenue

FROM (
    SELECT
        p.product_category_name,
        SUM(oi.total_amount) AS category_revenue
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY p.product_category_name
) AS category_totals

GROUP BY category_segment
ORDER BY total_revenue DESC;


/* ============================================================
17. PRODUCT FREIGHT ANALYSIS

Shows the total and average freight value associated with
each product.
============================================================ */

SELECT
    product_id,
    ROUND(SUM(freight_value), 2) AS total_freight,
    ROUND(AVG(freight_value), 2) AS avg_freight
FROM order_items
GROUP BY product_id
ORDER BY total_freight DESC
LIMIT 20;


/* ============================================================
18. CATEGORY FREIGHT ANALYSIS

Shows freight cost by product category.
Useful for identifying categories with high shipping costs.
============================================================ */

SELECT
    p.product_category_name,
    ROUND(SUM(oi.freight_value), 2) AS total_freight,
    ROUND(AVG(oi.freight_value), 2) AS avg_freight
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_freight DESC
LIMIT 20;


/* ============================================================
19. CATEGORY REVENUE VS FREIGHT

Compares category revenue with freight cost to identify
categories where shipping costs represent a large portion
of revenue.
============================================================ */

SELECT
    p.product_category_name,

    ROUND(SUM(oi.total_amount), 2) AS revenue,

    ROUND(SUM(oi.freight_value), 2) AS freight,

    ROUND(
        SUM(oi.freight_value) /
        NULLIF(SUM(oi.total_amount), 0) * 100,
        2
    ) AS freight_to_revenue_pct

FROM order_items oi

JOIN products p
    ON oi.product_id = p.product_id

GROUP BY p.product_category_name

ORDER BY freight_to_revenue_pct DESC
LIMIT 20;


/* ============================================================
20. PRODUCT REVIEW PERFORMANCE

Shows the average review score for products.
Only products with at least 10 reviewed orders are included
to make the comparison more reliable.
============================================================ */

SELECT
    oi.product_id,

    ROUND(
        AVG(r.review_score),
        2
    ) AS avg_review_score,

    COUNT(DISTINCT oi.order_id) AS reviewed_orders

FROM order_items oi

JOIN reviews r
    ON oi.order_id = r.order_id

GROUP BY oi.product_id

HAVING COUNT(DISTINCT oi.order_id) >= 10

ORDER BY avg_review_score DESC

LIMIT 20;


/* ============================================================
21. PRODUCTS WITH POOR REVIEWS

Identifies products receiving low customer review scores.
Useful for detecting product quality or customer satisfaction
problems.
============================================================ */

SELECT
    oi.product_id,

    ROUND(
        AVG(r.review_score),
        2
    ) AS avg_review_score,

    COUNT(DISTINCT oi.order_id) AS reviewed_orders

FROM order_items oi

JOIN reviews r
    ON oi.order_id = r.order_id

GROUP BY oi.product_id

HAVING COUNT(DISTINCT oi.order_id) >= 10

ORDER BY avg_review_score ASC

LIMIT 20;


/* ============================================================
22. HIGH-REVENUE PRODUCTS WITH POOR REVIEWS

Identifies products that generate significant revenue but
receive poor customer ratings.
These products represent an important business risk.
============================================================ */

SELECT
    oi.product_id,

    ROUND(
        SUM(oi.total_amount),
        2
    ) AS revenue,

    ROUND(
        AVG(r.review_score),
        2
    ) AS avg_review_score,

    COUNT(DISTINCT oi.order_id) AS orders

FROM order_items oi

JOIN reviews r
    ON oi.order_id = r.order_id

GROUP BY oi.product_id

HAVING
    COUNT(DISTINCT oi.order_id) >= 10
    AND AVG(r.review_score) < 3

ORDER BY revenue DESC;


/* ============================================================
23. PRODUCT REVENUE RANKING

Ranks products according to their total revenue using a
SQL window function.
============================================================ */

SELECT
    product_id,

    ROUND(
        product_revenue,
        2
    ) AS product_revenue,

    DENSE_RANK() OVER (
        ORDER BY product_revenue DESC
    ) AS revenue_rank

FROM (
    SELECT
        product_id,
        SUM(total_amount) AS product_revenue
    FROM order_items
    GROUP BY product_id
) AS product_totals

ORDER BY revenue_rank

LIMIT 20;


/* ============================================================
24. CATEGORY REVENUE RANKING

Ranks product categories according to total revenue.
Demonstrates the use of SQL window functions at category level.
============================================================ */

SELECT
    product_category_name,

    ROUND(
        category_revenue,
        2
    ) AS category_revenue,

    DENSE_RANK() OVER (
        ORDER BY category_revenue DESC
    ) AS revenue_rank

FROM (
    SELECT
        p.product_category_name,
        SUM(oi.total_amount) AS category_revenue
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY p.product_category_name
) AS category_totals

ORDER BY revenue_rank;


/* ============================================================
25. PRODUCT CATALOG QUALITY

Checks how many products have missing important product
information such as category, weight and dimensions.
============================================================ */

SELECT

    COUNT(*) AS total_products,

    SUM(
        CASE
            WHEN product_category_name IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_category,

    SUM(
        CASE
            WHEN product_weight_g IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_weight,

    SUM(
        CASE
            WHEN product_length_cm IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_length,

    SUM(
        CASE
            WHEN product_height_cm IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_height,

    SUM(
        CASE
            WHEN product_width_cm IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_width

FROM products;


/* ============================================================
26. PRODUCT CATEGORY TRANSLATION

Displays the original Portuguese category name along with
its English translated category name.
============================================================ */

SELECT
    p.product_category_name,
    t.product_category_name_english,

    COUNT(DISTINCT p.product_id) AS products

FROM products p

LEFT JOIN product_category_name_translation t
    ON p.product_category_name =
       t.product_category_name

GROUP BY
    p.product_category_name,
    t.product_category_name_english

ORDER BY products DESC;


/* ============================================================
27. TOP CATEGORIES WITH MOST PRODUCTS

Shows which categories contain the largest number of products
in the catalog.
============================================================ */

SELECT
    product_category_name,
    COUNT(DISTINCT product_id) AS product_count
FROM products
GROUP BY product_category_name
ORDER BY product_count DESC
LIMIT 20;


/* ============================================================
28. CATEGORY REVENUE PER PRODUCT

Calculates the average revenue generated per product within
each category.
============================================================ */

SELECT

    p.product_category_name,

    COUNT(DISTINCT p.product_id) AS products,

    ROUND(
        SUM(oi.total_amount),
        2
    ) AS revenue,

    ROUND(
        SUM(oi.total_amount) /
        COUNT(DISTINCT p.product_id),
        2
    ) AS revenue_per_product

FROM products p

JOIN order_items oi
    ON p.product_id = oi.product_id

GROUP BY p.product_category_name

ORDER BY revenue_per_product DESC

LIMIT 20;

/* =========================================================
PRODUCT DENSITY VS REVENUE

Measures how much revenue is generated on average
by each product within a category.

This helps identify categories that have fewer products
but generate high revenue per product.
========================================================= */

SELECT

    p.product_category_name,

    COUNT(DISTINCT p.product_id) AS products,

    ROUND(
        SUM(oi.total_amount),
        2
    ) AS revenue,

    ROUND(
        SUM(oi.total_amount)
        / NULLIF(COUNT(DISTINCT p.product_id), 0),
        2
    ) AS revenue_per_product

FROM products p

JOIN order_items oi
    ON p.product_id = oi.product_id

GROUP BY p.product_category_name

ORDER BY revenue_per_product DESC;


/* =========================================================
PRODUCT PERFORMANCE SEGMENTATION

Classifies products based on their sales volume and revenue.

High Volume + High Revenue = Star Products
High Volume + Low Revenue  = Volume Products
Low Volume + High Revenue  = Premium Products
Low Volume + Low Revenue   = Low Performers

This helps identify which products drive volume,
which products generate high-value sales,
and which products may need attention.
========================================================= */

WITH product_metrics AS (

    SELECT

        product_id,

        COUNT(*) AS units_sold,

        ROUND(
            SUM(total_amount),
            2
        ) AS revenue

    FROM order_items

    GROUP BY product_id

),

product_avg AS (

    SELECT

        product_id,
        units_sold,
        revenue,

        AVG(units_sold) OVER () AS avg_units_sold,
        AVG(revenue) OVER () AS avg_revenue

    FROM product_metrics

)

SELECT

    product_id,

    units_sold,

    revenue,

    CASE

        WHEN units_sold >= avg_units_sold
             AND revenue >= avg_revenue
            THEN 'Star Product'

        WHEN units_sold >= avg_units_sold
             AND revenue < avg_revenue
            THEN 'Volume Product'

        WHEN units_sold < avg_units_sold
             AND revenue >= avg_revenue
            THEN 'Premium Product'

        ELSE 'Low Performer'

    END AS product_segment

FROM product_avg

ORDER BY revenue DESC;

/* =========================================================
MONTHLY ORDER & REVENUE PERFORMANCE

Tracks order volume and revenue month by month.

This helps identify:
- Growth periods
- Declining periods
- Seasonal demand
- Changes in customer purchasing activity
========================================================= */

SELECT

    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    ) AS month,

    COUNT(DISTINCT o.order_id) AS total_orders,

    SUM(oi.order_item_id) AS units_sold,

    ROUND(
        SUM(oi.total_amount),
        2
    ) AS revenue,

    ROUND(
        SUM(oi.total_amount) /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'delivered'

GROUP BY
    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    )

ORDER BY month;

/* =========================================================
MONTHLY ORDER & REVENUE PERFORMANCE

Tracks order volume and revenue month by month.

This helps identify:
- Growth periods
- Declining periods
- Seasonal demand
- Changes in customer purchasing activity
========================================================= */

SELECT

    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    ) AS month,

    COUNT(DISTINCT o.order_id) AS total_orders,

    SUM(oi.order_item_id) AS units_sold,

    ROUND(
        SUM(oi.total_amount),
        2
    ) AS revenue,

    ROUND(
        SUM(oi.total_amount) /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'delivered'

GROUP BY
    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    )

ORDER BY month;

/* =========================================================
MONTHLY REVENUE GROWTH

Calculates month-over-month revenue growth.

This helps identify whether the business is
growing or declining over time.
========================================================= */

WITH monthly_revenue AS (

    SELECT

        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        ) AS month,

        SUM(oi.total_amount) AS revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        )

),

revenue_growth AS (

    SELECT

        month,

        revenue,

        LAG(revenue)
        OVER (
            ORDER BY month
        ) AS previous_month_revenue

    FROM monthly_revenue

)

SELECT

    month,

    ROUND(
        revenue,
        2
    ) AS revenue,

    ROUND(
        previous_month_revenue,
        2
    ) AS previous_month_revenue,

    ROUND(
        (
            revenue - previous_month_revenue
        )
        / NULLIF(previous_month_revenue, 0)
        * 100,
        2
    ) AS revenue_growth_pct

FROM revenue_growth

ORDER BY month;

/* =========================================================
MONTHLY ORDER GROWTH

Calculates month-over-month order growth.

This shows whether customer purchasing activity
is increasing or decreasing over time.
========================================================= */

WITH monthly_orders AS (

    SELECT

        DATE_FORMAT(
            order_purchase_timestamp,
            '%Y-%m'
        ) AS month,

        COUNT(DISTINCT order_id) AS total_orders

    FROM orders

    WHERE order_status = 'delivered'

    GROUP BY
        DATE_FORMAT(
            order_purchase_timestamp,
            '%Y-%m'
        )

),

order_growth AS (

    SELECT

        month,

        total_orders,

        LAG(total_orders)
        OVER (
            ORDER BY month
        ) AS previous_month_orders

    FROM monthly_orders

)

SELECT

    month,

    total_orders,

    previous_month_orders,

    ROUND(
        (
            total_orders - previous_month_orders
        )
        / NULLIF(previous_month_orders, 0)
        * 100,
        2
    ) AS order_growth_pct

FROM order_growth

ORDER BY month;

/* =========================================================
ORDER STATUS ANALYSIS

Analyzes the distribution of orders across
different order statuses.

This helps identify the proportion of:
- Delivered
- Shipped
- Canceled
- Unavailable
- Other orders
========================================================= */

SELECT

    order_status,

    COUNT(*) AS total_orders,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS order_percentage

FROM orders

GROUP BY order_status

ORDER BY total_orders DESC;

/* =========================================================
CANCELLATION RATE

Measures the percentage of orders that were canceled.

A high cancellation rate may indicate problems with:
- Inventory
- Order processing
- Customer experience
- Seller fulfillment
========================================================= */

SELECT

    COUNT(*) AS total_orders,

    SUM(
        CASE
            WHEN order_status = 'canceled'
            THEN 1
            ELSE 0
        END
    ) AS canceled_orders,

    ROUND(
        SUM(
            CASE
                WHEN order_status = 'canceled'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate_pct

FROM orders;

/* =========================================================
AVERAGE DELIVERY TIME

Measures the average number of days between
order purchase and customer delivery.

This is an important logistics KPI for evaluating
overall delivery efficiency.
========================================================= */

SELECT

    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),
        2
    ) AS average_delivery_days

FROM orders

WHERE order_status = 'delivered'

AND order_delivered_customer_date IS NOT NULL;

/* =========================================================
ON-TIME DELIVERY RATE

Compares the actual delivery date with
the estimated delivery date.

Orders delivered on or before the estimated
date are considered on-time.
========================================================= */

SELECT

    COUNT(*) AS delivered_orders,

    SUM(
        CASE
            WHEN order_delivered_customer_date
                 <= order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS on_time_orders,

    SUM(
        CASE
            WHEN order_delivered_customer_date
                 > order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS late_orders,

    ROUND(
        SUM(
            CASE
                WHEN order_delivered_customer_date
                     <= order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS on_time_delivery_rate_pct

FROM orders

WHERE order_status = 'delivered'

AND order_delivered_customer_date IS NOT NULL

AND order_estimated_delivery_date IS NOT NULL;, /* =========================================================
AVERAGE DELIVERY DELAY

Measures how many days late the delayed orders
were delivered compared with their estimated
delivery dates.

This helps identify the severity of delivery delays.
========================================================= */

SELECT

    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_estimated_delivery_date
            )
        ),
        2
    ) AS average_delay_days

FROM orders

WHERE order_status = 'delivered'

AND order_delivered_customer_date IS NOT NULL

AND order_estimated_delivery_date IS NOT NULL

AND order_delivered_customer_date
    > order_estimated_delivery_date;
    
/* =========================================================
DELIVERY PERFORMANCE BY MONTH

Analyzes delivery performance month by month.

Measures:
- Average delivery time
- On-time deliveries
- Late deliveries
- On-time delivery rate

This helps identify months with logistics problems
or improvements.
========================================================= */

SELECT

    DATE_FORMAT(
        order_purchase_timestamp,
        '%Y-%m'
    ) AS month,

    COUNT(*) AS delivered_orders,

    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),
        2
    ) AS average_delivery_days,

    SUM(
        CASE
            WHEN order_delivered_customer_date
                 <= order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS on_time_orders,

    SUM(
        CASE
            WHEN order_delivered_customer_date
                 > order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS late_orders,

    ROUND(
        SUM(
            CASE
                WHEN order_delivered_customer_date
                     <= order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS on_time_delivery_rate_pct

FROM orders

WHERE order_status = 'delivered'

AND order_delivered_customer_date IS NOT NULL

AND order_estimated_delivery_date IS NOT NULL

GROUP BY
    DATE_FORMAT(
        order_purchase_timestamp,
        '%Y-%m'
    )

ORDER BY month;

/* =========================================================
DELIVERY PERFORMANCE BY STATE

Compares delivery performance across customer states.

This helps identify geographic regions with:
- Faster delivery
- Slower delivery
- Higher late-delivery rates
========================================================= */

SELECT

    c.customer_state,

    COUNT(*) AS delivered_orders,

    ROUND(
        AVG(
            DATEDIFF(
                o.order_delivered_customer_date,
                o.order_purchase_timestamp
            )
        ),
        2
    ) AS average_delivery_days,

    SUM(
        CASE
            WHEN o.order_delivered_customer_date
                 <= o.order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS on_time_orders,

    SUM(
        CASE
            WHEN o.order_delivered_customer_date
                 > o.order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS late_orders,

    ROUND(
        SUM(
            CASE
                WHEN o.order_delivered_customer_date
                     > o.order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS late_delivery_rate_pct

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'

AND o.order_delivered_customer_date IS NOT NULL

AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY c.customer_state

ORDER BY late_delivery_rate_pct DESC;

/* =========================================================
ORDER VALUE VS DELIVERY PERFORMANCE

Compares average order value between:
- On-time orders
- Late orders

This helps determine whether high-value orders
experience different delivery performance.
========================================================= */

WITH order_value AS (

    SELECT

        o.order_id,

        SUM(oi.total_amount) AS order_value,

        CASE

            WHEN o.order_delivered_customer_date
                 <= o.order_estimated_delivery_date

                THEN 'On-Time'

            ELSE 'Late'

        END AS delivery_status

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'

    AND o.order_delivered_customer_date IS NOT NULL

    AND o.order_estimated_delivery_date IS NOT NULL

    GROUP BY
        o.order_id,
        delivery_status

)

SELECT

    delivery_status,

    COUNT(*) AS total_orders,

    ROUND(
        AVG(order_value),
        2
    ) AS average_order_value,

    ROUND(
        SUM(order_value),
        2
    ) AS total_revenue

FROM order_value

GROUP BY delivery_status

ORDER BY total_revenue DESC;







/* =========================================================
BATCH 6 → CUSTOMER RETENTION & COHORT INTELLIGENCE

Analyzes customer purchasing behavior over time.

KPIs covered:
1. Repeat Purchase Rate
2. New vs Repeat Customers by Month
3. Customer Purchase Frequency
4. Customer Lifetime Value
5. Customer Retention by Month
6. Cohort Retention Analysis

These metrics help understand customer loyalty,
repeat purchasing behavior, customer value,
and long-term retention.
========================================================= */


/* =========================================================
1. REPEAT PURCHASE RATE

Measures the percentage of customers who placed
more than one order.

A higher repeat purchase rate indicates stronger
customer loyalty and retention.
========================================================= */

WITH customer_orders AS (

    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id

    WHERE o.order_status NOT IN ('canceled', 'unavailable')

    GROUP BY c.customer_unique_id

)

SELECT

    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN total_orders > 1 THEN 1
            ELSE 0
        END
    ) AS repeat_customers,

    ROUND(
        SUM(
            CASE
                WHEN total_orders > 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS repeat_purchase_rate_pct

FROM customer_orders;


/* =========================================================
2. NEW VS REPEAT CUSTOMERS BY MONTH

Classifies customers as:

New Customer   → First purchase occurred in that month
Repeat Customer → Had purchased before that month

This helps identify whether monthly growth comes
from acquiring new customers or retaining existing ones.
========================================================= */

WITH customer_orders AS (

    SELECT
        c.customer_unique_id,
        o.order_id,
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        ) AS order_month

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id

    WHERE o.order_status NOT IN ('canceled', 'unavailable')

),

first_purchase AS (

    SELECT
        customer_unique_id,
        MIN(order_month) AS first_purchase_month

    FROM customer_orders

    GROUP BY customer_unique_id

)

SELECT

    co.order_month,

    COUNT(DISTINCT
        CASE
            WHEN co.order_month = fp.first_purchase_month
            THEN co.customer_unique_id
        END
    ) AS new_customers,

    COUNT(DISTINCT
        CASE
            WHEN co.order_month > fp.first_purchase_month
            THEN co.customer_unique_id
        END
    ) AS repeat_customers,

    COUNT(DISTINCT co.customer_unique_id) AS total_active_customers

FROM customer_orders co

JOIN first_purchase fp
    ON co.customer_unique_id = fp.customer_unique_id

GROUP BY co.order_month

ORDER BY co.order_month;


/* =========================================================
3. CUSTOMER PURCHASE FREQUENCY

Measures how frequently customers purchase.

This identifies:
- One-time customers
- Occasional customers
- Frequent customers

Useful for understanding customer loyalty.
========================================================= */

WITH customer_orders AS (

    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id

    WHERE o.order_status NOT IN ('canceled', 'unavailable')

    GROUP BY c.customer_unique_id

)

SELECT

    CASE

        WHEN total_orders = 1
            THEN 'One-Time Customer'

        WHEN total_orders BETWEEN 2 AND 3
            THEN 'Occasional Customer'

        WHEN total_orders BETWEEN 4 AND 6
            THEN 'Frequent Customer'

        ELSE 'Highly Loyal Customer'

    END AS customer_segment,

    COUNT(*) AS customers,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage

FROM customer_orders

GROUP BY

    CASE

        WHEN total_orders = 1
            THEN 'One-Time Customer'

        WHEN total_orders BETWEEN 2 AND 3
            THEN 'Occasional Customer'

        WHEN total_orders BETWEEN 4 AND 6
            THEN 'Frequent Customer'

        ELSE 'Highly Loyal Customer'

    END

ORDER BY customers DESC;


/* =========================================================
4. CUSTOMER LIFETIME VALUE (CLV)

Calculates the total revenue generated by each customer
across their entire purchasing history.

This helps identify high-value customers.

CLV is one of the most useful customer analytics KPIs
for an e-commerce business.
========================================================= */

WITH customer_revenue AS (

    SELECT

        c.customer_unique_id,

        COUNT(DISTINCT o.order_id) AS total_orders,

        ROUND(
            SUM(oi.total_amount),
            2
        ) AS lifetime_value

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status NOT IN ('canceled', 'unavailable')

    GROUP BY c.customer_unique_id

)

SELECT

    customer_unique_id,

    total_orders,

    lifetime_value,

    CASE

        WHEN lifetime_value >= 1000
            THEN 'High Value Customer'

        WHEN lifetime_value >= 500
            THEN 'Medium Value Customer'

        ELSE 'Low Value Customer'

    END AS customer_value_segment

FROM customer_revenue

ORDER BY lifetime_value DESC;


/* =========================================================
5. CUSTOMER VALUE SEGMENT DISTRIBUTION

Shows how customers are distributed across
Low, Medium and High Lifetime Value segments.

This helps understand how much of the customer base
belongs to high-value segments.
========================================================= */

WITH customer_revenue AS (

    SELECT

        c.customer_unique_id,

        ROUND(
            SUM(oi.total_amount),
            2
        ) AS lifetime_value

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status NOT IN ('canceled', 'unavailable')

    GROUP BY c.customer_unique_id

),

customer_segments AS (

    SELECT

        customer_unique_id,

        lifetime_value,

        CASE

            WHEN lifetime_value >= 1000
                THEN 'High Value'

            WHEN lifetime_value >= 500
                THEN 'Medium Value'

            ELSE 'Low Value'

        END AS value_segment

    FROM customer_revenue

)

SELECT

    value_segment,

    COUNT(*) AS customers,

    ROUND(
        SUM(lifetime_value),
        2
    ) AS total_customer_value,

    ROUND(
        AVG(lifetime_value),
        2
    ) AS average_customer_value,

    ROUND(
        SUM(lifetime_value) * 100.0 /
        SUM(SUM(lifetime_value)) OVER (),
        2
    ) AS revenue_contribution_pct

FROM customer_segments

GROUP BY value_segment

ORDER BY total_customer_value DESC;


/* =========================================================
6. COHORT RETENTION ANALYSIS

Groups customers according to the month of their
first purchase and tracks how many return in later months.

This is an advanced retention KPI commonly used
in e-commerce and subscription analytics.

cohort_month = customer's first purchase month
activity_month = month in which customer purchased
retention_month = months since first purchase
========================================================= */

WITH customer_orders AS (

    SELECT

        c.customer_unique_id,

        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m-01'
        ) AS order_month

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id

    WHERE o.order_status NOT IN ('canceled', 'unavailable')

    GROUP BY

        c.customer_unique_id,
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m-01'
        )

),

customer_cohort AS (

    SELECT

        customer_unique_id,

        MIN(order_month) AS cohort_month

    FROM customer_orders

    GROUP BY customer_unique_id

)

SELECT

    cc.cohort_month,

    co.order_month AS activity_month,

    TIMESTAMPDIFF(
        MONTH,
        cc.cohort_month,
        co.order_month
    ) AS retention_month,

    COUNT(DISTINCT co.customer_unique_id)
        AS active_customers

FROM customer_orders co

JOIN customer_cohort cc

    ON co.customer_unique_id =
       cc.customer_unique_id

GROUP BY

    cc.cohort_month,

    co.order_month

ORDER BY

    cc.cohort_month,

    retention_month;


/* =========================================================
7. AVERAGE CUSTOMER LIFETIME VALUE

Calculates the average revenue generated
per customer.

Useful as a high-level customer value KPI.
========================================================= */

WITH customer_revenue AS (

    SELECT

        c.customer_unique_id,

        SUM(oi.total_amount) AS lifetime_value

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status NOT IN ('canceled', 'unavailable')

    GROUP BY c.customer_unique_id

)

SELECT

    COUNT(*) AS total_customers,

    ROUND(
        AVG(lifetime_value),
        2
    ) AS average_customer_lifetime_value,

    ROUND(
        MIN(lifetime_value),
        2
    ) AS minimum_customer_value,

    ROUND(
        MAX(lifetime_value),
        2
    ) AS maximum_customer_value,

    ROUND(
        SUM(lifetime_value),
        2
    ) AS total_customer_revenue

FROM customer_revenue;




DESCRIBE payments;

/* =========================================================
1. PAYMENT METHOD PERFORMANCE
========================================================= */

SELECT
    payment_type,
    COUNT(*) AS payment_transactions,
    COUNT(DISTINCT order_id) AS unique_orders,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;

# =========================================================

# BATCH 7 → PAYMENT & TRANSACTION INTELLIGENCE

# =========================================================

/* =========================================================
2. PAYMENT METHOD REVENUE CONTRIBUTION

Shows the percentage of total payment value contributed
by each payment method.
========================================================= */

SELECT
payment_type,
ROUND(SUM(payment_value), 2) AS total_payment_value,
ROUND(
SUM(payment_value)
/ (SELECT SUM(payment_value) FROM payments) * 100,
2
) AS payment_value_contribution_pct
FROM payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;

/* =========================================================
3. INSTALLMENT PERFORMANCE

Shows how payment value and transaction volume vary
across different installment levels.
========================================================= */

SELECT
payment_installments,
COUNT(*) AS payment_transactions,
COUNT(DISTINCT order_id) AS unique_orders,
ROUND(SUM(payment_value), 2) AS total_payment_value,
ROUND(AVG(payment_value), 2) AS average_payment_value
FROM payments
GROUP BY payment_installments
ORDER BY payment_installments;

/* =========================================================
4. INSTALLMENT DISTRIBUTION

Shows what percentage of payment transactions use
each installment level.
========================================================= */

SELECT
payment_installments,
COUNT(*) AS payment_transactions,
ROUND(
COUNT(*) /
(SELECT COUNT(*) FROM payments) * 100,
2
) AS transaction_percentage
FROM payments
GROUP BY payment_installments
ORDER BY payment_installments;

/* =========================================================
5. PAYMENT TYPE + INSTALLMENT ANALYSIS

Identifies the most valuable combinations of payment
method and installment level.
========================================================= */

SELECT
payment_type,
payment_installments,
COUNT(DISTINCT order_id) AS unique_orders,
ROUND(SUM(payment_value), 2) AS total_payment_value,
ROUND(AVG(payment_value), 2) AS average_payment_value
FROM payments
GROUP BY
payment_type,
payment_installments
ORDER BY total_payment_value DESC;

/* =========================================================
6. PAYMENT METHOD ORDER COVERAGE

Shows how many unique orders use each payment method
and its percentage of total payment orders.
========================================================= */

SELECT
payment_type,
COUNT(DISTINCT order_id) AS unique_orders,
ROUND(
COUNT(DISTINCT order_id)
/ (
SELECT COUNT(DISTINCT order_id)
FROM payments
) * 100,
2
) AS order_coverage_pct
FROM payments
GROUP BY payment_type
ORDER BY unique_orders DESC;

/* =========================================================
7. MULTIPLE-PAYMENT ORDERS

Identifies orders where customers used multiple
payment transactions.
========================================================= */
/* =========================================================
8. MULTIPLE-PAYMENT ORDER RATE

Measures the percentage of paid orders that contain
more than one payment transaction.
========================================================= */

WITH order_payment_summary AS (

SELECT
    order_id,
    COUNT(*) AS payment_transactions
FROM payments
GROUP BY order_id

)

SELECT


COUNT(*) AS total_paid_orders,

SUM(
    CASE
        WHEN payment_transactions > 1 THEN 1
        ELSE 0
    END
) AS multi_payment_orders,

ROUND(
    SUM(
        CASE
            WHEN payment_transactions > 1 THEN 1
            ELSE 0
        END
    ) / COUNT(*) * 100,
    2
) AS multi_payment_order_rate_pct


FROM order_payment_summary;

SELECT
order_id,
COUNT(*) AS payment_transactions,
COUNT(DISTINCT payment_type) AS payment_methods_used,
ROUND(SUM(payment_value), 2) AS total_payment_value
FROM payments
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY payment_transactions DESC;

/* =========================================================
8. MULTIPLE-PAYMENT ORDER RATE

Measures the percentage of orders that contain
multiple payment transactions.
========================================================= */



/* =========================================================
9. HIGHEST-VALUE PAYMENT TRANSACTIONS

Identifies the largest individual payment transactions.
========================================================= */

SELECT
order_id,
payment_type,
payment_installments,
ROUND(payment_value, 2) AS payment_value
FROM payments
ORDER BY payment_value DESC
LIMIT 20;

/* =========================================================
10. PAYMENT VALUE BY MONTH

Tracks total payment value and average payment value
over time.
========================================================= */

SELECT

DATE_FORMAT(
    o.order_purchase_timestamp,
    '%Y-%m'
) AS month,

COUNT(DISTINCT p.order_id) AS paid_orders,

ROUND(
    SUM(p.payment_value),
    2
) AS total_payment_value,

ROUND(
    AVG(p.payment_value),
    2
) AS average_payment_value


FROM payments p

JOIN orders o
ON p.order_id = o.order_id

GROUP BY
DATE_FORMAT(
o.order_purchase_timestamp,
'%Y-%m'
)

ORDER BY month;

/* =========================================================
11. PAYMENT METHOD MONTHLY TREND

Shows how payment method usage changes over time.
========================================================= */

SELECT


DATE_FORMAT(
    o.order_purchase_timestamp,
    '%Y-%m'
) AS month,

p.payment_type,

COUNT(DISTINCT p.order_id) AS unique_orders,

ROUND(
    SUM(p.payment_value),
    2
) AS total_payment_value

FROM payments p

JOIN orders o
ON p.order_id = o.order_id

GROUP BY

DATE_FORMAT(
    o.order_purchase_timestamp,
    '%Y-%m'
),

p.payment_type


ORDER BY
month,
total_payment_value DESC;

/* =========================================================
12. HIGH-VALUE PAYMENT SEGMENTATION

Segments payment transactions into:
Low Value,
Medium Value,
High Value.

This helps identify the distribution of transaction value.
========================================================= */

SELECT


CASE

    WHEN payment_value < 100
        THEN 'Low Value'

    WHEN payment_value BETWEEN 100 AND 500
        THEN 'Medium Value'

    ELSE 'High Value'

END AS payment_value_segment,

COUNT(*) AS payment_transactions,

ROUND(
    SUM(payment_value),
    2
) AS total_payment_value,

ROUND(
    AVG(payment_value),
    2
) AS average_payment_value


FROM payments

GROUP BY


CASE

    WHEN payment_value < 100
        THEN 'Low Value'

    WHEN payment_value BETWEEN 100 AND 500
        THEN 'Medium Value'

    ELSE 'High Value'

END

ORDER BY total_payment_value DESC;

/* =========================================================
13. INSTALLMENT SEGMENTATION

Classifies customers' payment behavior based on
the number of installments.
========================================================= */

SELECT


CASE

    WHEN payment_installments = 1
        THEN 'Single Payment'

    WHEN payment_installments BETWEEN 2 AND 5
        THEN 'Low Installment'

    WHEN payment_installments BETWEEN 6 AND 10
        THEN 'Medium Installment'

    ELSE 'High Installment'

END AS installment_segment,

COUNT(*) AS payment_transactions,

COUNT(DISTINCT order_id) AS unique_orders,

ROUND(
    SUM(payment_value),
    2
) AS total_payment_value,

ROUND(
    AVG(payment_value),
    2
) AS average_payment_value

FROM payments

GROUP BY


CASE

    WHEN payment_installments = 1
        THEN 'Single Payment'

    WHEN payment_installments BETWEEN 2 AND 5
        THEN 'Low Installment'

    WHEN payment_installments BETWEEN 6 AND 10
        THEN 'Medium Installment'

    ELSE 'High Installment'

END

ORDER BY total_payment_value DESC;

/* =========================================================
14. PAYMENT METHOD CONCENTRATION

Shows how dependent the business is on each payment
method based on total payment value.
========================================================= */

SELECT


payment_type,

ROUND(
    SUM(payment_value),
    2
) AS total_payment_value,

ROUND(
    SUM(payment_value)
    / (
        SELECT MAX(total_value)
        FROM (
            SELECT
                payment_type,
                SUM(payment_value) AS total_value
            FROM payments
            GROUP BY payment_type
        ) x
    ) * 100,
    2
) AS value_vs_top_method_pct


FROM payments

GROUP BY payment_type

ORDER BY total_payment_value DESC;

/* =========================================================
15. PAYMENT METHOD + INSTALLMENT RANKING

Ranks payment combinations based on total payment value.
Useful for identifying the strongest payment behaviors.
========================================================= */

WITH payment_combinations AS (


SELECT

    payment_type,

    payment_installments,

    COUNT(DISTINCT order_id) AS unique_orders,

    SUM(payment_value) AS total_payment_value

FROM payments

GROUP BY
    payment_type,
    payment_installments


)

SELECT


payment_type,

payment_installments,

unique_orders,

ROUND(
    total_payment_value,
    2
) AS total_payment_value,

RANK() OVER (
    ORDER BY total_payment_value DESC
) AS payment_combination_rank


FROM payment_combinations

ORDER BY payment_combination_rank;


/* =========================================================
BATCH 7 → BUSINESS & PROFITABILITY INTELLIGENCE

Advanced business KPIs:
- Revenue
- Freight cost
- Freight-to-revenue ratio
- Net revenue after freight
- Revenue per order
- Revenue per customer
- Average basket value
- Units per order
- Customer revenue concentration
- Product revenue concentration
- Pareto analysis
========================================================= */


/* =========================================================
1. OVERALL BUSINESS KPI SCORECARD
========================================================= */

SELECT

    COUNT(DISTINCT order_id) AS total_orders,

    COUNT(*) AS total_units_sold,

    ROUND(
        SUM(price),
        2
    ) AS total_revenue,

    ROUND(
        SUM(freight_value),
        2
    ) AS total_freight_cost,

    ROUND(
        SUM(price) - SUM(freight_value),
        2
    ) AS net_revenue_after_freight,

    ROUND(
        SUM(freight_value)
        / NULLIF(SUM(price), 0) * 100,
        2
    ) AS freight_to_revenue_pct,

    ROUND(
        SUM(price)
        / COUNT(DISTINCT order_id),
        2
    ) AS revenue_per_order,

    ROUND(
        COUNT(*)
        / COUNT(DISTINCT order_id),
        2
    ) AS units_per_order

FROM order_items;


/* =========================================================
2. REVENUE PER CUSTOMER
========================================================= */

SELECT

    COUNT(DISTINCT c.customer_unique_id)
        AS total_customers,

    ROUND(
        SUM(oi.price),
        2
    ) AS total_revenue,

    ROUND(
        SUM(oi.price)
        / COUNT(DISTINCT c.customer_unique_id),
        2
    ) AS revenue_per_customer

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN customers c
    ON o.customer_id = c.customer_id

WHERE o.order_status NOT IN
    ('canceled', 'unavailable');


/* =========================================================
3. AVERAGE BASKET SIZE
========================================================= */

WITH order_summary AS (

    SELECT

        order_id,

        COUNT(*) AS units,

        SUM(price) AS order_revenue

    FROM order_items

    GROUP BY order_id

)

SELECT

    ROUND(
        AVG(units),
        2
    ) AS average_units_per_order,

    ROUND(
        AVG(order_revenue),
        2
    ) AS average_basket_value,

    ROUND(
        SUM(order_revenue)
        / COUNT(*),
        2
    ) AS revenue_per_order

FROM order_summary;


/* =========================================================
4. FREIGHT BURDEN BY MONTH
========================================================= */

SELECT

    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    ) AS month,

    ROUND(
        SUM(oi.price),
        2
    ) AS revenue,

    ROUND(
        SUM(oi.freight_value),
        2
    ) AS freight_cost,

    ROUND(
        SUM(oi.freight_value)
        / NULLIF(SUM(oi.price), 0) * 100,
        2
    ) AS freight_to_revenue_pct,

    ROUND(
        SUM(oi.price)
        - SUM(oi.freight_value),
        2
    ) AS net_revenue_after_freight

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

WHERE o.order_status NOT IN
    ('canceled', 'unavailable')

GROUP BY
    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    )

ORDER BY month;


/* =========================================================
5. CUSTOMER REVENUE CONCENTRATION
========================================================= */

WITH customer_revenue AS (

    SELECT

        c.customer_unique_id,

        SUM(oi.price) AS revenue

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    JOIN customers c
        ON o.customer_id = c.customer_id

    WHERE o.order_status NOT IN
        ('canceled', 'unavailable')

    GROUP BY c.customer_unique_id

),

ranked_customers AS (

    SELECT

        customer_unique_id,

        revenue,

        ROW_NUMBER() OVER (
            ORDER BY revenue DESC
        ) AS customer_rank,

        COUNT(*) OVER () AS total_customers

    FROM customer_revenue

)

SELECT

    COUNT(*) AS top_20_percent_customers,

    ROUND(
        SUM(revenue),
        2
    ) AS top_20_percent_revenue,

    ROUND(
        SUM(revenue)
        /
        (
            SELECT SUM(revenue)
            FROM customer_revenue
        ) * 100,
        2
    ) AS top_20_revenue_contribution_pct

FROM ranked_customers

WHERE customer_rank
      <= CEIL(total_customers * 0.20);


/* =========================================================
6. TOP 20% PRODUCT REVENUE CONTRIBUTION
========================================================= */

WITH product_revenue AS (

    SELECT

        product_id,

        SUM(price) AS revenue

    FROM order_items

    GROUP BY product_id

),

ranked_products AS (

    SELECT

        product_id,

        revenue,

        ROW_NUMBER() OVER (
            ORDER BY revenue DESC
        ) AS product_rank,

        COUNT(*) OVER () AS total_products

    FROM product_revenue

)

SELECT

    COUNT(*) AS top_20_percent_products,

    ROUND(
        SUM(revenue),
        2
    ) AS top_20_percent_revenue,

    ROUND(
        SUM(revenue)
        /
        (
            SELECT SUM(revenue)
            FROM product_revenue
        ) * 100,
        2
    ) AS top_20_revenue_contribution_pct

FROM ranked_products

WHERE product_rank
      <= CEIL(total_products * 0.20);


/* =========================================================
7. PRODUCT REVENUE CONCENTRATION RANKING
========================================================= */

WITH product_revenue AS (

    SELECT

        product_id,

        COUNT(*) AS units_sold,

        SUM(price) AS revenue

    FROM order_items

    GROUP BY product_id

),

ranked_products AS (

    SELECT

        product_id,

        units_sold,

        revenue,

        RANK() OVER (
            ORDER BY revenue DESC
        ) AS revenue_rank

    FROM product_revenue

)

SELECT

    product_id,

    units_sold,

    ROUND(
        revenue,
        2
    ) AS revenue,

    revenue_rank,

    ROUND(
        revenue
        /
        (
            SELECT SUM(revenue)
            FROM product_revenue
        ) * 100,
        2
    ) AS revenue_contribution_pct

FROM ranked_products

ORDER BY revenue_rank;


/* =========================================================
8. HIGH REVENUE + LOW VOLUME PRODUCTS
========================================================= */

WITH product_metrics AS (

    SELECT

        product_id,

        COUNT(*) AS units_sold,

        SUM(price) AS revenue

    FROM order_items

    GROUP BY product_id

),

product_avg AS (

    SELECT

        product_id,

        units_sold,

        revenue,

        AVG(units_sold) OVER () AS avg_units,

        AVG(revenue) OVER () AS avg_revenue

    FROM product_metrics

)

SELECT

    product_id,

    units_sold,

    ROUND(
        revenue,
        2
    ) AS revenue,

    'High Revenue - Low Volume'
        AS business_segment

FROM product_avg

WHERE revenue >= avg_revenue

  AND units_sold < avg_units

ORDER BY revenue DESC;


/* =========================================================
9. HIGH VOLUME + LOW REVENUE PRODUCTS
========================================================= */

WITH product_metrics AS (

    SELECT

        product_id,

        COUNT(*) AS units_sold,

        SUM(price) AS revenue

    FROM order_items

    GROUP BY product_id

),

product_avg AS (

    SELECT

        product_id,

        units_sold,

        revenue,

        AVG(units_sold) OVER () AS avg_units,

        AVG(revenue) OVER () AS avg_revenue

    FROM product_metrics

)

SELECT

    product_id,

    units_sold,

    ROUND(
        revenue,
        2
    ) AS revenue,

    'High Volume - Low Revenue'
        AS business_segment

FROM product_avg

WHERE units_sold >= avg_units

  AND revenue < avg_revenue

ORDER BY units_sold DESC;


/* =========================================================
10. LOW REVENUE + HIGH FREIGHT PRODUCTS
========================================================= */

WITH product_metrics AS (

    SELECT

        product_id,

        SUM(price) AS revenue,

        SUM(freight_value) AS freight_cost

    FROM order_items

    GROUP BY product_id

),

product_avg AS (

    SELECT

        product_id,

        revenue,

        freight_cost,

        AVG(revenue) OVER () AS avg_revenue,

        AVG(freight_cost) OVER () AS avg_freight

    FROM product_metrics

)

SELECT

    product_id,

    ROUND(
        revenue,
        2
    ) AS revenue,

    ROUND(
        freight_cost,
        2
    ) AS freight_cost,

    ROUND(
        freight_cost
        / NULLIF(revenue, 0) * 100,
        2
    ) AS freight_to_revenue_pct

FROM product_avg

WHERE revenue < avg_revenue

  AND freight_cost >= avg_freight

ORDER BY freight_to_revenue_pct DESC;


/* =========================================================
11. REVENUE PER ORDER BY MONTH
========================================================= */

SELECT

    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    ) AS month,

    COUNT(DISTINCT o.order_id)
        AS total_orders,

    ROUND(
        SUM(oi.price),
        2
    ) AS revenue,

    ROUND(
        SUM(oi.price)
        / COUNT(DISTINCT o.order_id),
        2
    ) AS revenue_per_order

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status NOT IN
    ('canceled', 'unavailable')

GROUP BY
    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    )

ORDER BY month;


/* =========================================================
12. REVENUE PER CUSTOMER BY STATE
========================================================= */

SELECT

    c.customer_state,

    COUNT(DISTINCT c.customer_unique_id)
        AS customers,

    ROUND(
        SUM(oi.price),
        2
    ) AS revenue,

    ROUND(
        SUM(oi.price)
        / COUNT(DISTINCT c.customer_unique_id),
        2
    ) AS revenue_per_customer

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status NOT IN
    ('canceled', 'unavailable')

GROUP BY
    c.customer_state

ORDER BY revenue_per_customer DESC;


/* =========================================================
13. BUSINESS REVENUE PARETO
========================================================= */

WITH product_revenue AS (

    SELECT

        product_id,

        SUM(price) AS revenue

    FROM order_items

    GROUP BY product_id

),

ranked_products AS (

    SELECT

        product_id,

        revenue,

        SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS cumulative_revenue,

        SUM(revenue) OVER () AS total_revenue

    FROM product_revenue

)

SELECT

    product_id,

    ROUND(
        revenue,
        2
    ) AS revenue,

    ROUND(
        cumulative_revenue,
        2
    ) AS cumulative_revenue,

    ROUND(
        cumulative_revenue
        / total_revenue * 100,
        2
    ) AS cumulative_revenue_pct

FROM ranked_products

ORDER BY revenue DESC;


/* =========================================================
14. CUSTOMER PARETO
========================================================= */

WITH customer_revenue AS (

    SELECT

        c.customer_unique_id,

        SUM(oi.price) AS revenue

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status NOT IN
        ('canceled', 'unavailable')

    GROUP BY c.customer_unique_id

),

ranked_customers AS (

    SELECT

        customer_unique_id,

        revenue,

        SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS cumulative_revenue,

        SUM(revenue) OVER () AS total_revenue

    FROM customer_revenue

)

SELECT

    customer_unique_id,

    ROUND(
        revenue,
        2
    ) AS revenue,

    ROUND(
        cumulative_revenue,
        2
    ) AS cumulative_revenue,

    ROUND(
        cumulative_revenue
        / total_revenue * 100,
        2
    ) AS cumulative_revenue_pct

FROM ranked_customers

ORDER BY revenue DESC;


SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS customers,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(AVG(oi.price), 2) AS average_item_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC;

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        COUNT(DISTINCT o.order_id) * 100.0 /
        (SELECT COUNT(DISTINCT order_id)
         FROM orders
         WHERE order_status = 'delivered'),
        2
    ) AS order_contribution_pct
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_orders DESC;

SELECT
    c.customer_state,
    ROUND(SUM(oi.freight_value), 2) AS total_freight_cost,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(
        SUM(oi.freight_value) * 100.0 /
        SUM(oi.price),
        2
    ) AS freight_to_revenue_pct
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY freight_to_revenue_pct DESC;

SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS customers,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(
        SUM(oi.price) /
        COUNT(DISTINCT c.customer_unique_id),
        2
    ) AS revenue_per_customer
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue_per_customer DESC;

SELECT
    c.customer_state,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_cost,
    ROUND(
        SUM(oi.price) - SUM(oi.freight_value),
        2
    ) AS net_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY net_revenue DESC;

SELECT
    s.seller_state,
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_cost
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
JOIN orders o
    ON oi.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY
    s.seller_state,
    c.customer_state
ORDER BY orders DESC;

SELECT
    CASE
        WHEN s.seller_state = c.customer_state
        THEN 'Same State'
        ELSE 'Cross State'
    END AS shipping_type,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_cost
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
JOIN orders o
    ON oi.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY shipping_type;


-- Seller state → Customer state
-- Find top seller/customer state combinations
SELECT
    s.seller_state,
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_cost
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
JOIN orders o
    ON oi.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_state, c.customer_state
ORDER BY orders DESC;

SHOW VARIABLES LIKE 'wait_timeout';

SHOW VARIABLES LIKE 'net_read_timeout';
SHOW VARIABLES LIKE 'net_write_timeout';
SHOW VARIABLES LIKE 'max_allowed_packet';

SELECT 1;

SELECT
    s.seller_state,
    c.customer_state,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_cost
FROM order_items oi
JOIN sellers s
    ON oi.seller_id = s.seller_id
JOIN orders o
    ON oi.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY
    s.seller_state,
    c.customer_state
ORDER BY orders DESC;

CREATE TEMPORARY TABLE temp_order_items AS
SELECT
    order_id,
    seller_id,
    ROUND(SUM(price), 2) AS revenue,
    ROUND(SUM(freight_value), 2) AS freight_cost
FROM order_items
GROUP BY order_id, seller_id;

SELECT COUNT(*) FROM temp_order_items;

CREATE TEMPORARY TABLE temp_geo AS
SELECT
    t.seller_id,
    o.order_id,
    c.customer_state,
    t.revenue,
    t.freight_cost
FROM temp_order_items t
JOIN orders o
    ON t.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered';

SELECT COUNT(*) FROM temp_geo;

SELECT
    s.seller_state,
    g.customer_state,
    COUNT(DISTINCT g.order_id) AS orders,
    ROUND(SUM(g.revenue), 2) AS revenue,
    ROUND(SUM(g.freight_cost), 2) AS freight_cost
FROM temp_geo g
JOIN sellers s
    ON g.seller_id = s.seller_id
GROUP BY
    s.seller_state,
    g.customer_state
ORDER BY orders DESC;
