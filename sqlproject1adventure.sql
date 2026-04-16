-- SQL is language used to manange and query data stored in database.
-- Businesses use sql to analyse data,create reports, and support better decision making
create database adventure_data;
use adventure_data;
-- 1.Total Sales,total profit,production cost(Aggregate Function) for Sales Analysis and profit analyze Using Aggregates
SELECT
    ROUND(SUM(SalesAmount) / 1000000, 2) AS Total_Sales_M,
    ROUND(SUM(ProductionCost) / 1000000, 2) AS Production_Cost_M,
    ROUND(SUM(SalesAmount - ProductionCost) / 1000000, 2) AS Total_Profit_M
FROM (
    SELECT
        (UnitPrice * (1 - UnitPriceDiscountPct)) AS SalesAmount,
        ProductStandardCost AS ProductionCost
    FROM factinternetsales
    UNION ALL
    SELECT
        (UnitPrice * (1 - UnitPriceDiscountPct)) AS SalesAmount,
        ProductStandardCost AS ProductionCost
    FROM factinternetsales
) t;

-- 2.Region-wise Sales & Profit (JOIN + GROUP BY)
SELECT
    st.SalesTerritoryRegion,
    ROUND(SUM(f.UnitPrice * (1 - f.UnitPriceDiscountPct)) / 1000000, 2) AS Sales_M,
    ROUND(
        SUM(
            (f.UnitPrice * (1 - f.UnitPriceDiscountPct))
            - f.ProductStandardCost
        ) / 1000000, 2
    ) AS Profit_M
FROM factinternetsales f
JOIN dimsalesterritory st
    ON f.SalesTerritoryKey = st.SalesTerritoryKey
GROUP BY st.SalesTerritoryRegion;



-- 3.Year-wise Sales, Cost & Profit (Time Analysis)
SELECT
    d.CalendarYear,
    ROUND(SUM(f.UnitPrice * (1 - f.UnitPriceDiscountPct)) / 1000000, 2) AS Sales_M,
    ROUND(SUM(f.ProductStandardCost) / 1000000, 2) AS Cost_M,
    ROUND(
        SUM(
            (f.UnitPrice * (1 - f.UnitPriceDiscountPct))
            - f.ProductStandardCost
        ) / 1000000, 2
    ) AS Profit_M
FROM factinternetsales f
JOIN dimdate d
    ON f.OrderDate = d.FullDateAlternateKey
GROUP BY d.CalendarYear
ORDER BY d.CalendarYear;

-- 4.Month-wise Sales Trend
SELECT
    d.CalendarYear,
    d.EnglishMonthName,
    ROUND(SUM(f.UnitPrice * (1 - f.UnitPriceDiscountPct)) / 1000000, 2) AS Monthly_Sales_M
FROM factinternetsales f
JOIN dimdate d
    ON f.OrderDate = d.FullDateAlternateKey
GROUP BY
    d.CalendarYear,
    d.EnglishMonthName,
    d.MonthNumberOfYear
ORDER BY
    d.CalendarYear,
    d.MonthNumberOfYear;

-- 5.Month-wise Profit Analysis
SELECT
    d.CalendarYear,
    d.EnglishMonthName,
    ROUND(
        SUM(
            (f.UnitPrice * (1 - f.UnitPriceDiscountPct))
            - f.ProductStandardCost
        ) / 1000000, 2
    ) AS Monthly_Profit_M
FROM factinternetsales f
JOIN dimdate d
    ON f.OrderDate = d.FullDateAlternateKey
GROUP BY
    d.CalendarYear,
    d.EnglishMonthName,
    d.MonthNumberOfYear;
    


-- --6. Product Category-wise Profit (Multi-table Join)
SELECT
    pc.EnglishProductCategoryName,
    ROUND(
        SUM(
            (f.UnitPrice * (1 - f.UnitPriceDiscountPct))
            - f.ProductStandardCost
        ) / 1000000, 2
    ) AS Profit_M
FROM factinternetsales f
JOIN dimproduct p
    ON f.ProductKey = p.ProductKey
JOIN dimproductsubcategory ps
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
JOIN dim_product_category pc
    ON ps.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY pc.EnglishProductCategoryName;




-- 7. Customer Income Category (CASE Statement)
SELECT
    CustomerKey,
    YearlyIncome,
    CASE
        WHEN YearlyIncome < 40000 THEN 'Low Income'
        WHEN YearlyIncome BETWEEN 40000 AND 80000 THEN 'Middle Income'
        ELSE 'High Income'
    END AS Income_Category
FROM dimcustomer;





 -- 8.Window Function – Running Total of Sales
 -- window functions to rank products based on sales performance.
  SELECT 
    p.EnglishProductName,
    SUM(f.ExtendedAmount) AS Product_Sales,
    RANK() OVER (ORDER BY SUM(f.ExtendedAmount) DESC) AS Sales_Rank
FROM fact_internet_sales_new f
JOIN dimproduct p
    ON f.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName;






-- 9. Top 5 Products by Sales (Window Function)
SELECT *
FROM (
    SELECT
        p.EnglishProductName,
        ROUND(SUM(f.UnitPrice * (1 - f.UnitPriceDiscountPct)) / 1000000, 2) AS Sales_M,
        RANK() OVER (
            ORDER BY SUM(f.UnitPrice * (1 - f.UnitPriceDiscountPct)) DESC
        ) AS Sales_Rank
    FROM factinternetsales f
    JOIN dimproduct p
        ON f.ProductKey = p.ProductKey
    GROUP BY p.EnglishProductName
) t
WHERE Sales_Rank <= 5;





-- 10.stored procedure
-- . Stored Procedure (MySQL – INPUT & OUTPUT parameter)
DELIMITER //

CREATE PROCEDURE GetTotalSalesByYear (
    IN p_Year INT,
    OUT p_TotalSales DECIMAL(28,2)
)
BEGIN
    SELECT COALESCE(SUM(f.ExtendedAmount), 0)
    INTO p_TotalSales
    FROM fact_internet_sales_new f
    JOIN dimdate d
        ON d.FullDateAlternateKey = f.OrderDate
    WHERE d.CalendarYear = p_Year;
END //

DELIMITER ;

-- Call the procedure for the year 2014
CALL GetTotalSalesByYear(2014, @TotalSales);

-- Display the output
SELECT @TotalSales AS Total_Sales_2014;

-- 11.Subquery: Products with Above-Average Profit
SELECT
    p.EnglishProductName,
    ROUND(
        SUM(
            (f.UnitPrice * (1 - f.UnitPriceDiscountPct))
            - f.ProductStandardCost
        ) / 1000000, 2
    ) AS Profit_M
FROM factinternetsales f
JOIN dimproduct p
    ON f.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName
HAVING
    SUM(
        (f.UnitPrice * (1 - f.UnitPriceDiscountPct))
        - f.ProductStandardCost
    ) >
    (
        SELECT
            AVG(
                (f2.UnitPrice * (1 - f2.UnitPriceDiscountPct))
                - f2.ProductStandardCost
            )
        FROM factinternetsales f2
    );


