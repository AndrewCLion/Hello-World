--CREATE PROC dbo.ShowOrphanUsers
--AS
--BEGIN
CREATE TABLE #Results
(
[Database Name] sysname COLLATE Latin1_General_CI_AS,
[Orphaned User] sysname COLLATE Latin1_General_CI_AS
)

SET NOCOUNT ON

DECLARE @DBName sysname, @Qry nvarchar(4000)

SET @Qry = ''
SET @DBName = ''

WHILE @DBName IS NOT NULL
BEGIN
SET @DBName =
(
SELECT MIN(name)
FROM master..sysdatabases
WHERE name NOT IN
(
'master', 'model', 'tempdb', 'msdb',
'distribution', 'pubs', 'northwind'
)
AND DATABASEPROPERTY(name, 'IsOffline') = 0
AND DATABASEPROPERTY(name, 'IsSuspect') = 0
AND name > @DBName
)

IF @DBName IS NULL BREAK

SET @Qry = ' SELECT ''' + @DBName + ''' AS [Database Name],
CAST(name AS sysname) COLLATE Latin1_General_CI_AS AS [Orphaned User]
FROM ' + QUOTENAME(@DBName) + '..sysusers su
WHERE su.islogin = 1
AND su.name <> ''guest''
AND NOT EXISTS
(
SELECT 1
FROM master..syslogins sl
WHERE su.sid = sl.sid
)'

INSERT INTO #Results EXEC (@Qry)
END

SELECT *
FROM #Results
ORDER BY [Database Name], [Orphaned User]
--END

DROP TABLE #Results