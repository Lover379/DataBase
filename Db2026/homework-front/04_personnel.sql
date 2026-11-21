
SELECT
    loginid AS EmployeeID,
    YEAR(dater) AS [Year],
    DATEPART(QUARTER, dater) AS [Quarter],
    COUNT(*) AS SalesPositions,
    COUNT(DISTINCT CAST(dater AS date)) AS WorkingDays,
    SUM(amount) AS SalesAmount
FROM journal
WHERE transtype = 101
  AND grouptranstype = 1
  AND status = 0
  AND flagrefund = 0
GROUP BY
    loginid,
    YEAR(dater),
    DATEPART(QUARTER, dater)
ORDER BY
    [Year],
    [Quarter],
    EmployeeID;
GO

SELECT
    loginid AS EmployeeID,
    YEAR(dater) AS [Year],
    CASE
        WHEN MONTH(dater) <= 6 THEN 1
        ELSE 2
    END AS [HalfYear],
    COUNT(*) AS SalesPositions,
    COUNT(DISTINCT CAST(dater AS date)) AS WorkingDays,
    SUM(amount) AS SalesAmount
FROM journal
WHERE transtype = 101
  AND grouptranstype = 1
  AND status = 0
  AND flagrefund = 0
GROUP BY
    loginid,
    YEAR(dater),
    CASE
        WHEN MONTH(dater) <= 6 THEN 1
        ELSE 2
    END
ORDER BY
    [Year],
    [HalfYear],
    EmployeeID;
GO
