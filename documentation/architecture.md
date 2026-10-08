# Project Architecture

## 1. Architecture Overview

This project follows a SQL-first analytics architecture.

Raw transaction and master data are first validated and prepared in MySQL. A SQL analytical view then combines the required business dimensions and transaction-level data.

Power BI connects to the analytical layer and is used for KPI calculation, business analysis and dashboard reporting.

The overall flow is:

Source Data
→ Data Quality & Cleaning
→ SQL Analytical Layer
→ Power BI Data Model
→ DAX Measures
→ Interactive Dashboard

---

## 2. Source Data Layer

The project uses the following source tables:

- `transactions`
- `transaction_clean`
- `customers`
- `products`
- `markets`
- `date`

The transaction data contains the sales activity, while the remaining tables provide customer, product, market and date information.

---

## 3. Data Quality & Cleaning Layer

Before dashboard development, the transaction data was audited for:

- Missing values
- Duplicate records
- Currency consistency
- Invalid or negative values
- Zero-value transactions
- Product mapping gaps
- Customer mapping
- Market mapping
- Date coverage

Currency values were normalized to INR using the available exchange-rate information.

The cleaned transaction data is stored in:

`transaction_clean`

The original master tables were preserved rather than being modified to hide data-quality issues.

---

## 4. SQL Analytical Layer

The main analytical view is:

`vw_transaction_analysis`

This view combines:

- Transaction data
- Customer information
- Product information
- Market information
- Date information
- Business classification flags

It also provides calculated fields such as:

- `sales_value_type`
- `is_business_sale`
- `is_zero_value_transaction`
- `is_negative_transaction`
- `product_status`

This creates a consistent analytical layer for Power BI.

---

## 5. Product Reporting Layer

A separate reporting view is used:

`vw_product_reporting`

This view exposes all product codes appearing in transaction data.

Products that exist in the transaction data but are missing from the official product master are classified as:

`Unmapped`

The official product master is not modified to artificially create mappings.

---

## 6. Power BI Data Model

Power BI uses the following tables/views:

- `sales_vw_transaction_analysis`
- `sales_customers`
- `sales_vw_product_reporting`
- `sales_markets`
- `sales_date`

The transaction analysis view acts as the central fact/analytical table.

The remaining tables act as dimensions.

---

## 7. Relationships

The model follows one-to-many relationships:

- `sales_customers[customer_code]` → `sales_vw_transaction_analysis[customer_code]`
- `sales_vw_product_reporting[product_code]` → `sales_vw_transaction_analysis[product_code]`
- `sales_markets[markets_code]` → `sales_vw_transaction_analysis[market_code]`
- `sales_date[date]` → `sales_vw_transaction_analysis[order_date]`

All relationships use single-direction filtering from dimension tables to the transaction analysis table.

No many-to-many relationships are used.

---

## 8. Date Model

`sales_date` is configured as the Date table in Power BI.

It provides:

- Year
- Month
- Year-Month
- Chronological sorting
- Time-based filtering
- Comparable year-over-year analysis

The `date_yy_mmm` field is sorted using a numeric Year-Month sort column.

---

## 9. DAX Layer

The main business measures are created in Power BI using DAX.

Primary KPIs:

- Business Sales
- Business Transactions
- Business Sales Quantity
- Comparable YoY Sales Growth

Data-quality measures:

- Zero Value Transactions
- Negative Transactions
- Unmapped Product Transactions

The DAX layer applies the documented business rules rather than changing the underlying source data.

---

## 10. Business Logic Flow

The main sales logic is:

`sales_amount_inr > 0`
→ Business Sale
→ Included in Business Sales
→ Included in Business Transactions

For zero-value transactions:

`sales_amount_inr = 0`
→ Zero Value Transaction
→ Excluded from Business Sales
→ Retained for audit

For negative transactions:

`sales_amount_inr < 0`
→ Negative Transaction
→ Excluded from Business Sales
→ Retained for audit

Sales quantity remains based on the recorded source quantity and is not filtered by the Business Sale flag.

---

## 11. Dashboard Layer

The Power BI dashboard contains three analytical pages.

### Page 1 — Sales Performance Executive Overview

Focus:

- Business Sales
- Business Transactions
- Business Sales Quantity
- Comparable YoY Sales Growth
- Monthly sales trend
- Market performance
- Data quality indicators

### Page 2 — Sales & Customer Analysis

Focus:

- Product performance
- Customer performance
- Market performance
- Zone performance

### Page 3 — Customer & Channel Analysis

Focus:

- Customer type contribution
- Business Sales
- Business Transactions
- Recorded Sales Quantity
- Customer concentration insights

---

## 12. Architecture Design Principles

### Source Preservation

Original source and master data are not modified unnecessarily.

### Separation of Concerns

Data preparation and business analysis are handled in SQL, while visualization and interactive reporting are handled in Power BI.

### Traceability

Major dashboard KPIs can be traced back to the SQL analytical layer.

### Auditability

Zero-value, negative and unmapped-product records are retained and reported rather than silently removed.

### Controlled Business Logic

Business definitions are explicitly documented instead of relying on visual-level assumptions.

---

## 13. Technology Stack

### Database

MySQL

### Data Analysis & Transformation

SQL

### Business Intelligence

Microsoft Power BI

### Data Visualization

Power BI

### Version Control & Portfolio

GitHub

---

## 14. End-to-End Architecture

```text
SOURCE DATA
     |
     v
+---------------------------+
|      MySQL Tables         |
|---------------------------|
| transactions              |
| transaction_clean         |
| customers                 |
| products                  |
| markets                   |
| date                      |
+-------------+-------------+
              |
              v
+---------------------------+
| Data Quality & Cleaning   |
|---------------------------|
| Missing values            |
| Duplicate checks          |
| Currency normalization    |
| Zero / negative values    |
| Product mapping           |
| Customer / market checks  |
+-------------+-------------+
              |
              v
+---------------------------+
|    SQL Analytical Layer   |
|---------------------------|
| vw_transaction_analysis   |
| vw_product_reporting      |
+-------------+-------------+
              |
              v
+---------------------------+
|      Power BI Model       |
|---------------------------|
| Transaction Analysis      |
| Customer Dimension        |
| Product Dimension         |
| Market Dimension          |
| Date Dimension            |
+-------------+-------------+
              |
              v
+---------------------------+
|        DAX Layer          |
|---------------------------|
| Business Sales            |
| Business Transactions     |
| Sales Quantity            |
| YoY Sales Growth          |
| Data Quality KPIs         |
+-------------+-------------+
              |
              v
+---------------------------+
|     Power BI Dashboard    |
|---------------------------|
| Executive Overview        |
| Sales & Customer Analysis |
| Customer & Channel        |
+---------------------------+

---

## 15. Final Architecture Summary

The project is designed as a traceable SQL-to-Power-BI analytics pipeline.

MySQL is responsible for data preparation, validation and analytical views.

Power BI is responsible for semantic modeling, DAX calculations, visualization and interactive business reporting.

This architecture keeps data quality, business logic and presentation layers separated while maintaining a clear path from source transactions to final dashboard insights.
