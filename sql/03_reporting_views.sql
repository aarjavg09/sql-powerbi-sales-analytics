USE sales;

-- Main reporting view:
-- Combines transactions with customer, product, market and date details.

CREATE OR REPLACE VIEW vw_transaction_analysis AS
SELECT
    t.product_code,
    t.customer_code,
    t.market_code,
    t.order_date,
    t.sales_qty,
    t.sales_amount,
    t.currency,
    t.exchange_rate_to_inr,
    t.sales_amount_inr,

    c.customer_name,
    c.customer_type,

    p.product_type,

    m.markets_name,
    m.zone,

    d.cy_date,
    d.year,
    d.month_name,
    d.date_yy_mmm,

    CASE
        WHEN t.sales_amount_inr > 0 THEN 'Business Sale'
        WHEN t.sales_amount_inr = 0 THEN 'Zero Value'
        ELSE 'Negative'
    END AS sales_value_type,

    CASE
        WHEN t.sales_amount_inr > 0 THEN 1
        ELSE 0
    END AS is_business_sale,

    CASE
        WHEN t.sales_amount_inr = 0 THEN 1
        ELSE 0
    END AS is_zero_value_transaction,

    CASE
        WHEN t.sales_amount_inr < 0 THEN 1
        ELSE 0
    END AS is_negative_transaction,

    CASE
        WHEN p.product_code IS NULL THEN 'Unmapped'
        ELSE 'Mapped'
    END AS product_status

FROM transaction_clean t

LEFT JOIN customers c
    ON t.customer_code = c.customer_code

LEFT JOIN products p
    ON t.product_code = p.product_code

LEFT JOIN markets m
    ON t.market_code = m.markets_code

LEFT JOIN `date` d
    ON t.order_date = d.date;


-- Product reporting view:
-- Keeps all transaction product codes visible without changing
-- the official product master.

CREATE OR REPLACE VIEW vw_product_reporting AS
SELECT
    t.product_code,
    COALESCE(p.product_type, 'Unmapped') AS product_type,

    CASE
        WHEN p.product_code IS NULL THEN 'Unmapped'
        ELSE 'Mapped'
    END AS mapping_status

FROM (
    SELECT DISTINCT product_code
    FROM transaction_clean
) t

LEFT JOIN products p
    ON t.product_code = p.product_code;


-- Quick checks after creating the views.

SELECT COUNT(*) AS transaction_analysis_rows
FROM vw_transaction_analysis;

SELECT
    COUNT(*) AS reporting_products,
    SUM(mapping_status = 'Mapped') AS mapped_products,
    SUM(mapping_status = 'Unmapped') AS unmapped_products
FROM vw_product_reporting;
