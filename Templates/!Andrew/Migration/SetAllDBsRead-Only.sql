SET NOCOUNT ON

DECLARE @dbName sysname, @rc int
DECLARE @SQL nvarchar(4000)

DECLARE @DoPrint bit = 1
DECLARE @DoEXEC bit = 0

SELECT name
INTO #db
FROM sys.databases d
--FROM sys.databases d LEFT JOIN sys.syslogins l on d.owner_sid = l.sid
WHERE 
    d.[name] NOT IN ('master', 'model', 'msdb', 'tempdb', 'Admin', 'OnePoint', 'distribution') AND
    --d.[name] NOT LIKE '%ReportServer%' AND
    d.[is_in_standby] = 0 AND
    d.[state_desc] = 'ONLINE' AND
	d.is_read_only = 0

SELECT @rc = 1, @dbName = MIN(name)
FROM #db

WHILE @rc <> 0
BEGIN
    
	/* Insert Code here */
	SET @SQL = N'ALTER DATABASE [' + @dbName + N'] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE ;'
	-- e.g. 	SET @SQL = N'USE [' + @dbName + N'] ; ' + N'CREATE USER [BYACCOUNT\IMXOK] FOR LOGIN [BYACCOUNT\IMXOK]; EXEC sp_addrolemember N''db_owner'', N''BYACCOUNT\IMXOK'''

	IF @DoPrint = 1
		print @SQL
	IF @DoEXEC = 1
		EXEC sp_executesql @SQL

	/* Insert Code here */
	SET @SQL = N'ALTER DATABASE [' + @dbName + N'] SET  READ_ONLY WITH NO_WAIT ;'
	-- e.g. 	SET @SQL = N'USE [' + @dbName + N'] ; ' + N'CREATE USER [BYACCOUNT\IMXOK] FOR LOGIN [BYACCOUNT\IMXOK]; EXEC sp_addrolemember N''db_owner'', N''BYACCOUNT\IMXOK'''

	IF @DoPrint = 1
		print @SQL
	IF @DoEXEC = 1
		EXEC sp_executesql @SQL

	/* Insert Code here */
	SET @SQL = N'ALTER DATABASE [' + @dbName + N'] SET  MULTI_USER ;'
	-- e.g. 	SET @SQL = N'USE [' + @dbName + N'] ; ' + N'CREATE USER [BYACCOUNT\IMXOK] FOR LOGIN [BYACCOUNT\IMXOK]; EXEC sp_addrolemember N''db_owner'', N''BYACCOUNT\IMXOK'''

	IF @DoPrint = 1
		print @SQL
	IF @DoEXEC = 1
		EXEC sp_executesql @SQL

    SELECT TOP 1 @dbName = name
    FROM #db
    WHERE name > @dbName
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

DROP TABLE #db