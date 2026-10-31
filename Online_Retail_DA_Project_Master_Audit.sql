## 1. DATABASE SETUP 

DROP DATABASE IF EXISTS online_retail;

CREATE DATABASE online_retail;

USE online_retail;

## 2. CREATE RAW DATA TABLE

CREATE TABLE online_retail_raw (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description VARCHAR(255),
    Quantity INT,
    InvoiceDate VARCHAR(30),
    UnitPrice DECIMAL(12,4),
    CustomerID VARCHAR(20),
    Country VARCHAR(100)
);

## 3. IMPORT DATA FROM CSV

LOAD DATA LOCAL INFILE
'C:/Users/Prabhat Kumar/Desktop/Online_Retail_Data_Analyst_Project/Online_Retail_Clean_8_Columns.csv'
INTO TABLE online_retail_raw
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country
);

## 4. RAW DATA VALIDATION AND PREVIEW

SELECT COUNT(*) AS total_records
FROM online_retail_raw;

SELECT *
FROM online_retail_raw
LIMIT 10;

## 5. CHECK MISSING NULL VALUES

SELECT
    COUNT(*) AS total_records,
    SUM(InvoiceNo IS NULL) AS missing_invoice,
    SUM(StockCode IS NULL) AS missing_stockcode,
    SUM(Description IS NULL) AS missing_description,
    SUM(Quantity IS NULL) AS missing_quantity,
    SUM(InvoiceDate IS NULL) AS missing_date,
    SUM(UnitPrice IS NULL) AS missing_price,
    SUM(CustomerID IS NULL) AS missing_customer,
    SUM(Country IS NULL) AS missing_country
FROM online_retail_raw;

## 6. CHECK NEGATIVE AND ZERO VALUES

SELECT
    SUM(Quantity < 0) AS negative_quantity,
    SUM(Quantity = 0) AS zero_quantity,
    SUM(UnitPrice < 0) AS negative_price,
    SUM(UnitPrice = 0) AS zero_price
FROM online_retail_raw;

## 7. CHECK BLANK VALUES

SELECT
    SUM(TRIM(InvoiceNo) = '') AS blank_invoice,
    SUM(TRIM(StockCode) = '') AS blank_stockcode,
    SUM(TRIM(Description) = '') AS blank_description,
    SUM(TRIM(InvoiceDate) = '') AS blank_date,
    SUM(TRIM(CustomerID) = '') AS blank_customer,
    SUM(TRIM(Country) = '') AS blank_country
FROM online_retail_raw;

## 8. NEGATIVE QUANTITY ANALYSIS

SELECT
    COUNT(*) AS total_negative_quantity,
    SUM(InvoiceNo LIKE 'C%') AS cancellation_invoices,
    SUM(InvoiceNo NOT LIKE 'C%') AS other_negative_quantity
FROM online_retail_raw
WHERE Quantity < 0;

## 9. DUPLICATE RECORDS ANALYSIS

SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country,
    COUNT(*) AS duplicate_count
FROM online_retail_raw
GROUP BY
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

## 10. DUPLICATE SUMMARY AND PERCENTAGE

SELECT
    (SELECT COUNT(*)
     FROM online_retail_raw) AS total_raw_records,

    COUNT(*) AS repeated_combinations,

    SUM(duplicate_count - 1) AS extra_repeated_rows,

    ROUND(
        SUM(duplicate_count - 1) * 100.0 /
        (SELECT COUNT(*) FROM online_retail_raw),
        2
    ) AS extra_rows_percentage

FROM (
    SELECT COUNT(*) AS duplicate_count
    FROM online_retail_raw
    GROUP BY
        InvoiceNo,
        StockCode,
        Description,
        Quantity,
        InvoiceDate,
        UnitPrice,
        CustomerID,
        Country
    HAVING COUNT(*) > 1
) AS duplicates;

## 11. TOP REPEATED RECORD COMBINATIONS

SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country,
    COUNT(*) AS duplicate_count
FROM online_retail_raw
GROUP BY
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 20;

## 12. CHECK CLEAN TABLE EXISTENCE

SHOW TABLES LIKE 'online_retail_clean';

## 13. CREATE CLEAN TABLE

CREATE TABLE online_retail_clean AS
SELECT DISTINCT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country
FROM online_retail_raw;

