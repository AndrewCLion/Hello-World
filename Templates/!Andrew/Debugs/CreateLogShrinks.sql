--will create a script which creates a script to srink the first Log file found in each user database.
SET NOCOUNT ON

DECLARE @dbName sysname, @rc int
DECLARE @SQL nvarchar(4000)

SELECT name
INTO #db
FROM sys.databases
WHERE 
    name NOT IN ('master', 'model', 'msdb', 'tempdb', 'Admin', 'OnePoint', 'distribution') AND
    --name NOT LIKE '%ReportServer%' AND
    DATABASEPROPERTYEX([name], 'IsInStandBy') = 0 AND
    DATABASEPROPERTYEX([name], 'Status') = 'ONLINE'

SELECT @rc = 1, @dbName = MIN(name)
FROM #db

WHILE @rc <> 0
BEGIN
    
	/* Insert Code here */
	SET @SQL = N'USE [' + @dbName + N'] 
	DECLARE @logname nvarchar(4000)
	SELECT TOP 1 @logname = name FROM sys.database_files WHERE type = 1;
	SET @logname = ''USE [' + @dbName + N']
	DBCC SHRINKFILE (N'''''' + @logname + '''''' , 4000)
	GO''
	print @logname
	GO'
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

