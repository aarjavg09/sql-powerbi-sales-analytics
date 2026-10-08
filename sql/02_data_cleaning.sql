-- SQL + Power BI Sales Analytics
-- 02_data_cleaning.sql

USE sales;


-- Check the currencies present in the transaction data.
-- sales_amount_inr is the normalized amount used for analysis.

SELECT
    currency,
    COUNT(*) AS transaction_count
FROM transaction_clean
GROUP BY currency
ORDER BY transaction_count DESC;


-- Check that INR transactions were kept at their original amount
-- and that no normalized INR values are missing.

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


-- Validate the INR conversion for USD transactions.

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


-- Review repeated transaction records.
-- There is no transaction_id in the source data, so duplicates
-- are reviewed using the available transaction-level columns
-- instead of deleting them automatically.

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


-- Keep zero-value transactions in the dataset for audit purposes.
-- They are excluded from Business Sales later.

SELECT
    COUNT(*) AS zero_value_transactions,
    SUM(sales_amount_inr) AS zero_value_sales
FROM transaction_clean
WHERE sales_amount_inr = 0;


-- Keep negative transactions for audit purposes.
-- They are not treated as Business Sales.

SELECT
    COUNT(*) AS negative_transactions,
    SUM(sales_amount_inr) AS negative_sales
FROM transaction_clean
WHERE sales_amount_inr < 0;


-- Classify transactions based on their normalized sales value.
-- Positive transactions are treated as Business Sales.

SELECT
    CASE
        WHEN sales_amount_inr > 0 THEN 'Business Sale'
        WHEN sales_amount_inr = 0 THEN 'Zero Value'
        ELSE 'Negative'
    END AS sales_value_type,
    COUNT(*) AS transaction_count,
    SUM(sales_amount_inr) AS sales_amount_inr
FROM transaction_clean
GROUP BY
    CASE
        WHEN sales_amount_inr > 0 THEN 'Business Sale'
        WHEN sales_amount_inr = 0 THEN 'Zero Value'
        ELSE 'Negative'
    END
ORDER BY transaction_count DESC;


-- Keep sales quantity exactly as recorded in the source.
-- Quantity is not filtered based on sales value.

SELECT
    COUNT(*) AS recorded_transactions,
    SUM(sales_qty) AS total_recorded_sales_quantity
FROM transaction_clean;


-- Final check after currency normalization and data preparation.

SELECT
    COUNT(*) AS total_transactions,
    SUM(sales_amount_inr IS NULL) AS missing_normalized_amounts,
    COUNT(DISTINCT TRIM(currency)) AS currency_count,
    MIN(order_date) AS first_transaction_date,
    MAX(order_date) AS last_transaction_date
FROM transaction_clean;
