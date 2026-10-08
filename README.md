# SQL + Power BI Sales Analytics

## 📌 Project Overview

This project is an end-to-end sales analytics solution built using MySQL and Power BI.
The project focuses on transforming raw transaction data into a validated analytical layer, identifying data-quality issues, defining business-ready KPIs, and delivering an interactive Power BI dashboard for sales performance analysis.

The workflow covers data-quality auditing, currency normalization, transaction analysis, product mapping validation, SQL-based reporting views, dimensional data modeling, DAX measures, dashboard development, and business insight generation.

## 🎯 Business Problem

 The business needs a reliable view of sales performance across products, customers, markets, zones, and customer types.

However, the underlying transaction data contains data-quality and reporting challenges, including zero-value transactions, a negative transaction, multiple currencies, and transaction product codes that are not present in the product master.

The objective is therefore not only to create a dashboard, but to first validate and prepare the data, preserve source-data integrity, define transparent business rules, and then produce decision-ready sales analysis.

## 🎯 Project Objectives

- Build a reliable SQL-based analytical layer for transaction reporting.
- Audit and quantify data-quality issues before reporting.
- Normalize transaction values into INR.
- Preserve zero-value and negative transactions for auditability.
- Identify and quantify unmapped transaction products.
- Build a dimensional Power BI data model.
- Create validated DAX measures for business KPIs.
- Analyze sales performance across products, customers, markets, zones, and customer types.
- Identify sales concentration and dependency risks.
- Deliver an interactive executive Power BI dashboard.
- Translate analytical findings into actionable business recommendations.


## 📊 Dataset & Scope

### Transaction Coverage

- Total transactions: **150,002**
- Date coverage: **October 2017 – June 2020**
- Transaction dates: **806 distinct dates**
- Customers: **38**
- Active transaction markets: **15**
- Transaction product codes: **339**

### Product Master Coverage

- Product master records: **279**
- Transaction product codes: **339**
- Unmapped transaction product codes: **60**

### Currency

Transaction values were normalized to INR using the available exchange-rate information.

- Missing normalized INR amounts after processing: **0**
- Currencies identified: **2**

## 🔍 Data Quality & Audit

A structured data-quality audit was performed before dashboard development.

### Transaction Value Audit

| Check | Result |
|---|---:|
| Total transactions | 150,002 |
| Zero-value transactions | 1,606 |
| Negative transactions | 1 |
| Missing normalized INR amounts | 0 |

Zero-value and negative transactions were **retained in the source/analytical data for auditability** rather than deleted.

### Product Mapping Audit

The transaction data contained **339 distinct product codes**, while the product master contained **279 product codes**.

This resulted in:

- **60 unmapped transaction product codes**
- **55,159 affected transactions**

Instead of modifying the official product master to hide the mismatch, a separate reporting view was created to classify products as **Mapped** or **Unmapped**.

## 🧹 Data Cleaning & Transformation

The transaction data was prepared through a structured validation and transformation process before being used for business reporting.

### 1. Currency Normalization

Transaction amounts were normalized into INR using the available exchange-rate information.

The normalized amount was stored as `sales_amount_inr` and validated to ensure that no transaction remained without a normalized INR value.

### 2. Transaction Value Handling

Transaction records were not deleted solely because their sales value was zero or negative.

The following business rule was established:

- Positive-value transactions → included in Business Sales.
- Zero-value transactions → retained for audit, excluded from Business Sales.
- Negative-value transactions → retained for audit, excluded from Business Sales.

This preserves the underlying transaction history while preventing non-positive values from inflating or distorting Business Sales.

### 3. Sales Quantity Handling

Sales quantity was retained as recorded in the transaction data.

The `Business Sales Quantity` measure therefore represents **all recorded transaction quantities**, including quantities associated with zero-value and negative-value transactions.

This is intentionally different from the Business Sales calculation.

### 4. Product Mapping Validation

Transaction product codes were compared against the product master.

Products available in the transaction data but missing from the product master were classified as `Unmapped`.

The official product master was not modified to artificially resolve these records.

Instead, a separate reporting view, `vw_product_reporting`, was created to provide:

- Product code
- Product type
- Mapping status (`Mapped` / `Unmapped`)

### 5. Analytical Transaction View

A consolidated analytical view, `vw_transaction_analysis`, was created by combining transaction data with customer, product, market, and date information.

The view also contains reporting flags used for business analysis, including:

- Sales value type
- Business sale indicator
- Zero-value transaction indicator
- Negative transaction indicator
- Product mapping status

## 🗄️ SQL Analytical Layer

MySQL was used as the primary analytical layer before the data was consumed by Power BI.

The SQL layer was designed to separate data preparation and business analysis from dashboard presentation.

