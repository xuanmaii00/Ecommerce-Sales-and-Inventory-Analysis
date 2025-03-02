--Query 1: Calculate Quantity of items, Sales value & Order quantity by each Subcategory in Last 12 months
SELECT distinct format_datetime('%b %Y', a.ModifiedDate) as period
      , c.name
      , sum(a.OrderQty) as item_quantity
      , sum(a.LineTotal) as total_sales
      , count(distinct a.SalesOrderID) as order_quatity
FROM `adventureworks2019.Sales.SalesOrderDetail` a
LEFT JOIN `adventureworks2019.Production.Product` b 
ON a.ProductID=b.ProductID
LEFT JOIN `adventureworks2019.Production.ProductSubcategory` c
ON cast(b.ProductSubcategoryID as int)=c.ProductSubcategoryID
WHERE date(a.ModifiedDate) between (date_sub('2014-06-30', INTERVAL 12 month)) and '2014-06-30' 
GROUP BY 1,2    
ORDER BY 1 desc,2;                       
            

--Query 2: Calculate YoY growth rate in percentage by SubCategory & release top 3 Category with highest growth rate 
WITH 
sale_info AS (
  SELECT 
      FORMAT_TIMESTAMP("%Y", a.ModifiedDate) AS year,
      c.Name,
      SUM(a.OrderQty) AS qty_item
  FROM `adventureworks2019.Sales.SalesOrderDetail` a 
  LEFT JOIN `adventureworks2019.Production.Product` b ON a.ProductID = b.ProductID
  LEFT JOIN `adventureworks2019.Production.ProductSubcategory` c ON CAST(b.ProductSubcategoryID AS INT) = c.ProductSubcategoryID
  GROUP BY 1, 2
  ORDER BY 2 ASC, 1 DESC
),

sale_diff AS (
  SELECT *,
      LEAD(qty_item) OVER (PARTITION BY Name ORDER BY year DESC) AS prv_qty,
      ROUND(qty_item / (LEAD(qty_item) OVER (PARTITION BY Name ORDER BY year DESC)) - 1, 2) AS qty_diff
  FROM sale_info
  ORDER BY 5 DESC
),

rk_qty_diff AS (
  SELECT *,
      DENSE_RANK() OVER (ORDER BY qty_diff DESC) AS dk
  FROM sale_diff
)

SELECT DISTINCT Name,
      qty_item,
      prv_qty,
      qty_diff,
      dk
FROM rk_qty_diff 
WHERE dk <= 3
ORDER BY dk;



--Query 3: Ranking Top 3 TerritoryID with biggest Order quantity of every year  
WITH 
calc as
(SELECT extract(year from a.ModifiedDate) as year
      , b.TerritoryID
      , sum(OrderQty) as item_quantity  
FROM `adventureworks2019.Sales.SalesOrderDetail` a
LEFT JOIN `adventureworks2019.Sales.SalesOrderHeader` b 
ON a.SalesOrderID=b.SalesOrderID
GROUP BY 1,2
ORDER BY 1 desc, 3 desc)

, ranking as 
 (SELECT *
      , dense_rank() over (partition by year order by item_quantity desc) as rank
FROM calc
ORDER BY year desc, rank)

SELECT *
FROM ranking
WHERE rank <=3;


--Query 4: Calculate Total Discount Cost belongs to Seasonal Discount for each SubCategory
SELECT 
    FORMAT_TIMESTAMP("%Y", ModifiedDate) AS yr,
    Name,
    SUM(disc_cost) AS total_cost
FROM (
    SELECT DISTINCT a.*,
        c.Name,
        d.DiscountPct,
        d.Type,
        a.OrderQty * d.DiscountPct * UnitPrice AS disc_cost
    FROM `adventureworks2019.Sales.SalesOrderDetail` a
    LEFT JOIN `adventureworks2019.Production.Product` b ON a.ProductID = b.ProductID
    LEFT JOIN `adventureworks2019.Production.ProductSubcategory` c ON CAST(b.ProductSubcategoryID AS INT) = c.ProductSubcategoryID
    LEFT JOIN `adventureworks2019.Sales.SpecialOffer` d ON a.SpecialOfferID = d.SpecialOfferID
    WHERE LOWER(d.Type) LIKE '%seasonal discount%'
)
GROUP BY 1, 2;


