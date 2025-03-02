# Ecommerce Sales & Inventory Analysis_SQL

## 📑 Table of Contents
1. 📌 Background & Overview
2. 📂 Dataset Description & Data Structure
3. ⚒️ Main Process
4. 🔎 Final Conclusion & Recommendations

---

## 📌 Background & Overview  

### 🎯 Objective:  
This project analyzes sales, customer retention, and inventory trends in AdventureWorks to:  
✔️ Evaluate sales performance and category growth trends.  
✔️ Identify high-performing territories and seasonal discount impacts.  
✔️ Assess inventory levels and stock-sales ratios for optimization.  
✔️ Analyze customer retention trends to improve loyalty programs.  

### 👤 Who is this project for?  
✔️ Sales & Marketing Teams  
✔️ Supply Chain & Inventory Managers  
✔️ Business Analysts & Decision-makers  

### ❓ Business Questions:  
✔️ What are the top-performing product subcategories based on sales and order quantity?  
✔️ Which categories experienced the highest YoY growth?  
✔️ What are the top sales territories, and how do they rank annually?  
✔️ What is the total cost of seasonal discounts per subcategory?  
✔️ How does customer retention trend over time?  
✔️ What is the stock level trend and stock-to-sales ratio per product?  
✔️ How many orders are in pending status, and what is their total value?  

---

## 📂 Dataset Description & Data Structure  

### 📌 Data Source:  
✔️ **Source:** AdventureWorks Database  
✔️ **Format:** SQL  

### 📊 Data Structure & Relationships  

#### 1️⃣ Tables Used:
The dataset consists of session-level Google Analytics data.

#### 2️⃣ Table Schema & Data Snapshot  
##### **Table: Session Data**
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| fullVisitorId | STRING | Unique visitor ID |
| date | STRING | Session date in YYYYMMDD format |
| totals | RECORD | Aggregated session metrics |
| totals.bounces | INTEGER | 1 if session bounced, else NULL |
| totals.hits | INTEGER | Total number of hits in the session |
| totals.pageviews | INTEGER | Total number of pageviews |
| totals.visits | INTEGER | 1 for interactive sessions, NULL otherwise |
| totals.transactions | INTEGER | Total number of e-commerce transactions |
| traffic.source | STRING | Traffic source (e.g., search engine, URL, referrer) |

##### **Table: Hits Data**
| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| hits | RECORD | Contains details of individual hits |
| hits.eCommerceAction | RECORD | All e-commerce actions during the session |
| hits.eCommerceAction.action_type | STRING | Action type (view, add-to-cart, checkout, purchase, etc.) |
| hits.product | RECORD | Nested product details for e-commerce transactions |
| hits.product.productQuantity | INTEGER | Quantity of product purchased |
| hits.product.productRevenue | INTEGER | Revenue from product purchase (scaled by 10^6) |
| hits.product.productSKU | STRING | Product SKU |
| hits.product.v2ProductName | STRING | Product Name |

---

## ⚒️ Main Process  
1️⃣ **Data Cleaning & Preprocessing**  
- Ensured session and transaction data integrity  
- Filtered out incomplete or irrelevant records  

2️⃣ **Exploratory Data Analysis (EDA)**  
- Analyzed bounce rates, page views, and transactions  
- Identified key e-commerce actions and trends  

3️⃣ **SQL Analysis**  
- Used window functions, joins, and aggregations to extract insights  
- Created queries for session behavior and revenue analysis  

---

## 🔎 Final Conclusion & Recommendations  

