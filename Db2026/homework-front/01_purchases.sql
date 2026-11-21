
SELECT
    YEAR(DateAdd) AS [Year],
    MONTH(DateAdd) AS [Month],
    COUNT(*) AS OperationsCount,
    COUNT(DISTINCT DocumentID) AS DocumentsCount,
    COUNT(DISTINCT VendorID) AS SuppliersCount,
    SUM(ABS(Amount)) AS TotalAmount
FROM bm_StorageOperations
WHERE OperationID = 1
GROUP BY
    YEAR(DateAdd),
    MONTH(DateAdd)
ORDER BY
    [Year],
    [Month];
GO
