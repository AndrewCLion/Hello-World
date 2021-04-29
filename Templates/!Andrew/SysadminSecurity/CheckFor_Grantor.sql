-- Author: Andrew Craven 17.12.2014
-- Change value of @UserName to the one you are looking for
SET NOCOUNT ON

DECLARE @UserName NVARCHAR(64)
DECLARE @dbName sysname, @rc int
DECLARE @SQL nvarchar(4000)

SET @UserName = N'%EQZWL%'

SELECT	sys.server_permissions.class, sys.server_permissions.class_desc, sys.server_permissions.major_id, sys.server_permissions.minor_id, 
		sys.server_permissions.grantee_principal_id, sys.server_permissions.grantor_principal_id, sys.server_permissions.type, 
		sys.server_permissions.permission_name, sys.server_permissions.state, sys.server_permissions.state_desc, spee.name AS Grantee, spor.name AS Grantor
FROM	sys.server_permissions INNER JOIN
        sys.server_principals AS spee ON sys.server_permissions.grantee_principal_id = spee.principal_id INNER JOIN
        sys.server_principals AS spor ON sys.server_permissions.grantor_principal_id = spor.principal_id
WHERE spee.name LIKE @UserName OR spor.name LIKE @UserName

BEGIN TRY
	DROP TABLE #db
END TRY
BEGIN CATCH
	--Print 'Clean Start'
END CATCH

SELECT name
INTO #db
FROM sys.databases
--WHERE 
--    --name NOT IN ('master', 'model', 'msdb', 'tempdb', 'Admin', 'OnePoint', 'distribution') AND
--    name NOT IN ('master', 'model', 'msdb', 'tempdb', 'Admin', 'OnePoint', 'distribution') AND
--    name NOT LIKE '%ReportServer%' AND
--    --DATABASEPROPERTYEX([name], 'IsInStandBy') = 0 AND
--    DATABASEPROPERTYEX([name], 'Status') = 'ONLINE'

    DECLARE @Table TABLE(
            DBname VARCHAR(MAX),
            state_desc VARCHAR(MAX),
            [permission_name] VARCHAR(MAX),
            [Schema] VARCHAR(MAX),
            [name] VARCHAR(MAX),
            [type] VARCHAR(MAX),
            Grantor VARCHAR(MAX),
            Grantee VARCHAR(MAX)
    )

SELECT @rc = 1, @dbName = MIN(name)
FROM #db

WHILE @rc <> 0
BEGIN
    
	/* Insert Code here */
	SET @SQL = N'USE [' + @dbName + N'] ; ' + N'SELECT ''' + @dbName + N''' as DBname, SDP.state_desc, SDP.permission_name, SSU.name AS [Schema], SSO.name, SSO.type, SSUGrantor.name AS Grantor, SSUGrantee.name AS Grantee'
											+ N' FROM sys.sysobjects AS SSO INNER JOIN'
											+ N' sys.database_permissions AS SDP ON SSO.id = SDP.major_id INNER JOIN'
											+ N' sys.sysusers AS SSU ON SSO.uid = SSU.uid INNER JOIN'
											+ N' sys.sysusers AS SSUGrantor ON SDP.grantor_principal_id = SSUGrantor.uid INNER JOIN'
											+ N' sys.sysusers AS SSUGrantee ON SDP.grantee_principal_id = SSUGrantee.uid'
											--+ N' WHERE SSUGrantor.name LIKE ''BUILTIN%'' OR SSUGrantee.name LIKE ''BUILTIN%'''
											+ N' WHERE SSUGrantor.name LIKE ''' + @UserName + ''''
											--+ N' WHERE SSUGrantor.issqlrole = 0'
											+ N' ORDER BY [Schema], SSO.name'
	BEGIN TRY
	INSERT INTO @Table EXEC sp_executesql @SQL
	END TRY
	BEGIN CATCH
		print 'Database offline? :'		
		print @SQL		
	END CATCH

    SELECT TOP 1 @dbName = name
    FROM #db
    WHERE name > @dbName
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

SELECT * FROM @Table

DROP TABLE #db