DECLARE @TSQL  NVARCHAR(2000)
DECLARE @lC    INT

CREATE TABLE #TempLog (
      LogDate     DATETIME,
      ProcessInfo NVARCHAR(50),
      [Text] NVARCHAR(MAX)
)

CREATE TABLE #logF (
      ArchiveNumber     INT,
      LogDate           DATETIME,
      LogSize           INT
)

INSERT INTO #logF   

EXEC sp_enumerrorlogs

SELECT @lC = MIN(ArchiveNumber) FROM #logF

WHILE @lC IS NOT NULL
BEGIN
      INSERT INTO #TempLog
      EXEC sp_readerrorlog @lC
      SELECT @lC = MIN(ArchiveNumber) FROM #logF 
      WHERE ArchiveNumber > @lC
END

--Failed login counts. Useful for security audits.
SELECT 'Failed - ' + CONVERT(nvarchar(5), COUNT(Text)) + ' attempts' AS [Login Attempt], Text AS Details
FROM #TempLog 
where ProcessInfo = 'Logon' 
and Text like '%failed%'
Group by Text

--Find Last Successful login. Useful to know before deleting "obsolete" accounts.
SELECT Distinct 'Successful - Last login at (' + CONVERT(nvarchar(64), MAX(LogDate)) + ')' AS [Login Attempt], Text AS Details
FROM #TempLog 
where ProcessInfo = 'Logon' and Text like '%succeeded%'
and Text not like '%NT AUTHORITY%'
Group by Text

DROP TABLE #TempLog
DROP TABLE #logF