-- replaces sp_changedbowner
SET NOCOUNT ON

DECLARE @dbName sysname, @lName sysname, @rc int
DECLARE @SQL nvarchar(4000)

SELECT d.name as dbname, ISNULL(l.name, SUSER_SNAME(d.owner_sid)) as lname
INTO #db
FROM sys.databases d LEFT JOIN sys.syslogins l on d.owner_sid = l.sid
WHERE 
    d.name NOT IN ('master', 'model', 'msdb', 'tempdb', 'Admin', 'OnePoint', 'distribution') AND
    --name LIKE '%EMMY%' AND
    --name NOT LIKE '%ReportServer%' AND
    d.[is_in_standby] = 0 AND
    d.[state_desc] = 'ONLINE' AND
	ISNULL(l.[name],'') <> 'sa'

SELECT @rc = 1, @dbName = MIN(dbname)
FROM #db

WHILE @rc <> 0
BEGIN
    
	SELECT @rc = 1, @lName = lname
	FROM #db
	WHERE dbname LIKE @dbName
	/* Insert Code here */
	SET @SQL = N'ALTER AUTHORIZATION ON DATABASE::[' + @dbName + N'] TO [sa]; -- was ' + @lName

	
	print @SQL
	--EXEC sp_executesql @SQL

    SELECT TOP 1 @dbName = dbname
    FROM #db
    WHERE dbname > @dbName
    ORDER BY dbname

    SET @rc = @@ROWCOUNT
END

DROP TABLE #db