## 14. RAW VS CLEAN RECORD COUNT

SELECT
    (SELECT COUNT(*) FROM online_retail_raw) AS raw_records,
    (SELECT COUNT(*) FROM online_retail_clean) AS clean_records,
    (SELECT COUNT(*) FROM online_retail_raw)
      - (SELECT COUNT(*) FROM online_retail_clean) AS removed_duplicate_rows;
      
##15. CLEAN TABLE BLANK VALUE CHECK 
      
      SELECT
    SUM(TRIM(InvoiceNo) = '') AS blank_invoice,
    SUM(TRIM(StockCode) = '') AS blank_stockcode,
    SUM(TRIM(Description) = '') AS blank_description,
    SUM(TRIM(InvoiceDate) = '') AS blank_date,
    SUM(TRIM(CustomerID) = '') AS blank_customer,
    SUM(TRIM(Country) = '') AS blank_country
FROM online_retail_clean;

## 16. CLEAN TABLE NEGATIVE QUANTITY ANALYSIS

SELECT
    COUNT(*) AS total_negative_quantity,
    SUM(InvoiceNo LIKE 'C%') AS cancellation_invoices,
    SUM(InvoiceNo NOT LIKE 'C%') AS other_negative_quantity
FROM online_retail_clean
WHERE Quantity < 0;

## 17. INVOICE DATE VALIDATION

SELECT
    COUNT(*) AS total_records,
    SUM(STR_TO_DATE(InvoiceDate, '%d-%m-%Y %H:%i') IS NULL) AS invalid_dates,
    MIN(STR_TO_DATE(InvoiceDate, '%d-%m-%Y %H:%i')) AS earliest_date,
    MAX(STR_TO_DATE(InvoiceDate, '%d-%m-%Y %H:%i')) AS latest_date
FROM online_retail_clean
WHERE TRIM(InvoiceDate) <> '';

## 18. REVENUE ANALYSIS

SELECT
    ROUND(SUM(Quantity * UnitPrice), 2) AS total_revenue,
    ROUND(SUM(
        CASE
            WHEN Quantity > 0 AND UnitPrice > 0
            THEN Quantity * UnitPrice
            ELSE 0
        END
    ), 2) AS gross_sales_revenue,
    ROUND(SUM(
        CASE
            WHEN Quantity < 0
            THEN Quantity * UnitPrice
            ELSE 0
        END
    ), 2) AS return_value
FROM online_retail_clean;

## 19. MONTHLY SALES ANALYSIS

SELECT
    DATE_FORMAT(
        STR_TO_DATE(InvoiceDate, '%d-%m-%Y %H:%i'),
        '%Y-%m'
    ) AS sales_month,
    ROUND(SUM(Quantity * UnitPrice), 2) AS net_revenue,
    ROUND(SUM(
        CASE
            WHEN Quantity > 0 AND UnitPrice > 0
            THEN Quantity * UnitPrice
            ELSE 0
        END
    ), 2) AS gross_sales,
    COUNT(DISTINCT InvoiceNo) AS total_invoices
FROM online_retail_clean
WHERE TRIM(InvoiceDate) <> ''
GROUP BY sales_month
ORDER BY sales_month;

## 20. COUNTRY-WISE SALES ANALYSIS

SELECT
    Country,
    ROUND(SUM(Quantity * UnitPrice), 2) AS net_revenue,
    SUM(Quantity) AS total_quantity_sold,
    COUNT(DISTINCT InvoiceNo) AS total_invoices
FROM online_retail_clean
GROUP BY Country
ORDER BY net_revenue DESC;

## 21. TOP 10 PRODUCTS BY REVENUE

SELECT
    StockCode,
    Description,
    ROUND(SUM(Quantity * UnitPrice), 2) AS net_revenue,
    SUM(Quantity) AS total_quantity_sold,
    COUNT(DISTINCT InvoiceNo) AS total_invoices
FROM online_retail_clean
WHERE Quantity > 0
    AND UnitPrice > 0
    AND TRIM(Description) <> ''
GROUP BY
    StockCode,
    Description
ORDER BY net_revenue DESC
LIMIT 10;

## 22. TOP 10 CUSTOMERS BY REVENUE

SELECT
    CustomerID,
    Country,
    ROUND(SUM(Quantity * UnitPrice), 2) AS net_revenue,
    SUM(Quantity) AS total_quantity,
    COUNT(DISTINCT InvoiceNo) AS total_invoices
