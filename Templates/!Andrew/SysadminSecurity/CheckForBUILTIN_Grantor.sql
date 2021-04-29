-- Replaces constructsd such as:
-- EXEC sp_msforeachdb 'USE [?];select ''?'' DBName, * from sys.sysindexes where id = OBJECT_ID(''KODef'') and indid < 2'
SET NOCOUNT ON

DECLARE @dbName sysname, @rc int
DECLARE @SQL nvarchar(4000)

SELECT name
INTO #db
FROM sys.databases
WHERE 
    name NOT IN ('master', 'model', 'msdb', 'tempdb', 'Admin', 'OnePoint', 'distribution') AND
    name NOT LIKE '%ReportServer%' AND
    --DATABASEPROPERTYEX([name], 'IsInStandBy') = 0 AND
    DATABASEPROPERTYEX([name], 'Status') = 'ONLINE'

SELECT @rc = 1, @dbName = MIN(name)
FROM #db

WHILE @rc <> 0
BEGIN
    
	/* Insert Code here */
	SET @SQL = N'USE [' + @dbName + N'] ; ' + N'SELECT ''' + @dbName + N''' as DBname, SDP.state_desc, SDP.permission_name, SSU.name AS [Schema], SSO.name, SSO.type, SSUGrantor.name AS Grantor, SSUGrantee.name AS Grantee'
											+ N' FROM sys.sysobjects AS SSO INNER JOIN'
											+ N' sys.database_permissions AS SDP ON SSO.id = SDP.major_id INNER JOIN'
											+ N' sys.sysusers AS SSU ON SSO.uid = SSU.uid INNER JOIN'
											+ N' sys.sysusers AS SSUGrantor ON SDP.grantee_principal_id = SSUGrantor.uid INNER JOIN'
											+ N' sys.sysusers AS SSUGrantee ON SDP.grantor_principal_id = SSUGrantee.uid'
											+ N' WHERE SSUGrantor.name LIKE ''BUILTIN%'' OR SSUGrantee.name LIKE ''BUILTIN%'''
											--+ N' WHERE SSUGrantor.issqlrole = 0'
											+ N' ORDER BY [Schema], SSO.name'
	EXEC sp_executesql @SQL

    SELECT TOP 1 @dbName = name
    FROM #db
    WHERE name > @dbName
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

DROP TABLE #db