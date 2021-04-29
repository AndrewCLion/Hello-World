-- Replaces constructsd such as:
-- EXEC sp_msforeachdb 'USE [?];select ''?'' DBName, * from sys.sysindexes where id = OBJECT_ID(''KODef'') and indid < 2'
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

SELECT @rc = 1, @dbName = MIN(name)
FROM #db

WHILE @rc <> 0
BEGIN
    
	/* Insert Code here */
	SET @SQL = N'USE [' + @dbName + N'] ; ' + N'SELECT TOP 1 * FROM sys.schemas;'
	-- e.g. 	SET @SQL = N'USE [' + @dbName + N'] ; ' + N'CREATE USER [BYACCOUNT\IMXOK] FOR LOGIN [BYACCOUNT\IMXOK]; EXEC sp_addrolemember N''db_owner'', N''BYACCOUNT\IMXOK'''

	print @SQL
	--EXEC sp_executesql @SQL

    SELECT TOP 1 @dbName = name
    FROM #db
    WHERE name > @dbName
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

DROP TABLE #db