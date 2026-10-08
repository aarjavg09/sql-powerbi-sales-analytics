USE sales;

-- Business KPI summary
SELECT
    COUNT(*) AS recorded_transactions,

    SUM(sales_amount_inr) AS recorded_sales_inr,

    SUM(
        CASE
            WHEN sales_amount_inr > 0
            THEN sales_amount_inr
            ELSE 0
        END
    ) AS business_sales_inr,

    SUM(sales_qty) AS total_sales_qty,

    SUM(
        CASE
            WHEN sales_amount_inr > 0
            THEN 1
            ELSE 0
        END
    ) AS business_transactions,

    SUM(
        CASE
            WHEN sales_amount_inr = 0
            THEN 1
            ELSE 0
        END
    ) AS zero_value_transactions,

    SUM(
        CASE
            WHEN sales_amount_inr < 0
            THEN 1
            ELSE 0
        END
    ) AS negative_transactions,

    SUM(
        CASE
            WHEN product_status = 'Unmapped'
            THEN 1
            ELSE 0
        END
    ) AS unmapped_product_transactions

FROM vw_transaction_analysis;


-- Annual Business Sales
SELECT
    year,
    SUM(
        CASE
            WHEN is_business_sale = 1
            THEN sales_amount_inr
            ELSE 0
        END
    ) AS business_sales
FROM vw_transaction_analysis
GROUP BY year
ORDER BY year;


-- Comparable Jan-Jun sales for 2019 and 2020
SELECT
    year,
    SUM(sales_amount_inr) AS business_sales
FROM vw_transaction_analysis
WHERE is_business_sale = 1
  AND order_date BETWEEN
      CASE
          WHEN year = 2019 THEN '2019-01-01'
          WHEN year = 2020 THEN '2020-01-01'
      END
      AND
      CASE
          WHEN year = 2019 THEN '2019-06-26'
          WHEN year = 2020 THEN '2020-06-26'
      END
GROUP BY year
ORDER BY year;


-- Monthly Business Sales
SELECT
    month_name,
    SUM(
        CASE
            WHEN is_business_sale = 1
            THEN sales_amount_inr
            ELSE 0
        END
    ) AS business_sales
FROM vw_transaction_analysis
GROUP BY month_name
ORDER BY
    MIN(MONTH(order_date));


-- Product performance
SELECT
    product_code,
    MAX(product_type) AS product_type,
    SUM(
        CASE
            WHEN is_business_sale = 1
            THEN sales_amount_inr
            ELSE 0
        END
    ) AS business_sales
FROM vw_transaction_analysis
GROUP BY product_code
ORDER BY business_sales DESC;


-- Customer performance
SELECT
    customer_code,
    MAX(customer_name) AS customer_name,
    MAX(customer_type) AS customer_type,
    SUM(
        CASE
            WHEN is_business_sale = 1
            THEN sales_amount_inr
            ELSE 0
        END
    ) AS business_sales
FROM vw_transaction_analysis
GROUP BY customer_code
ORDER BY business_sales DESC;


-- Market performance
SELECT
    market_code,
    MAX(markets_name) AS market_name,
    MAX(zone) AS zone,
    SUM(
        CASE
            WHEN is_business_sale = 1
            THEN sales_amount_inr
            ELSE 0
        END
    ) AS business_sales
FROM vw_transaction_analysis
GROUP BY market_code
ORDER BY business_sales DESC;


-- Zone performance
SELECT
    zone,
    COUNT(*) AS recorded_transactions,
    SUM(sales_qty) AS sales_quantity,
    SUM(
        CASE
            WHEN is_business_sale = 1
            THEN sales_amount_inr
            ELSE 0
        END
    ) AS business_sales
FROM vw_transaction_analysis
GROUP BY zone
ORDER BY business_sales DESC;


-- Customer type performance
SELECT
    customer_type,
    COUNT(DISTINCT customer_code) AS customers,
    SUM(
        CASE
            WHEN is_business_sale = 1
            THEN 1
            ELSE 0
        END
    ) AS business_transactions,
    SUM(sales_qty) AS sales_quantity,
    SUM(
        CASE
            WHEN is_business_sale = 1
            THEN sales_amount_inr
            ELSE 0
        END
    ) AS business_sales
FROM vw_transaction_analysis
GROUP BY customer_type
ORDER BY business_sales DESC;
