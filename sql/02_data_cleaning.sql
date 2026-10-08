-
-- SQL + Power BI Sales Analytics
-- 02_data_cleaning.sql
-- Purpose: Document and validate non-destructive data preparation
-- ============================================================

USE sales;
-- ============================================================
-- 1. Currency Standardization
-- ============================================================
-- Currency values are standardized before calculating the
-- normalized INR sales amount.
--
-- INR transactions use the recorded sales amount.
-- USD transactions are converted using exchange_rate_to_inr.
--
-- This transformation is represented below without modifying
-- the source transaction table.

SELECT
    currency,
    COUNT(*) AS transaction_count
FROM transaction_clean
GROUP BY currency
ORDER BY transaction_count DESC;


-- ============================================================
-- 2. Normalized INR Sales Amount Validation
-- ============================================================
-- The finalized transaction_clean table contains
-- sales_amount_inr after currency normalization.

SELECT
    COUNT(*) AS total_transactions,
    SUM(sales_amount_inr IS NULL) AS missing_inr_amounts,
    SUM(
        CASE
            WHEN TRIM(currency) = 'INR'
                 AND sales_amount_inr = sales_amount
            THEN 1
            ELSE 0
        END
    ) AS validated_inr_transactions
FROM transaction_clean;


-- ============================================================
-- 3. Currency Conversion Validation
-- ============================================================
-- Validate USD transactions against the recorded exchange rate.

SELECT
    COUNT(*) AS usd_transactions,
    SUM(
        CASE
            WHEN sales_amount_inr =
                 sales_amount * exchange_rate_to_inr
            THEN 1
            ELSE 0
        END
    ) AS correctly_normalized_usd_transactions
FROM transaction_clean
WHERE TRIM(currency) = 'USD';


-- ============================================================
-- 4. Duplicate Review
-- ============================================================
-- Duplicate records were investigated during the data audit.
-- Records were not blindly deleted because the source data does
-- not contain a dedicated transaction_id.
--
-- The following query identifies repeated transaction-level
-- combinations for review.

SELECT
    product_code,
    customer_code,
    market_code,
    order_date,
    sales_qty,
    sales_amount,
    currency,
    COUNT(*) AS duplicate_count
FROM transaction_clean
GROUP BY
    product_code,
    customer_code,
    market_code,
    order_date,
    sales_qty,
    sales_amount,
    currency
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- ============================================================
-- 5. Zero-Value Transaction Treatment
-- ============================================================
-- Zero-value transactions are retained in the analytical data.
-- They are excluded from Business Sales through the
-- is_business_sale business rule.

SELECT
    COUNT(*) AS zero_value_transactions,
    SUM(sales_amount_inr) AS zero_value_sales
FROM transaction_clean
WHERE sales_amount_inr = 0;


-- ============================================================
-- 6. Negative Transaction Treatment
-- ============================================================
-- Negative transactions are retained for auditability.
-- They are excluded from Business Sales through the
-- is_business_sale business rule.

SELECT
    COUNT(*) AS negative_transactions,
    SUM(sales_amount_inr) AS negative_sales
FROM transaction_clean
WHERE sales_amount_inr < 0;


-- ============================================================
-- 7. Business Sale Classification
-- ============================================================
-- Positive-value transactions are treated as business sales.
--
-- Zero-value and negative transactions remain in the dataset
-- but do not contribute to Business Sales.

SELECT
    CASE
        WHEN sales_amount_inr > 0 THEN 'Business Sale'
        WHEN sales_amount_inr = 0 THEN 'Zero Value'
        WHEN sales_amount_inr < 0 THEN 'Negative'
    END AS sales_value_type,
    COUNT(*) AS transaction_count,
    SUM(sales_amount_inr) AS sales_amount_inr
FROM transaction_clean
GROUP BY
    CASE
        WHEN sales_amount_inr > 0 THEN 'Business Sale'
        WHEN sales_amount_inr = 0 THEN 'Zero Value'
        WHEN sales_amount_inr < 0 THEN 'Negative'
    END
ORDER BY transaction_count DESC;


-- ============================================================
-- 8. Sales Quantity Preservation
-- ============================================================
-- Sales quantity is retained as recorded.
--
-- Quantity is NOT filtered using the business-sale condition.
-- This preserves operational transaction volume.

SELECT
    COUNT(*) AS recorded_transactions,
    SUM(sales_qty) AS total_recorded_sales_quantity
FROM transaction_clean;


-- ============================================================
-- 9. Final Normalization Integrity Check
-- ============================================================
-- Final validation after the cleaning/normalization process.

SELECT
    COUNT(*) AS total_transactions,
    SUM(sales_amount_inr IS NULL) AS missing_normalized_amounts,
    COUNT(DISTINCT TRIM(currency)) AS normalized_currency_count,
    MIN(order_date) AS first_transaction_date,
    MAX(order_date) AS last_transaction_date
FROM transaction_clean;
