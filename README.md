# Online Retail Data Analyst Project

## Project Overview

This project analyzes the UCI Online Retail dataset using SQL to explore
transaction data, revenue patterns, products, customers, countries,
returns, and data quality.

The goal is to demonstrate practical data analyst skills: data
validation, duplicate analysis, SQL aggregation, business-focused
analysis, and communicating findings clearly.

## Dataset

-   **Source:** UCI Machine Learning Repository --- Online Retail
    dataset
-   **Raw records:** 541,909
-   **Columns:** 8
-   **Fields:** `InvoiceNo`, `StockCode`, `Description`, `Quantity`,
    `InvoiceDate`, `UnitPrice`, `CustomerID`, `Country`

The dataset contains retail transactions and includes
cancellations/returns, missing customer IDs, blank descriptions, and
unusual price values. These cases were investigated as data-quality and
business-analysis topics rather than automatically deleting every
unusual record.

## Tools

-   MySQL / MySQL Workbench
-   SQL
-   GitHub (for project versioning and portfolio presentation)

Excel and Power BI dashboards are planned as the next project phases and
should be added after they are completed.

## Data Preparation

Two tables were used:

-   `online_retail_raw` --- source data imported into MySQL.
-   `online_retail_clean` --- distinct rows created from the raw table
    for analysis.

  Check                                                 Result
  -------------------------------------------------- ---------
  Raw records                                          541,909
  Clean records                                        536,641
  Extra duplicate rows removed from clean table          5,268
  Invalid dates found by the date validation query           0

The raw table is retained so that the cleaning impact can be compared
with the clean table.

## Analysis Performed

The SQL work covers:

-   Record counts and raw-versus-clean comparisons
-   Duplicate detection and duplicate-row removal
-   Missing and blank values
-   Negative and zero quantities
-   Negative and zero unit prices
-   Invoice date validation and date range
-   Revenue calculations
-   Monthly sales trends
-   Country-level sales analysis
-   Top products by revenue
-   Top customers by revenue
-   Order-level revenue and average order value
-   Daily and weekday sales analysis
-   Returns and cancellation analysis
-   Data-quality comparisons between raw and clean tables

## Data Quality Notes

The clean table is a deduplicated analysis table; it is not a claim that
every field is complete or every transaction is a standard sale.
Important observations include:

-   Some product descriptions are blank.
-   Many transactions have no customer ID.
-   Negative quantities can represent returns or cancellations.
-   Zero and negative unit prices require business interpretation.
-   Raw data is preserved for comparison and auditability.

These records should be interpreted in context rather than removed
without justification.

## Repository Contents

-   `Online_Retail_DA_Project_Master_Audit(2).sql` --- current SQL
    master/audit script.
-   `README.md` --- project overview and documentation.
-   `Screenshots/` --- optional evidence images, if available.

> **Important:** The SQL script includes database setup commands,
> including `DROP DATABASE IF EXISTS online_retail`, table creation, and
> data loading. Do not run the entire script against a database you need
> to preserve. Execute individual analysis queries as appropriate.

## Project Status

-   **SQL analysis:** Core analysis completed.
-   **GitHub documentation:** README prepared; repository upload remains
    to be done.
-   **Excel dashboard:** Planned.
-   **Power BI dashboard:** Planned.

## Next Steps

1.  Upload the SQL script and this README to a GitHub repository.
2.  Build an Excel dashboard using the same dataset.
3.  Build an interactive Power BI dashboard with sales, product,
    customer, and country insights.
4.  Add dashboard screenshots and documented findings after those
    deliverables are complete.

## Data Source

UCI Machine Learning Repository, **Online Retail** dataset.
