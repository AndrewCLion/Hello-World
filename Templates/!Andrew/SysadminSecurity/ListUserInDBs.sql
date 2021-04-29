SET NOCOUNT ON

DECLARE @dbName sysname, @rc int
DECLARE @SQL nvarchar(4000)

SELECT name
INTO #db
FROM sys.databases d
--FROM sys.databases d LEFT JOIN sys.syslogins l on d.owner_sid = l.sid
WHERE 
    d.[name] NOT IN ('master', 'model', 'msdb', 'tempdb', 'Admin', 'OnePoint', 'distribution') AND
    --d.[name] NOT LIKE '%ReportServer%' AND
    d.[is_in_standby] = 0 AND
    d.[state_desc] = 'ONLINE'

SELECT CAST('' AS nvarchar(254)) AS DBName, * INTO #un FROM sys.database_principals WHERE [name] LIKE 'XXX%'

SELECT @rc = 1, @dbName = MIN(name)
FROM #db

WHILE @rc <> 0
BEGIN
    
	/* Insert Code here */
	SET @SQL = N'USE [' + @dbName + N'] ; ' + N'INSERT INTO #un SELECT ''' + @dbName + N''' AS DBName, * FROM sys.database_principals WHERE [name] LIKE ''BYACCOUNT\%'';'

	--print @SQL
	EXEC sp_executesql @SQL

    SELECT TOP 1 @dbName = name
    FROM #db
    WHERE name > @dbName
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

SELECT * FROM #un ORDER BY DBName, name

DROP TABLE #un
DROP TABLE #db