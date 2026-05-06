/* 
   PROJECT: SALES DATA CLEANING & ANALYTICS
   AUTHOR: Julia Souto
   GOAL: Clean raw transaction data and generate operational reports.
*/

-- 1. DATA CLEANSING: Handling inconsistencies and missing values
WITH cleaned_sales AS (
    SELECT 
        order_id,
        COALESCE(customer_id, 'Unknown') AS customer_id, -- Handling nulls
        CAST(order_date AS DATE) AS clean_order_date,   -- Standardizing dates
        product_category,
        quantity,
        unit_price,
        -- Calculating gross total per item
        (quantity * unit_price) AS gross_amount
    FROM raw_sales_table
    WHERE order_id IS NOT NULL 
      AND unit_price > 0 -- Rule: ignoring invalid transactions
),

-- 2. BUSINESS LOGIC: Categorizing customer value
customer_segments AS (
    SELECT 
        customer_id,
        SUM(gross_amount) AS total_spent,
        COUNT(order_id) AS total_orders
    FROM cleaned_sales
    GROUP BY customer_id
)

-- 3. FINAL REPORT: Operational KPIs for Management
SELECT 
    p.product_category,
    COUNT(s.order_id) AS total_transactions,
    ROUND(SUM(s.gross_amount), 2) AS total_revenue,
    ROUND(AVG(s.gross_amount), 2) AS average_order_value,
    -- Check: Flagging categories with high return potential (low price/high volume)
    CASE 
        WHEN AVG(s.unit_price) < 10 THEN 'High Volume/Low Margin'
        ELSE 'Premium Segment'
    END AS category_status
FROM cleaned_sales s
GROUP BY p.product_category
ORDER BY total_revenue DESC;
