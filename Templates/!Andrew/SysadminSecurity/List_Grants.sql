DECLARE @GRANTOR VARCHAR(MAX)

SET @GRANTOR = 'EVE'

--SELECT	pe.permission_name, pe.state_desc, pr.name AS grantee, pr2.name AS grantor, sys.objects.name, sys.objects.type_desc
--FROM	sys.database_permissions AS pe LEFT OUTER JOIN
--		sys.objects ON pe.major_id = sys.objects.object_id LEFT OUTER JOIN
--		sys.database_principals AS pr2 ON pe.grantor_principal_id = pr2.principal_id LEFT OUTER JOIN
--		sys.database_principals AS pr ON pe.grantee_principal_id = pr.principal_id
--WHERE	(pe.type = 'EX')
--    AND (@GRANTOR IS NULL OR pe.grantor_principal_id LIKE @GRANTOR OR pr2.name IS NULL OR pe.grantor_principal_id <>1)

---- Replaces constructs such as:
---- EXEC sp_msforeachdb 'USE [?];select ''?'' DBName, * from sys.sysindexes where id = OBJECT_ID(''KODef'') and indid < 2'
--SET NOCOUNT ON
--    DECLARE @Table TABLE(
--            SPID INT,
--            Status VARCHAR(MAX),
--            LOGIN VARCHAR(MAX),
--            HostName VARCHAR(MAX),
--            BlkBy VARCHAR(MAX),
--            DBName VARCHAR(MAX),
--            Command VARCHAR(MAX),
--            CPUTime INT,
--            DiskIO INT,
--            LastBatch VARCHAR(MAX),
--            ProgramName VARCHAR(MAX),
--            SPID_1 INT,
--            REQUESTID INT
--    )

DECLARE @dbName sysname, @rc int
DECLARE @SQL nvarchar(4000)

SELECT name
INTO #db
FROM sys.databases
WHERE 
    --name NOT IN ('master', 'model', 'msdb', 'tempdb', 'Admin', 'OnePoint', 'distribution') AND
    --name NOT LIKE '%ReportServer%' AND
    DATABASEPROPERTYEX([name], 'IsInStandBy') = 0 AND
    DATABASEPROPERTYEX([name], 'Status') = 'ONLINE'

SELECT @rc = 1, @dbName = MIN(name)
FROM #db

WHILE @rc <> 0
BEGIN
    
	/* Insert Code here */
	SET @SQL = N'USE [' + @dbName + N'] ; ' 
	+ N'IF EXISTS (SELECT pe.permission_name
	FROM sys.database_permissions pe
    JOIN sys.database_principals pr
        ON pe.grantee_principal_id = pr.principal_Id
    JOIN sys.database_principals pr2
        ON pe.grantor_principal_id = pr2.principal_Id
	WHERE pe.type = ''EX''
	    AND (pr2.name LIKE ''%' + @GRANTOR + '%'' OR pr2.name IS NULL OR pe.grantor_principal_id <> 1) )'
	+ N'SELECT DB_NAME() AS [database]
    ,pe.permission_name
    ,pe.state_desc
    ,pr.name AS [grantee]
    ,pr2.name AS [grantor]
	FROM sys.database_permissions pe
    JOIN sys.database_principals pr
        ON pe.grantee_principal_id = pr.principal_Id
    JOIN sys.database_principals pr2
        ON pe.grantor_principal_id = pr2.principal_Id
	WHERE pe.type = ''EX''
	    AND (pr2.name LIKE ''%' + @GRANTOR + '%'' OR pr2.name IS NULL OR pe.grantor_principal_id <> 1)'

	PRINT @SQL
	EXEC sp_executesql @SQL

    SELECT TOP 1 @dbName = name
    FROM #db
    WHERE name > @dbName
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

DROP TABLE #db
GO