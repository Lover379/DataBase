
SELECT
    YEAR(DateAdd) AS [Year],
    DATEPART(ISO_WEEK, DateAdd) AS [Week],
    SUM(CASE WHEN OperationID = 1 THEN ABS(Count) ELSE 0 END) AS Received,
    SUM(CASE WHEN OperationID = 2 THEN ABS(Count) ELSE 0 END) AS WrittenOff,
    SUM(CASE WHEN OperationID = 1 THEN Amount ELSE 0 END) AS ReceiptAmount,
    SUM(CASE WHEN OperationID = 2 THEN ABS(Amount) ELSE 0 END) AS WriteOffAmount
FROM bm_StorageOperations
GROUP BY
    YEAR(DateAdd),
    DATEPART(ISO_WEEK, DateAdd)
ORDER BY
    [Year],
    [Week];
GO