FROM online_retail_clean
WHERE CustomerID IS NOT NULL
    AND TRIM(CustomerID) <> ''
    AND Quantity > 0
    AND UnitPrice > 0
GROUP BY
    CustomerID,
    Country
ORDER BY net_revenue DESC
LIMIT 10;

## 23. ORDER-LEVEL REVENUE ANALYSIS

SELECT
    InvoiceNo,
    CustomerID,
    Country,
    COUNT(*) AS total_items,
    SUM(Quantity) AS total_quantity,
    ROUND(SUM(Quantity * UnitPrice), 2) AS order_revenue
FROM online_retail_clean
WHERE InvoiceNo NOT LIKE 'C%'
GROUP BY
    InvoiceNo,
    CustomerID,
    Country
ORDER BY order_revenue DESC
LIMIT 20;

## 24. AVERAGE ORDER VALUE (AOV)

SELECT
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Quantity * UnitPrice), 2) AS total_revenue,
    ROUND(
        SUM(Quantity * UnitPrice) /
        COUNT(DISTINCT InvoiceNo),
        2
    ) AS average_order_value
FROM online_retail_clean
WHERE InvoiceNo NOT LIKE 'C%'
    AND Quantity > 0
    AND UnitPrice > 0;
    
    ## 25. DAILY SALES ANALYSIS
    
    SELECT
    DATE(STR_TO_DATE(InvoiceDate, '%d-%m-%Y %H:%i')) AS sales_date,
    ROUND(SUM(Quantity * UnitPrice), 2) AS daily_revenue,
    SUM(Quantity) AS total_quantity_sold,
    COUNT(DISTINCT InvoiceNo) AS total_orders
FROM online_retail_clean
WHERE InvoiceNo NOT LIKE 'C%'
    AND Quantity > 0
    AND UnitPrice > 0
GROUP BY sales_date
ORDER BY sales_date;

## 26. WEEKDAY SALES ANALYSIS

SELECT
    DAYNAME(STR_TO_DATE(InvoiceDate, '%d-%m-%Y %H:%i')) AS day_name,
    ROUND(SUM(Quantity * UnitPrice), 2) AS total_revenue,
    SUM(Quantity) AS total_quantity_sold,
    COUNT(DISTINCT InvoiceNo) AS total_orders
FROM online_retail_clean
WHERE InvoiceNo NOT LIKE 'C%'
    AND Quantity > 0
    AND UnitPrice > 0
GROUP BY day_name
ORDER BY total_revenue DESC;

## 27. CLEAN TABLE MISSING VALUE AUDIT

SELECT
    COUNT(*) AS total_records,
    SUM(InvoiceNo IS NULL OR TRIM(InvoiceNo) = '') AS missing_invoice,
    SUM(StockCode IS NULL OR TRIM(StockCode) = '') AS missing_stockcode,
    SUM(Description IS NULL OR TRIM(Description) = '') AS missing_description,
    SUM(InvoiceDate IS NULL OR TRIM(InvoiceDate) = '') AS missing_date,
    SUM(CustomerID IS NULL OR TRIM(CustomerID) = '') AS missing_customer,
    SUM(Country IS NULL OR TRIM(Country) = '') AS missing_country
FROM online_retail_clean;

## 28. QUANTITY AND UNIT PRICE AUDIT

SELECT
    SUM(Quantity < 0) AS negative_quantity,
    SUM(Quantity = 0) AS zero_quantity,
    SUM(UnitPrice < 0) AS negative_price,
    SUM(UnitPrice = 0) AS zero_price
FROM online_retail_clean;

## 29. CLEAN TABLE RECORD COUNT 

SELECT COUNT(*) AS total_records
FROM online_retail_clean;

## 30. CLEAN TABLE DUPLICATE VALIDATION

SELECT
    COUNT(*) AS duplicate_groups,
    COALESCE(SUM(duplicate_count - 1), 0) AS extra_duplicate_rows
FROM (
    SELECT COUNT(*) AS duplicate_count
    FROM online_retail_clean
    GROUP BY
        InvoiceNo,
        StockCode,
        Description,
        Quantity,
        InvoiceDate,
        UnitPrice,
        CustomerID,
        Country
    HAVING COUNT(*) > 1
) AS duplicates;