## Query 1: Sales Summary by Subcategory (Last 12 Months)
```sql
SELECT DISTINCT FORMAT_DATETIME('%b %Y', a.ModifiedDate) AS period,
      c.name,
      SUM(a.OrderQty) AS item_quantity,
      SUM(a.LineTotal) AS total_sales,
      COUNT(DISTINCT a.SalesOrderID) AS order_quantity
FROM `adventureworks2019.Sales.SalesOrderDetail` a
LEFT JOIN `adventureworks2019.Production.Product` b ON a.ProductID = b.ProductID
LEFT JOIN `adventureworks2019.Production.ProductSubcategory` c 
ON CAST(b.ProductSubcategoryID AS INT) = c.ProductSubcategoryID
WHERE DATE(a.ModifiedDate) BETWEEN (DATE_SUB('2014-06-30', INTERVAL 12 MONTH)) AND '2014-06-30'
GROUP BY 1, 2    
ORDER BY 1 DESC, 2;  
```
### Insights:
- Tracks sales trends by subcategory over the last 12 months.
- Provides insights into which subcategories contribute most to revenue and order volume.

## Query 2: Year-over-Year Growth & Top 3 Fastest Growing Subcategories
```sql
WITH sale_info AS (
  SELECT FORMAT_TIMESTAMP('%Y', a.ModifiedDate) AS year,
      c.Name,
      SUM(a.OrderQty) AS qty_item
  FROM `adventureworks2019.Sales.SalesOrderDetail` a 
  LEFT JOIN `adventureworks2019.Production.Product` b ON a.ProductID = b.ProductID
  LEFT JOIN `adventureworks2019.Production.ProductSubcategory` c 
  ON CAST(b.ProductSubcategoryID AS INT) = c.ProductSubcategoryID
  GROUP BY 1, 2
),

sale_diff AS (
  SELECT *,
      LEAD(qty_item) OVER (PARTITION BY Name ORDER BY year DESC) AS prv_qty,
      ROUND(qty_item / LEAD(qty_item) OVER (PARTITION BY Name ORDER BY year DESC) - 1, 2) AS qty_diff
  FROM sale_info
),

rk_qty_diff AS (
  SELECT *,
      DENSE_RANK() OVER (ORDER BY qty_diff DESC) AS dk
  FROM sale_diff
)

SELECT DISTINCT Name, qty_item, prv_qty, qty_diff, dk
FROM rk_qty_diff 
WHERE dk <= 3
ORDER BY dk;
```
### Insights:
- Identifies the top 3 subcategories with the highest year-over-year growth.
- Helps in recognizing the fastest-growing segments for strategic focus.

## Query 3: Top 3 Sales Territories by Order Volume per Year
```sql
WITH calc AS (
  SELECT EXTRACT(YEAR FROM a.ModifiedDate) AS year,
      b.TerritoryID,
      SUM(OrderQty) AS item_quantity  
  FROM `adventureworks2019.Sales.SalesOrderDetail` a
  LEFT JOIN `adventureworks2019.Sales.SalesOrderHeader` b 
  ON a.SalesOrderID = b.SalesOrderID
  GROUP BY 1, 2
),

ranking AS (
  SELECT *, DENSE_RANK() OVER (PARTITION BY year ORDER BY item_quantity DESC) AS rank
  FROM calc
)

SELECT * FROM ranking WHERE rank <= 3;
```
### Insights:
- Determines top-performing sales territories.
- Supports sales strategy refinement by highlighting key regions.

## Query 4: Total Seasonal Discount Cost by Subcategory
```sql
SELECT FORMAT_TIMESTAMP('%Y', ModifiedDate) AS yr,
    Name,
    SUM(disc_cost) AS total_cost
FROM (
    SELECT DISTINCT a.*, c.Name, d.DiscountPct, d.Type,
        a.OrderQty * d.DiscountPct * UnitPrice AS disc_cost
    FROM `adventureworks2019.Sales.SalesOrderDetail` a
    LEFT JOIN `adventureworks2019.Production.Product` b ON a.ProductID = b.ProductID
    LEFT JOIN `adventureworks2019.Production.ProductSubcategory` c ON CAST(b.ProductSubcategoryID AS INT) = c.ProductSubcategoryID
    LEFT JOIN `adventureworks2019.Sales.SpecialOffer` d ON a.SpecialOfferID = d.SpecialOfferID
    WHERE LOWER(d.Type) LIKE '%seasonal discount%'
)
GROUP BY 1, 2;
```
### Insights:
- Evaluates the financial impact of seasonal discounts.
- Helps in optimizing discount strategies for profitability.

