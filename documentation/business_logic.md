# Business Logic

## 1. Business Sales

A transaction is treated as a Business Sale when `sales_amount_inr > 0`.

Zero-value and negative-value transactions are retained in the data for audit purposes but are excluded from Business Sales.

**Final Business Sales:** ₹984,861,450.75

---

## 2. Business Transactions

Business Transactions count only transactions where `is_business_sale = 1`.

**Total Recorded Transactions:** 150,002  
**Business Transactions:** 148,395

---

## 3. Sales Quantity

Sales Quantity represents the quantity recorded in the source transaction data.

It is not filtered using the Business Sale flag.

**Total Recorded Sales Quantity:** 2,442,057

This keeps the quantity metric faithful to the original transaction records.

---

## 4. Zero-Value Transactions

Transactions where `sales_amount_inr = 0` are classified as Zero Value transactions.

**Zero-Value Transactions:** 1,606

These transactions remain in the dataset for data-quality and audit analysis but are excluded from Business Sales.

---

## 5. Negative Transactions

Transactions where `sales_amount_inr < 0` are classified as Negative transactions.

**Negative Transactions:** 1

The single negative transaction has a value of **-₹1**.

It is retained instead of being removed so that the original recorded data remains traceable.

---

## 6. Currency Normalization

The transaction data contains two currencies:

- INR
- USD

Transaction values were normalized to INR using the available exchange-rate information.

The normalized amount is stored in `sales_amount_inr`.

All 150,002 transactions have a valid INR amount after normalization.

---

## 7. Product Mapping

Transaction data contains 339 distinct product codes, while the official product master contains 279 product codes.

Therefore, 60 product codes appear in transactions but are not present in the product master.

These products are classified as `Unmapped`.

The official product master was not modified to artificially add these products.

Instead, the reporting layer exposes them as Unmapped products.

**Unmapped Product Transactions:** 55,159

---

## 8. Customer Mapping

Customer information is joined using `customer_code`.

The transaction data contains 38 distinct customers and the customer master also contains 38 customers.

No customer mapping gap was identified.

---

## 9. Market Mapping

Market information is joined using `market_code`.

The market master contains 17 markets, while transaction data contains activity across 15 markets.

The remaining master markets have no transaction activity in the analyzed transaction data.

---

## 10. Date Logic

A dedicated Date dimension is used for time-based analysis.

The transaction period covers:

**October 2017 – June 2020**

The Date dimension contains 1,126 dates, while transaction data contains 806 distinct transaction dates.

The Date dimension is used in Power BI for year, month and chronological analysis.

---

## 11. Comparable YoY Logic

The dataset does not contain a complete year for 2020.

Therefore, comparing full-year 2019 sales with 2020 sales would be misleading.

The project compares the same period:

**January 1 – June 26, 2019**  
vs.  
**January 1 – June 26, 2020**

Results:

| Period | Business Sales |
|---|---:|
| Jan 1 – Jun 26, 2019 | ₹164.66M |
| Jan 1 – Jun 26, 2020 | ₹142.22M |

**Comparable YoY Sales Growth: -13.63%**

This provides a fair comparison between equivalent periods.

---

## 12. Product Performance

Products are ranked using Business Sales.

Product concentration analysis showed:

- Top 1 Product: 7.00%
- Top 5 Products: 24.08%
- Top 10 Products: 35.04%

This indicates that Business Sales are distributed across a relatively broad product base rather than being dominated by a single product.

---

## 13. Customer Concentration

Customers are ranked using Business Sales.

Customer concentration analysis showed:

- Top 1 Customer: 41.97%
- Top 5 Customers: 61.02%
- Top 10 Customers: 75.00%

This indicates meaningful customer dependency and concentration risk.

---

## 14. Market Concentration

Markets are ranked using Business Sales.

Market concentration analysis showed:

- Top 1 Market: 52.75%
- Top 5 Markets: 91.29%
- Top 10 Markets: 98.84%

This indicates very high geographic concentration.

Delhi NCR is the largest market, contributing approximately 52.75% of Business Sales.

---

## 15. Customer Channel Analysis

Customers are grouped using `customer_type`.

The main customer types are:

- Brick & Mortar
- E-Commerce

Business Sales contribution:

- Brick & Mortar: approximately 75.6%
- E-Commerce: approximately 24.4%

Business Transactions:

- Brick & Mortar: 97,384
- E-Commerce: 52,618

The dashboard uses these metrics to compare customer-channel contribution.

---

## 16. Zone Analysis

Markets are grouped into geographic zones:

- North
- Central
- South

Business Sales are aggregated by zone to understand geographic performance.

The analysis also showed that North's dominance is strongly influenced by Delhi NCR.

When Delhi NCR is excluded, Central becomes the highest-sales zone.

---

## 17. Power BI KPI Framework

The Executive Overview uses four primary KPIs:

1. Business Sales
2. Business Transactions
3. Business Sales Quantity
4. Comparable YoY Sales Growth

Additional data-quality indicators are:

1. Zero Value Transactions
2. Negative Transactions
3. Unmapped Product Transactions

Average Transaction Value and Transaction Growth were intentionally not selected as primary KPIs.

---

## 18. Data Integrity Principle

The project follows the principle:

**Preserve the source data first, apply business logic separately.**

Therefore:

- Zero-value transactions are retained.
- Negative transactions are retained.
- Unmapped products are not artificially added to the master.
- Original sales quantities are preserved.
- Currency values are normalized to INR.
- Business Sales is derived using an explicit positive-value rule.

This keeps the analytical layer traceable and auditable.

---

## 19. Dashboard Scope

The Power BI dashboard focuses on:

- Sales performance
- Customer contribution
- Product performance
- Market performance
- Zone performance
- Customer channel contribution
- Comparable year-over-year performance
- Data-quality indicators

The dashboard acts as a business-analysis layer built on top of the SQL analytical layer.
