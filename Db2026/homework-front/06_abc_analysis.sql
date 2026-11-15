
WITH ProductSales AS (
    SELECT
        id AS ProductID,
        description AS ProductName,
        SUM(amount) AS Revenue
    FROM journal
    WHERE transtype = 101
      AND grouptranstype = 1
      AND status = 0
      AND flagrefund = 0
    GROUP BY id, description
),
SalesShares AS (
    SELECT
        ProductID,
        ProductName,
        Revenue,
        SUM(Revenue) OVER() AS TotalRevenue
    FROM ProductSales
),
ABC AS (
    SELECT
        ProductID,
        ProductName,
        Revenue,
        CAST(Revenue * 100.0 / NULLIF(TotalRevenue, 0) AS decimal(10,2)) AS SharePercent,
        CAST(
            SUM(Revenue) OVER (
                ORDER BY Revenue DESC
                ROWS UNBOUNDED PRECEDING
            ) * 100.0 / NULLIF(TotalRevenue, 0)
            AS decimal(10,2)
        ) AS CumulativePercent
    FROM SalesShares
)
SELECT
    ProductID,
    ProductName,
    Revenue,
    SharePercent,
    CumulativePercent,
    CASE
        WHEN CumulativePercent <= 80 THEN 'A'
        WHEN CumulativePercent <= 95 THEN 'B'
        ELSE 'C'
    END AS ABC_Group
FROM ABC
ORDER BY Revenue DESC;
GO