--Query 5: Retention rate of Customer in 2014 with status of Successfully Shipped (Cohort Analysis)
WITH total_order as(
SELECT extract(month from ModifiedDate) as month_order
      , CustomerID
FROM `adventureworks2019.Sales.SalesOrderHeader`
WHERE Status=5
    AND extract(year from ModifiedDate)= 2014
)
,row_nb as (
SELECT *, 
row_number() over (partition by CustomerID order by month_order) as rn
FROM total_order
)
,first_order as (
SELECT month_order as first_month_order
      , CustomerID
FROM row_nb
WHERE rn=1
)
SELECT month_order
      , first_month_order
      , concat('M-',month_order- first_month_order) as month_diff
      , count(distinct a.CustomerID) as current_cus
FROM total_order a
LEFT JOIN first_order b
on a.CustomerID=b.CustomerID
GROUP BY 1,2
ORDER BY 2,3;


--Query 6: Trend of Stock level & MoM diff % by all product in 2011.
WITH calc as (
SELECT a.Name
      , extract(month from b.ModifiedDate) as month
      , extract(year from b.ModifiedDate) as year
      , sum(StockedQty) as stock
FROM `adventureworks2019.Production.Product` a
JOIN `adventureworks2019.Production.WorkOrder` b
ON a.ProductID=b.ProductID
WHERE extract (year from b.ModifiedDate)= 2011
GROUP BY 3,2,1
ORDER BY 3,1, 2 desc
)
, prv as 
(SELECT *
      , lead(Stock) over( partition by year,Name order by month desc) as prv_stock
FROM calc
ORDER BY 3,1, 2 desc
)
SELECT *
      , coalesce(round((stock-prv_stock)*100/prv_stock,1),0.0) as diff
FROM prv;


--Query 7: Calculate Ratio of Stock / Sales in 2011 by product name, by month
WITH 
sale_info AS (
  SELECT 
      EXTRACT(MONTH FROM a.ModifiedDate) AS mth, 
      EXTRACT(YEAR FROM a.ModifiedDate) AS yr, 
      a.ProductId, 
      b.Name, 
      SUM(a.OrderQty) AS sales
  FROM `adventureworks2019.Sales.SalesOrderDetail` a 
  LEFT JOIN `adventureworks2019.Production.Product` b 
    ON a.ProductID = b.ProductID
  WHERE FORMAT_TIMESTAMP("%Y", a.ModifiedDate) = '2011'
  GROUP BY 1, 2, 3, 4
), 

stock_info AS (
  SELECT
      EXTRACT(MONTH FROM ModifiedDate) AS mth, 
      EXTRACT(YEAR FROM ModifiedDate) AS yr, 
      ProductId, 
      SUM(StockedQty) AS stock_cnt
  FROM `adventureworks2019.Production.WorkOrder`
  WHERE FORMAT_TIMESTAMP("%Y", ModifiedDate) = '2011'
  GROUP BY 1, 2, 3
)

SELECT
      a.*,
      COALESCE(b.stock_cnt, 0) AS stock,
      ROUND(COALESCE(b.stock_cnt, 0) / sales, 2) AS ratio
FROM sale_info a 
FULL JOIN stock_info b 
  ON a.ProductId = b.ProductId
  AND a.mth = b.mth 
  AND a.yr = b.yr
ORDER BY 1 DESC, 7 DESC;


--Query 8: Number of order and value at Pending status in 2014
SELECT extract(year from ModifiedDate) as year
      , status
      , count(distinct PurchaseOrderID) as order_count
      , sum( TotalDue) as total
 FROM `adventureworks2019.Purchasing.PurchaseOrderHeader` 
WHERE extract(year from ModifiedDate)=2014
      AND status=1
GROUP BY 1,2;

