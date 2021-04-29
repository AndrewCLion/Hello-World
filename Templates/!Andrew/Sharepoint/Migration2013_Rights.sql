USE [master]
GO
CREATE LOGIN [BYACCOUNT\SPD03FRD] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO
ALTER SERVER ROLE [dbcreator] ADD MEMBER [BYACCOUNT\SPD03FRD]
GO
ALTER SERVER ROLE [securityadmin] ADD MEMBER [BYACCOUNT\SPD03FRD]
GO
CREATE LOGIN [BYACCOUNT\SPD03APD] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO
CREATE LOGIN [BYACCOUNT\SPD03SPD] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO
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
    
	--/* Insert Code here */
	--SET @SQL = N'USE [' + @dbName + N'] ; CREATE USER [BYACCOUNT\SPD03FRD] FOR LOGIN [BYACCOUNT\SPD03FRD] ; ALTER ROLE [db_owner] ADD MEMBER [BYACCOUNT\SPD03FRD];'
	---- e.g. 	SET @SQL = N'USE [' + @dbName + N'] ; ' + N'CREATE USER [BYACCOUNT\IMXOK] FOR LOGIN [BYACCOUNT\IMXOK]; EXEC sp_addrolemember N''db_owner'', N''BYACCOUNT\IMXOK'''

	----print @SQL
	--EXEC sp_executesql @SQL

	SET @SQL = N'USE [' + @dbName + N'] ; CREATE USER [BYACCOUNT\SPD03APD] FOR LOGIN [BYACCOUNT\SPD03APD] ; ALTER ROLE [db_owner] ADD MEMBER [BYACCOUNT\SPD03APD];'
	-- e.g. 	SET @SQL = N'USE [' + @dbName + N'] ; ' + N'CREATE USER [BYACCOUNT\IMXOK] FOR LOGIN [BYACCOUNT\IMXOK]; EXEC sp_addrolemember N''db_owner'', N''BYACCOUNT\IMXOK'''

	--print @SQL
	EXEC sp_executesql @SQL

	SET @SQL = N'USE [' + @dbName + N'] ; CREATE USER [BYACCOUNT\SPD03SPD] FOR LOGIN [BYACCOUNT\SPD03SPD] ; ALTER ROLE [db_owner] ADD MEMBER [BYACCOUNT\SPD03SPD];'
	-- e.g. 	SET @SQL = N'USE [' + @dbName + N'] ; ' + N'CREATE USER [BYACCOUNT\IMXOK] FOR LOGIN [BYACCOUNT\IMXOK]; EXEC sp_addrolemember N''db_owner'', N''BYACCOUNT\IMXOK'''

	--print @SQL
	EXEC sp_executesql @SQL

    SELECT TOP 1 @dbName = name
    FROM #db
    WHERE name > @dbName
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

DROP TABLE #db