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
👉 Based on the findings, we recommend the following:  

### 📌 Key Takeaways:
✔️ Optimize product page experience to reduce bounce rates.  
✔️ Target high-engagement users with personalized offers.  
✔️ Improve checkout process to reduce cart abandonment.  
