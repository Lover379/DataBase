
SELECT
    YEAR(DateAdd) AS [Year],
    MONTH(DateAdd) AS [Month],
    VendorID,
    COUNT(DISTINCT DocumentID) AS DocumentsCount,
    COUNT(DISTINCT ProductID) AS ProductsCount,
    SUM(ABS(Amount)) AS TotalPurchases
FROM bm_StorageOperations
WHERE OperationID = 1
  AND VendorID IN (211, 200, 107, 92, 202)
GROUP BY
    YEAR(DateAdd),
    MONTH(DateAdd),
    VendorID
ORDER BY
    [Year],
    [Month],
    VendorID;
GO