### Reporting Views

#### `vw_transaction_analysis`

A consolidated transaction-level analytical view created by joining:

- Transaction data
- Customer master
- Product master
- Market master
- Date dimension

The view preserves the transaction-level grain and contains business-analysis fields such as:

- Customer information
- Product information
- Market and zone
- Date attributes
- INR-normalized sales amount
- Sales value classification
- Business sale flag
- Zero-value transaction flag
- Negative transaction flag
- Product mapping status

The resulting view contains **150,002 transaction records**, preserving the original transaction-level row count.

#### `vw_product_reporting`

A reporting view created to handle product-master mapping differences without modifying the official product master.

It exposes all **339 product codes** present in the transaction data and classifies them as:

- `Mapped`
- `Unmapped`

This approach preserves master-data integrity while allowing Power BI to report on all transaction products.

### SQL Business Analysis

SQL was also used to validate and analyze:

- Executive sales KPIs
- Annual sales performance
- Comparable year-over-year sales growth
- Monthly sales trends
- Product performance and concentration
- Customer performance and concentration
- Market performance and concentration
- Zone performance
- Customer-type contribution
- Transaction and data-quality indicators


## 📐 Power BI Data Model

Power BI was connected to the MySQL analytical layer to create a structured reporting model.

### Main Fact / Analytical Table

`vw_transaction_analysis`

This table contains the transaction-level analytical data used for the majority of reporting calculations.

### Dimension Tables

The model uses the following supporting dimensions:

- `customers`
- `vw_product_reporting`
- `markets`
- `date`

### Relationships

The model uses one-to-many relationships from the dimension tables to the transaction-level analytical table:

- Customers → Transactions
- Products → Transactions
- Markets → Transactions
- Date → Transactions

Relationships use single-direction filtering from dimensions to the analytical transaction table.

### Date Model

The `date` table was configured as the Power BI Date Table.

Additional date attributes were used for:

- Year
- Month
- Month Number
- Year-Month reporting
- Chronological sorting

This structure allows consistent time-based analysis and comparable year-over-year calculations.
## 📊 DAX & KPI Framework

DAX measures were created in Power BI to implement the project's business rules and reporting KPIs.

### Core KPIs

- Business Sales
- Business Transactions
- Business Sales Quantity
- Comparable YoY Sales Growth
- Zero Value Transactions
- Negative Transactions
- Unmapped Product Transactions

### Business Sales Logic

Business Sales includes only transactions where:

`sales_amount_inr > 0`

### Business Transactions Logic

Business Transactions counts transaction records classified as business sales.

### Business Sales Quantity Logic

Business Sales Quantity represents the total recorded sales quantity without filtering out zero-value or negative-value transactions.

### Comparable YoY Logic

Because the available 2020 data ends on June 26, a full-year comparison would be misleading.

Therefore, comparable year-over-year performance was evaluated using:

- January 1 – June 26, 2019
- January 1 – June 26, 2020

The resulting comparable YoY sales growth is **-13.63%**.

### Data Quality Measures

Separate measures were created to monitor:

- Zero-value transactions: **1,606**
- Negative transactions: **1**
- Unmapped product transactions: **55,159**

## 📈 Dashboard

The Power BI report contains three analytical pages designed around different business questions.

### Page 1 — Executive Overview

The Executive Overview provides a high-level view of:

- Business Sales
- Business Transactions
- Recorded Sales Quantity
- Comparable YoY Sales Growth
- Monthly Business Sales Trend
- Business Sales by Market
- Data Quality & Integrity indicators

The page also documents the business logic used for sales and quantity calculations.

### Page 2 — Sales & Customer Analysis

This page focuses on major sales drivers:

- Top 10 Products by Business Sales
- Top 10 Customers by Business Sales
- Business Sales by Market
- Business Sales by Zone

The page is designed to identify major product, customer, market and geographic sales contributors.

### Page 3 — Customer & Channel Analysis

This page evaluates customer-type contribution using:

- Business Sales by Customer Type
- Business Transactions by Customer Type
- Business Sales Quantity by Customer Type

Interactive filters include:

- Customer Type
- Year

The page also presents key business insights and their full-period baseline.

### Report Navigation

A page navigator is provided to move between the three dashboard pages.


## 💡 Key Business Insights

The analysis identified several important patterns in the transaction data.

### 1. Overall Sales Performance

Total Business Sales are approximately **₹984.86M** across the available transaction period.

### 2. Comparable YoY Decline

Comparable sales for January 1 – June 26 declined by **13.63%** from 2019 to 2020.

This comparison uses equal date ranges rather than comparing a complete year with a partial year.

### 3. Market Concentration

Delhi NCR contributes approximately **52.75%** of Business Sales.

