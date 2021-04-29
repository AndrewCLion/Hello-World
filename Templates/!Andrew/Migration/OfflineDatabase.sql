-- *single* DBs
--ALTER DATABASE [] SET OFFLINE
--ALTER DATABASE [] SET OFFLINE WITH NO_WAIT
--ALTER DATABASE [] SET OFFLINE WITH ROLLBACK IMMEDIATE
--ALTER DATABASE [] SET OFFLINE WITH ROLLBACK AFTER 120 SECONDS
--ALTER DATABASE [] SET ONLINE

-- *all* DBs
SET NOCOUNT ON

DECLARE @dbName sysname, @rc int
DECLARE @SQL nvarchar(4000)

SELECT name
INTO #db
FROM sys.databases
WHERE 
    name NOT IN ('master', 'model', 'msdb', 'tempdb', 'Admin', 'OnePoint', 'distribution') AND
    name NOT LIKE '%%' AND
    DATABASEPROPERTYEX([name], 'IsInStandBy') = 0 AND
    DATABASEPROPERTYEX([name], 'Status') = 'ONLINE'

SELECT @rc = 1, @dbName = MIN(name)
FROM #db

WHILE @rc <> 0
BEGIN
    
	/* Insert Code here */
	SET @SQL = N'ALTER DATABASE [' + @dbName + N'] SET OFFLINE WITH NO_WAIT'
	--SET @SQL = N'ALTER DATABASE [' + @dbName + N'] SET OFFLINE WITH ROLLBACK IMMEDIATE'

	EXEC sp_executesql @SQL

    SELECT TOP 1 @dbName = name
    FROM #db
    WHERE name > @dbName
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

DROP TABLE #db