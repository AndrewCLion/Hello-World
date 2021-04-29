USE master
SET NOCOUNT ON

DECLARE @dbName sysname, @rc int
DECLARE @SQL nvarchar(4000)

SELECT name
INTO #db
FROM sys.databases d
--FROM sys.databases d LEFT JOIN sys.syslogins l on d.owner_sid = l.sid
WHERE 
    d.[name] != 'master' AND
    --d.[name] NOT LIKE '%ReportServer%' AND
    d.[is_in_standby] = 0 AND
    d.[state_desc] = 'ONLINE'

SELECT DB_NAME() AS DBName, SUSER_SNAME(sdp.sid) AS dbo_owner, sys.syslogins.loginname AS File_owner, sdp.sid, d.owner_sid
INTO ##dbos
FROM   sys.syslogins INNER JOIN
       sys.databases AS d ON sys.syslogins.sid = d.owner_sid CROSS JOIN
       sys.database_principals AS sdp
WHERE  (sdp.name = 'dbo') AND (d.name = DB_NAME()) OR
       (sdp.principal_id = 1) AND (d.name = DB_NAME())

SELECT @rc = 1, @dbName = MIN(name)
FROM #db

WHILE @rc <> 0
BEGIN
    
	/* Insert Code here */
	SET @SQL = N'USE [' + @dbName + N'] ; ' + N'INSERT INTO ##dbos SELECT DB_NAME() AS DBName, SUSER_SNAME(sdp.sid) AS dbo_owner, sys.syslogins.loginname AS File_owner, sdp.sid, d.owner_sid
FROM   sys.syslogins INNER JOIN
       sys.databases AS d ON sys.syslogins.sid = d.owner_sid CROSS JOIN
       sys.database_principals AS sdp
WHERE  (sdp.name = ''dbo'') AND (d.name = DB_NAME()) OR
       (sdp.principal_id = 1) AND (d.name = DB_NAME())
'
	--print @SQL
	EXEC sp_executesql @SQL

    SELECT TOP 1 @dbName = name
    FROM #db
    WHERE name > @dbName
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

SELECT * FROM ##dbos

DROP TABLE ##dbos
DROP TABLE #db