## 31. OVERALL CLEAN TABLE SUMMARY

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT InvoiceNo) AS unique_invoices,
    COUNT(DISTINCT StockCode) AS unique_products,
    COUNT(DISTINCT Country) AS unique_countries,
    COUNT(DISTINCT NULLIF(TRIM(CustomerID), '')) AS unique_customers,
    ROUND(SUM(Quantity * UnitPrice), 2) AS total_revenue,
    SUM(Quantity) AS total_quantity
FROM online_retail_clean;

## 32. SALES KPI SUMMARY

SELECT
    COUNT(DISTINCT InvoiceNo) AS total_sales_orders,
    COUNT(DISTINCT StockCode) AS products_sold,
    COUNT(DISTINCT Country) AS countries,
    COUNT(DISTINCT NULLIF(TRIM(CustomerID), '')) AS unique_customers,
    ROUND(SUM(Quantity * UnitPrice), 2) AS sales_revenue,
    SUM(Quantity) AS quantity_sold
FROM online_retail_clean
WHERE InvoiceNo NOT LIKE 'C%'
  AND Quantity > 0
  AND UnitPrice > 0
  AND TRIM(Description) <> '';
  
  ## 33. COUNTRY-WISE SALES KPI
  
  SELECT
    Country,
    ROUND(SUM(Quantity * UnitPrice), 2) AS total_revenue,
    SUM(Quantity) AS total_quantity_sold,
    COUNT(DISTINCT InvoiceNo) AS total_orders
FROM online_retail_clean
WHERE InvoiceNo NOT LIKE 'C%'
    AND Quantity > 0
    AND UnitPrice > 0
    AND TRIM(Description) <> ''
GROUP BY Country
ORDER BY total_revenue DESC;

## 34. TOP PRODUCTS BY SALES

SELECT
    StockCode,
    Description,
    SUM(Quantity) AS total_quantity_sold,
    ROUND(SUM(Quantity * UnitPrice), 2) AS total_revenue,
    COUNT(DISTINCT InvoiceNo) AS total_orders
FROM online_retail_clean
WHERE InvoiceNo NOT LIKE 'C%'
    AND Quantity > 0
    AND UnitPrice > 0
    AND TRIM(Description) <> ''
GROUP BY StockCode, Description
ORDER BY total_revenue DESC
LIMIT 10;

## 35. TOP CUSTOMERS BY SALES

SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    SUM(Quantity) AS total_quantity,
    ROUND(SUM(Quantity * UnitPrice), 2) AS total_revenue
FROM online_retail_clean
WHERE InvoiceNo NOT LIKE 'C%'
    AND Quantity > 0
    AND UnitPrice > 0
    AND CustomerID IS NOT NULL
    AND TRIM(CustomerID) <> ''
    AND TRIM(Description) <> ''
GROUP BY CustomerID
ORDER BY total_revenue DESC
LIMIT 10;

## 36. VALID AND INVALID DATE SUMMARY

SELECT
    COUNT(*) AS total_records,
    SUM(
        STR_TO_DATE(InvoiceDate, '%d-%m-%Y %H:%i') IS NOT NULL
    ) AS valid_dates,
    SUM(
        STR_TO_DATE(InvoiceDate, '%d-%m-%Y %H:%i') IS NULL
    ) AS invalid_dates
FROM online_retail_clean
WHERE TRIM(InvoiceDate) <> '';

## 37. MONTHLY SALES KPI

SELECT
    DATE_FORMAT(
        STR_TO_DATE(InvoiceDate, '%d-%m-%Y %H:%i'),
        '%Y-%m'
    ) AS sales_month,

    ROUND(SUM(Quantity * UnitPrice), 2) AS total_revenue,

    SUM(Quantity) AS total_quantity_sold,

    COUNT(DISTINCT InvoiceNo) AS total_orders

FROM online_retail_clean

WHERE InvoiceNo NOT LIKE 'C%'
    AND Quantity > 0
    AND UnitPrice > 0
    AND TRIM(Description) <> ''

GROUP BY sales_month
ORDER BY sales_month;

## 38. TOP ORDERS BY REVENUE