This indicates a significant geographic concentration and dependency on a single market.

### 4. Customer Concentration

The top 5 customers contribute approximately **61.02%** of Business Sales.

The top 10 customers contribute approximately **75.00%**.

This indicates meaningful customer concentration and dependency risk.

### 5. Customer-Type Contribution

Brick & Mortar customers contribute approximately **75.6%** of Business Sales, while E-Commerce contributes approximately **24.4%**.

The two customer types have an equal number of customers in the master data, but their sales contribution is significantly different.

### 6. Product Concentration

The top 10 products contribute approximately **35.04%** of Business Sales, while the top 5 contribute approximately **24.08%**.

Compared with customer and market concentration, product sales are relatively more distributed.

### 7. Data Quality Exposure

The analysis identified:

- **1,606 zero-value transactions**
- **1 negative transaction**
- **55,159 transactions involving unmapped product codes**

These records were retained and quantified rather than silently removed.


## 🎯 Business Recommendations

Based on the analytical findings, the following business actions could be considered.

### 1. Reduce Geographic Dependency

Delhi NCR contributes approximately 52.75% of Business Sales.

The business should evaluate opportunities to strengthen sales in other markets to reduce dependency on a single geographic market.

### 2. Strengthen Key Customer Retention

The top 5 customers contribute approximately 61.02% of Business Sales.

These customers should receive focused retention and account-management strategies while the business simultaneously develops a broader customer base.

### 3. Evaluate Channel Expansion

Brick & Mortar contributes approximately 75.6% of Business Sales compared with approximately 24.4% from E-Commerce.

The business could investigate opportunities to expand the E-Commerce channel where commercially viable.

### 4. Improve Product Master Governance

The presence of 60 transaction product codes missing from the product master affects 55,159 transactions.

A controlled product-mapping and master-data governance process should be established to reduce reporting ambiguity.

### 5. Investigate Comparable Sales Decline

The comparable January–June sales decline of 13.63% requires further investigation.

Potential drivers should be evaluated across:

- Markets
- Customers
- Products
- Customer types
- Monthly trends

The dashboard identifies the decline but does not establish its causal drivers.

## ⚠️ Limitations

- The dataset covers October 2017 through June 2020, with 2020 data available only through June 26.
- Therefore, full-year 2020 performance cannot be compared directly with full-year historical performance.
- Comparable YoY analysis was used to address the partial-year issue.
- The analysis is descriptive and diagnostic; it does not establish causal relationships.
- No customer profitability, cost, margin, or operational expense data was available.
- No transaction ID was available in the source data, so transaction-level uniqueness could not be evaluated using a dedicated transaction identifier.
- Unmapped products were classified for reporting purposes but were not artificially added to the official product master.
- Business recommendations are analytical recommendations and were not measured as implemented business outcomes.

## 🚀 Future Improvements

Potential extensions to the project include:

- Automated data-refresh and ETL workflows.
- Improved product-master governance and automated product mapping.
- Additional profitability and margin analysis if cost data becomes available.
- Customer retention and cohort analysis.
- More detailed product-category analysis.
- Market-level trend and growth analysis.
- Automated data-quality monitoring.
- Deployment of the reporting solution through an enterprise BI environment.

## 🛠️ Tools & Technologies

### Database & SQL
- MySQL
- SQL
- SQL Views
- Joins
- Aggregations
- Conditional logic
- Data-quality analysis

### Business Intelligence
- Microsoft Power BI
- Power Query
- DAX
- Data modeling
- Interactive slicers
- Report navigation

### Documentation & Portfolio
- GitHub
- Markdown

## 📁 Project Structure
sql-powerbi-sales-analytics/
│
├── README.md
│
├── sql/
│   ├── 01_data_quality_audit.sql
│   ├── 02_data_cleaning.sql
│   ├── 03_reporting_views.sql
│   └── 04_business_analysis.sql
│
├── powerbi/
│   └── sales_analytics_dashboard.pbix
│
├── screenshots/
│   ├── executive_overview.png
│   ├── sales_customer_analysis.png
│   ├── customer_channel_analysis.png
│   └── data_model.png
│
├── documentation/
│   ├── data_dictionary.md
│   ├── business_logic.md
│   └── architecture.md
│
└── assets/
    └── architecture.png

## 👨‍💻 Author


### Important

Abhi agar ye files/folders GitHub mein physically nahi hain, **README mein structure likhna okay hai**, but eventually humein actual repository structure bhi isi ke according banana hai.

---

# STEP 18 — Author

**Aarjav Jain**

Aspiring Data Analyst

Skills demonstrated in this project:

- SQL
- MySQL
- Power BI
- DAX
- Data Quality Analysis
- Data Modeling
- Business Analytics


