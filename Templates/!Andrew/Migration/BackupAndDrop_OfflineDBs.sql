-- Note that the routine only generates a script, which then will be copied and pasted and run in a new Query window
SET NOCOUNT ON

DECLARE @Share nvarchar(400)
SET @Share = N'\\by-cs159120\W2K3Exit-SQL-DB\'

DECLARE @MachineName nvarchar(400)
SET @MachineName = CAST(SERVERPROPERTY('MachineName') AS nvarchar(400)) + N'\'

DECLARE @dbName sysname, @rc int
DECLARE @SQL nvarchar(4000)

SET @SQL= N'-- MKDIR "' + @Share + @MachineName + N'"'
print @SQL

SELECT name
INTO #db
FROM sys.databases
WHERE 
    name NOT IN ('master', 'model', 'msdb', 'tempdb', 'Admin', 'OnePoint', 'distribution') AND
    --name NOT LIKE '%ReportServer%' AND
    DATABASEPROPERTYEX([name], 'IsInStandBy') = 0 AND
    DATABASEPROPERTYEX([name], 'Status') = 'OFFLINE'

SELECT @rc = 1, @dbName = MIN(name)
FROM #db

WHILE @rc <> 0
BEGIN
    
	/* Insert Code here */
	SET @SQL = N'ALTER DATABASE [' + @dbName + N'] SET ONLINE
	GO
	BACKUP DATABASE [' + @dbName + N'] TO  DISK = N''' + @Share + @MachineName + @dbName + N'.BAK''
	WITH  COPY_ONLY, NOFORMAT, NOINIT,  NAME = N''' + @dbName + N'-Vollständig letztmalige Datenbank Sichern'', SKIP, NOREWIND, NOUNLOAD,  STATS = 5
	GO
	ALTER DATABASE [' + @dbName + N'] SET OFFLINE
	--DROP DATABASE [' + @dbName + N']
	GO
'

	print @SQL
	--EXEC sp_executesql @SQL

    SELECT TOP 1 @dbName = name
    FROM #db
    WHERE name > @dbName
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

DROP TABLE #db

	SET @SQL = N'BACKUP DATABASE [master] TO  DISK = N''' + @Share + @MachineName + N'master.BAK''
	WITH  COPY_ONLY, NOFORMAT, NOINIT,  NAME = N''master-Vollständig letztmalige Datenbank Sichern'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
	GO
'
	print @SQL

	SET @SQL = N'BACKUP DATABASE [model] TO  DISK = N''' + @Share + @MachineName + N'model.BAK''
	WITH  COPY_ONLY, NOFORMAT, NOINIT,  NAME = N''model-Vollständig letztmalige Datenbank Sichern'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
	GO
'
	print @SQL

	SET @SQL = N'BACKUP DATABASE [msdb] TO  DISK = N''' + @Share + @MachineName + N'msdb.BAK''
	WITH  COPY_ONLY, NOFORMAT, NOINIT,  NAME = N''msdb-Vollständig letztmalige Datenbank Sichern'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
	GO
'
	print @SQL