SELECT
    InvoiceNo,
    MIN(InvoiceDate) AS order_date,
    COUNT(DISTINCT StockCode) AS unique_products,
    SUM(Quantity) AS total_quantity,
    ROUND(SUM(Quantity * UnitPrice), 2) AS order_revenue
    
FROM online_retail_clean

WHERE InvoiceNo NOT LIKE 'C%'
    AND Quantity > 0
    AND UnitPrice > 0
    AND CustomerID IS NOT NULL
    AND TRIM(CustomerID) <> ''
    AND TRIM(Description) <> ''
GROUP BY InvoiceNo
ORDER BY order_revenue DESC
LIMIT 10;

## 39. INDIVIDUAL INVOICE DETAIL ANALYSIS

SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    UnitPrice,
    ROUND(Quantity * UnitPrice, 2) AS line_revenue,
    CustomerID,
    Country
FROM online_retail_clean
WHERE InvoiceNo = '581483';

## 40. TOP RETURNED PRODUCTS

SELECT
    StockCode,
    Description,
    SUM(ABS(Quantity)) AS total_returned_quantity,
    COUNT(DISTINCT InvoiceNo) AS return_invoices
FROM online_retail_clean
WHERE
    (InvoiceNo LIKE 'C%' OR Quantity < 0)
    AND Quantity < 0
GROUP BY
    StockCode,
    Description
ORDER BY total_returned_quantity DESC
LIMIT 10;

## 41. CANCELLATION ANALYSIS

SELECT
    COUNT(DISTINCT InvoiceNo) AS cancellation_invoices,
    COUNT(*) AS cancellation_records,
    SUM(ABS(Quantity)) AS total_cancelled_quantity,
    ROUND(
        SUM(ABS(Quantity) * UnitPrice),
        2
    ) AS estimated_cancelled_value
FROM online_retail_clean
WHERE InvoiceNo LIKE 'C%';

## 42. CLEAN TABLE KPI SUMMARY

SELECT
    COUNT(*) AS total_clean_records,
    COUNT(DISTINCT InvoiceNo) AS unique_invoices,
    COUNT(DISTINCT StockCode) AS unique_products,
    COUNT(DISTINCT CustomerID) AS unique_customers,
    COUNT(DISTINCT Country) AS unique_countries
FROM online_retail_clean;

## 43. COMPREHENSIVE DATA QUALITY AUDIT

SELECT
    COUNT(*) AS total_records,

    SUM(InvoiceNo IS NULL) AS missing_invoice,
    SUM(StockCode IS NULL) AS missing_stockcode,
    SUM(Description IS NULL OR TRIM(Description) = '') AS missing_description,
    SUM(InvoiceDate IS NULL OR TRIM(InvoiceDate) = '') AS missing_date,
    SUM(CustomerID IS NULL OR TRIM(CustomerID) = '') AS missing_customer,
    SUM(Country IS NULL OR TRIM(Country) = '') AS missing_country,

    SUM(Quantity <= 0) AS non_positive_quantity,
    SUM(UnitPrice <= 0) AS non_positive_price

FROM online_retail_clean;

## 44. RAW VS CLEAN QUANTITY COMPARISON

SELECT
    'Raw Table' AS table_name,
    COUNT(*) AS non_positive_quantity_records
FROM online_retail_raw
WHERE Quantity <= 0

UNION ALL

SELECT
    'Clean Table' AS table_name,
    COUNT(*) AS non_positive_quantity_records
FROM online_retail_clean
WHERE Quantity <= 0;

## 45. DATA QUALITY ISSUES SUMMARY

SELECT
    COUNT(*) AS total_records,
    SUM(Description IS NULL OR TRIM(Description) = '') AS missing_description,
    SUM(CustomerID IS NULL OR TRIM(CustomerID) = '') AS missing_customer,
    SUM(Quantity < 0) AS negative_quantity,
    SUM(Quantity = 0) AS zero_quantity,
    SUM(UnitPrice < 0) AS negative_price,
    SUM(UnitPrice = 0) AS zero_price
FROM online_retail_clean;

## 46. FINAL CLEAN TABLE SUMMARY

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT InvoiceNo) AS unique_invoices,
    COUNT(DISTINCT StockCode) AS unique_products,
    COUNT(DISTINCT Country) AS unique_countries,
    COUNT(DISTINCT NULLIF(TRIM(CustomerID), '')) AS unique_customers,
    ROUND(SUM(Quantity * UnitPrice), 2) AS total_revenue
