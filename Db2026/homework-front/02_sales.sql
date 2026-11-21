
SELECT
    YEAR(dater) AS [Year],
    MONTH(dater) AS [Month],
    COUNT(*) AS SalesPositions,
    COUNT(DISTINCT id) AS UniqueProducts,
    SUM(quantity) AS TotalQuantity,
    SUM(amount) AS TotalRevenue
FROM journal
WHERE transtype = 101
  AND grouptranstype = 1
  AND status = 0
  AND flagrefund = 0
GROUP BY
    YEAR(dater),
    MONTH(dater)
ORDER BY
    [Year],
    [Month];
GO
