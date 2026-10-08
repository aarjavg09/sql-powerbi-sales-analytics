USE sales;

-- Basic transaction count
SELECT
    COUNT(*) AS total_transactions
FROM transaction_clean;


-- Check for missing values in the transaction data
SELECT
    SUM(product_code IS NULL) AS missing_product_codes,
    SUM(customer_code IS NULL) AS missing_customer_codes,
    SUM(market_code IS NULL) AS missing_market_codes,
    SUM(order_date IS NULL) AS missing_order_dates,
    SUM(sales_qty IS NULL) AS missing_sales_qty,
    SUM(sales_amount IS NULL) AS missing_sales_amount,
    SUM(currency IS NULL) AS missing_currency,
    SUM(exchange_rate_to_inr IS NULL) AS missing_exchange_rate,
    SUM(sales_amount_inr IS NULL) AS missing_sales_amount_inr
FROM transaction_clean;


-- Check for duplicate transaction records
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


-- Check which currencies are present
SELECT
    currency,
    COUNT(*) AS transaction_count
FROM transaction_clean
GROUP BY currency
ORDER BY transaction_count DESC;


-- Confirm that all transaction amounts have been normalized to INR
SELECT
    COUNT(*) AS total_transactions,
    SUM(sales_amount_inr IS NULL) AS missing_inr_amounts,
    COUNT(DISTINCT currency) AS currencies
FROM transaction_clean;


-- Identify zero-value transactions
SELECT
    COUNT(*) AS zero_value_transactions
FROM transaction_clean
WHERE sales_amount_inr = 0;


-- Check for negative transactions
SELECT
    COUNT(*) AS negative_transactions,
    SUM(sales_amount_inr) AS negative_sales_amount
FROM transaction_clean
WHERE sales_amount_inr < 0;


-- Check whether transaction products exist in the product master
SELECT
    COUNT(DISTINCT t.product_code) AS transaction_product_codes,
    COUNT(DISTINCT p.product_code) AS mapped_product_codes,
    COUNT(DISTINCT t.product_code)
        - COUNT(DISTINCT p.product_code) AS unmapped_product_codes
FROM transaction_clean t
LEFT JOIN products p
    ON t.product_code = p.product_code;


-- Measure the transaction and sales impact of unmapped products
SELECT
    COUNT(*) AS unmapped_product_transactions,
    SUM(t.sales_amount_inr) AS unmapped_sales_amount
FROM transaction_clean t
LEFT JOIN products p
    ON t.product_code = p.product_code
WHERE p.product_code IS NULL;


-- Check customer master coverage
SELECT
    COUNT(DISTINCT t.customer_code) AS transaction_customers,
    COUNT(DISTINCT c.customer_code) AS mapped_customers
FROM transaction_clean t
LEFT JOIN customers c
    ON t.customer_code = c.customer_code;


-- Check market master coverage
SELECT
    COUNT(DISTINCT t.market_code) AS transaction_markets,
    COUNT(DISTINCT m.markets_code) AS mapped_markets
FROM transaction_clean t
LEFT JOIN markets m
    ON t.market_code = m.markets_code;


-- Check the date range covered by the transactions
SELECT
    MIN(order_date) AS first_transaction_date,
    MAX(order_date) AS last_transaction_date,
    COUNT(DISTINCT order_date) AS distinct_transaction_dates
FROM transaction_clean;


-- Final financial integrity check
SELECT
    COUNT(*) AS recorded_transactions,
    SUM(sales_amount_inr) AS recorded_sales_inr,
    SUM(
        CASE
            WHEN sales_amount_inr > 0 THEN sales_amount_inr
            ELSE 0
        END
    ) AS business_sales_inr,
    SUM(sales_amount_inr = 0) AS zero_value_transactions,
    SUM(sales_amount_inr < 0) AS negative_transactions
FROM transaction_clean;