FROM online_retail_clean;
      
## 47. RAW VS CLEAN BLANK CUSTOMER ID COMPARISON
     
	SELECT
    'Raw Table' AS table_name,
    COUNT(*) AS total_records,
    SUM(TRIM(CustomerID) = '') AS blank_customer_ids
FROM online_retail_raw

UNION ALL

SELECT
    'Clean Table' AS table_name,
    COUNT(*) AS total_records,
    SUM(TRIM(CustomerID) = '') AS blank_customer_ids
FROM online_retail_clean;

## 48. DETAILED RAW VS CLEAN DATA QUALITY COMPARISON

WITH raw_stats AS (
    SELECT
        COUNT(*) AS total_records,
        SUM(Description IS NULL OR TRIM(Description) = '') AS missing_description,
        SUM(CustomerID IS NULL OR TRIM(CustomerID) = '') AS missing_customer,
        SUM(Quantity < 0) AS negative_quantity,
        SUM(Quantity = 0) AS zero_quantity,
        SUM(UnitPrice < 0) AS negative_price,
        SUM(UnitPrice = 0) AS zero_price
    FROM online_retail_raw
),
clean_stats AS (
    SELECT
        COUNT(*) AS total_records,
        SUM(Description IS NULL OR TRIM(Description) = '') AS missing_description,
        SUM(CustomerID IS NULL OR TRIM(CustomerID) = '') AS missing_customer,
        SUM(Quantity < 0) AS negative_quantity,
        SUM(Quantity = 0) AS zero_quantity,
        SUM(UnitPrice < 0) AS negative_price,
        SUM(UnitPrice = 0) AS zero_price
    FROM online_retail_clean
)
SELECT
    'Total Records' AS metric,
    r.total_records AS raw_count,
    c.total_records AS clean_count,
    r.total_records - c.total_records AS difference
FROM raw_stats r CROSS JOIN clean_stats c

UNION ALL

SELECT
    'Missing Description',
    r.missing_description,
    c.missing_description,
    r.missing_description - c.missing_description
FROM raw_stats r CROSS JOIN clean_stats c

UNION ALL

SELECT
    'Missing Customer ID',
    r.missing_customer,
    c.missing_customer,
    r.missing_customer - c.missing_customer
FROM raw_stats r CROSS JOIN clean_stats c

UNION ALL

SELECT
    'Negative Quantity',
    r.negative_quantity,
    c.negative_quantity,
    r.negative_quantity - c.negative_quantity
FROM raw_stats r CROSS JOIN clean_stats c

UNION ALL

SELECT
    'Zero Quantity',
    r.zero_quantity,
    c.zero_quantity,
    r.zero_quantity - c.zero_quantity
FROM raw_stats r CROSS JOIN clean_stats c

UNION ALL

SELECT
    'Negative Unit Price',
    r.negative_price,
    c.negative_price,
    r.negative_price - c.negative_price
FROM raw_stats r CROSS JOIN clean_stats c

UNION ALL

SELECT
    'Zero Unit Price',
    r.zero_price,
    c.zero_price,
    r.zero_price - c.zero_price
FROM raw_stats r CROSS JOIN clean_stats c;

 ## 49. NEGATIVE UNIT PRICE INVESTIGATION
 
SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country,
    ROUND(Quantity * UnitPrice, 2) AS line_revenue
FROM online_retail_clean
WHERE UnitPrice < 0;

## 50. ZERO UNIT PRICE INVESTIGATION

SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country,
    ROUND(Quantity * UnitPrice, 2) AS line_revenue
FROM online_retail_clean
WHERE UnitPrice = 0
LIMIT 20;

SELECT
    COUNT(*) AS total_zero_price_records,
    SUM(Quantity > 0) AS positive_quantity_records,
    SUM(Quantity < 0) AS negative_quantity_records,
    SUM(Quantity = 0) AS zero_quantity_records,
    SUM(TRIM(CustomerID) = '') AS missing_customer_records
FROM online_retail_clean
WHERE UnitPrice = 0;

## 51. FINAL RAW AND CLEAN RECORD COUNT

SELECT COUNT(*) AS raw_records
FROM online_retail_raw;

SELECT COUNT(*) AS clean_records
FROM online_retail_clean;