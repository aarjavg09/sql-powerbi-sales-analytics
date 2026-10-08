# Data Dictionary

## Fact / Transaction Data

### vw_transaction_analysis

| Column | Description |
|---|---|
| product_code | Product identifier from the transaction data |
| customer_code | Customer identifier |
| market_code | Market identifier |
| order_date | Transaction/order date |
| sales_qty | Recorded sales quantity |
| sales_amount | Original transaction amount |
| currency | Original transaction currency |
| exchange_rate_to_inr | Exchange rate used for INR conversion |
| sales_amount_inr | Transaction amount normalized to INR |
| customer_name | Customer name from customer master |
| customer_type | Customer channel/type |
| product_type | Product category/type |
| markets_name | Market name |
| zone | Geographic zone |
| cy_date | Calendar date from date dimension |
| year | Transaction year |
| month_name | Transaction month |
| date_yy_mmm | Year-month display field |
| sales_value_type | Business Sale, Zero Value, or Negative |
| is_business_sale | 1 when INR sales amount is positive |
| is_zero_value_transaction | 1 when INR sales amount is zero |
| is_negative_transaction | 1 when INR sales amount is negative |
| product_status | Mapped or Unmapped product |

## Dimension Tables

### customers

| Column | Description |
|---|---|
| customer_code | Unique customer identifier |
| customer_name | Customer name |
| customer_type | Customer channel/type |

### markets

| Column | Description |
|---|---|
| markets_code | Unique market identifier |
| markets_name | Market name |
| zone | Geographic zone |

### products

| Column | Description |
|---|---|
| product_code | Product identifier |
| product_type | Product category/type |

### date

| Column | Description |
|---|---|
| date | Calendar date |
| cy_date | Calendar date reference |
| year | Calendar year |
| month_name | Month name |
| date_yy_mmm | Year-month display label |

## Reporting View

### vw_product_reporting

This view exposes all product codes found in transaction data while preserving the official product master.

| Column | Description |
|---|---|
| product_code | Product code appearing in transactions |
| product_type | Product type or `Unmapped` when no master mapping exists |
| mapping_status | `Mapped` or `Unmapped` |

## Data Scope

- Transaction rows: 150,002
- Transaction product codes: 339
- Product master codes: 279
- Unmapped transaction product codes: 60
- Customers: 38
- Markets in master: 17
- Active transaction markets: 15
- Transaction date coverage: Oct 2017 – Jun 2020