## Query 5: Customer Retention Rate (Cohort Analysis - 2014)
```sql
WITH total_order AS (
  SELECT EXTRACT(MONTH FROM ModifiedDate) AS month_order,
      CustomerID
  FROM `adventureworks2019.Sales.SalesOrderHeader`
  WHERE Status = 5 AND EXTRACT(YEAR FROM ModifiedDate) = 2014
),
row_nb AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY month_order) AS rn
  FROM total_order
),
first_order AS (
  SELECT month_order AS first_month_order, CustomerID
  FROM row_nb
  WHERE rn = 1
)
SELECT month_order, first_month_order,
      CONCAT('M-', month_order - first_month_order) AS month_diff,
      COUNT(DISTINCT a.CustomerID) AS current_cus
FROM total_order a
LEFT JOIN first_order b ON a.CustomerID = b.CustomerID
GROUP BY 1, 2
ORDER BY 2, 3;
```
### Insights:
- Tracks how many customers return in subsequent months after their first purchase.
- Aids in customer loyalty strategy planning.

## Query 6: Stock Level Trends & Month-over-Month Changes (2011)
```sql
WITH calc AS (
  SELECT a.Name,
      EXTRACT(MONTH FROM b.ModifiedDate) AS month,
      EXTRACT(YEAR FROM b.ModifiedDate) AS year,
      SUM(StockedQty) AS stock
  FROM `adventureworks2019.Production.Product` a
  JOIN `adventureworks2019.Production.WorkOrder` b ON a.ProductID = b.ProductID
  WHERE EXTRACT(YEAR FROM b.ModifiedDate) = 2011
  GROUP BY 3, 2, 1
),
prv AS (
  SELECT *, LEAD(stock) OVER (PARTITION BY year, Name ORDER BY month DESC) AS prv_stock
  FROM calc
)
SELECT *, COALESCE(ROUND((stock - prv_stock) * 100 / prv_stock, 1), 0.0) AS diff
FROM prv;
```
### Insights:
- Identifies stock fluctuations and trends over time.
- Helps in inventory planning and supply chain management.

## Query 7: Stock-to-Sales Ratio (2011)
```sql
WITH sale_info AS (
  SELECT EXTRACT(MONTH FROM a.ModifiedDate) AS mth,
      EXTRACT(YEAR FROM a.ModifiedDate) AS yr,
      a.ProductId,
      b.Name,
      SUM(a.OrderQty) AS sales
  FROM `adventureworks2019.Sales.SalesOrderDetail` a 
  LEFT JOIN `adventureworks2019.Production.Product` b ON a.ProductID = b.ProductID
  WHERE FORMAT_TIMESTAMP('%Y', a.ModifiedDate) = '2011'
  GROUP BY 1, 2, 3, 4
),
stock_info AS (
  SELECT EXTRACT(MONTH FROM ModifiedDate) AS mth,
      EXTRACT(YEAR FROM ModifiedDate) AS yr,
      ProductId,
      SUM(StockedQty) AS stock_cnt
  FROM `adventureworks2019.Production.WorkOrder`
  WHERE FORMAT_TIMESTAMP('%Y', ModifiedDate) = '2011'
  GROUP BY 1, 2, 3
)
SELECT a.*, COALESCE(b.stock_cnt, 0) AS stock,
      ROUND(COALESCE(b.stock_cnt, 0) / sales, 2) AS ratio
FROM sale_info a
FULL JOIN stock_info b ON a.ProductId = b.ProductId
  AND a.mth = b.mth AND a.yr = b.yr
ORDER BY 1 DESC, 7 DESC;
```
### Insights:
- Compares stock levels to sales volumes, helping optimize inventory levels.

### 📌 Key Takeaways:
✔️ Optimize product page experience to reduce bounce rates.  
✔️ Target high-engagement users with personalized offers.  
✔️ Improve checkout process to reduce cart abandonment.  
