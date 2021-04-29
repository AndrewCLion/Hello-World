SET NOCOUNT ON

DECLARE @dbName sysname, @rc int
DECLARE @SQL nvarchar(4000)

SELECT name
INTO #db
FROM sys.databases d
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
	SET @SQL = N'BACKUP DATABASE [' + @dbName + N'] 
TO  DISK = N''' + @dbName + N'.BAK'' WITH  COPY_ONLY, NOFORMAT, NOINIT,  
NAME = N''' + @dbName + N'-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10
GO
BACKUP LOG [' + @dbName + N'] 
TO  DISK = N''' + @dbName + N'.TRN'' WITH  COPY_ONLY, NOFORMAT, NOINIT,  
NAME = N''' + @dbName + N'-LOG Backup'', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10
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