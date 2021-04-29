--/**************************************************************/
--/* Procedure to call sp_help_revlogin for each database  		*/
--/*           and to generate commands for server roles 		*/
--/*															*/
--/* Changes:													*/
--/*															*/
--/* 04.08.2015	Andrew Craven	V1.0		Original Version	*/
--/*															*/		
--/**************************************************************/
SET NOCOUNT ON

SELECT name, isntname, sysadmin, securityadmin, serveradmin, setupadmin, processadmin, diskadmin, dbcreator, bulkadmin
INTO   #Lins
FROM   sys.syslogins;

TRUNCATE TABLE #Lins;

DECLARE @dbName sysname, @rc int
DECLARE @SQL nvarchar(4000)

DECLARE @login nvarchar(50)
 
SELECT name
INTO #db
FROM sys.databases d
--FROM sys.databases d LEFT JOIN sys.syslogins l on d.owner_sid = l.sid
WHERE 
    d.[name] != 'master' AND
    --d.[name] NOT IN ('master', 'model', 'msdb', 'tempdb', 'Admin', 'OnePoint', 'distribution') AND
    --d.[name] NOT LIKE '%ReportServer%' AND
    d.[is_in_standby] = 0 AND
    d.[state_desc] = 'ONLINE'

SELECT @rc = 1, @dbName = MIN(name)
FROM #db

WHILE @rc <> 0
BEGIN
    
	/* Insert Code here */
	SET @SQL = N'INSERT INTO #Lins (name, isntname, sysadmin, securityadmin, serveradmin, setupadmin, processadmin, diskadmin, dbcreator, bulkadmin)
	SELECT l.name, l.isntname, l.sysadmin, l.securityadmin, l.serveradmin, l.setupadmin, l.processadmin, l.diskadmin, l.dbcreator, l.bulkadmin
	FROM  [' + @dbName + N'].sys.database_principals u INNER  JOIN sys.syslogins l ON u.sid=l.sid WHERE l.name NOT LIKE ''##%'';'
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

SELECT DISTINCT name, isntname, sysadmin FROM #Lins 

print '
---------------------------------------- SQL logins ------------------------------------'
SET @login = NULL
SELECT @rc = 1, @login = MIN(name)
FROM #Lins
WHERE isntname=0

IF @login IS NULL
	print '-- none --'

WHILE @rc <> 0
BEGIN
    
	EXEC sp_help_revlogin  @login

    SELECT TOP 1 @login = name
    FROM #Lins
    WHERE name > @login AND isntname=0
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

print '
---------------------------------------- Windows users ------------------------------------'
SET @login = NULL
SELECT @rc = 1, @login = MIN(name)
FROM #Lins
WHERE isntname=1

IF @login IS NULL
	print '-- none --'

WHILE @rc <> 0
BEGIN
    
	EXEC sp_help_revlogin  @login

    SELECT TOP 1 @login = name
    FROM #Lins
    WHERE name > @login AND isntname=1
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

print '
---------------------------------------- sysadmin ------------------------------------'
SET @login = NULL
SELECT @rc = 1, @login = MIN(name)
FROM #Lins
WHERE sysadmin=1

IF @login IS NULL
	print '-- none --'

WHILE @rc <> 0
BEGIN
    
	SET @SQL = N'EXEC master..sp_addsrvrolemember @loginame = N''' + @login + N''', @rolename = N''sysadmin'''

	print @SQL

    SELECT TOP 1 @login = name
    FROM #Lins
    WHERE name > @login AND sysadmin=1
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

print '
---------------------------------------- securityadmin ------------------------------------'
SET @login = NULL
SELECT @rc = 1, @login = MIN(name)
FROM #Lins
WHERE securityadmin=1

IF @login IS NULL
	print '-- none --'

WHILE @rc <> 0
BEGIN
    
	SET @SQL = N'EXEC master..sp_addsrvrolemember @loginame = N''' + @login + N''', @rolename = N''securityadmin'''

	print @SQL

    SELECT TOP 1 @login = name
    FROM #Lins
    WHERE name > @login AND securityadmin=1
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

print '
---------------------------------------- serveradmin ------------------------------------'
SET @login = NULL
SET @login = NULL
SELECT @rc = 1, @login = MIN(name)
FROM #Lins
WHERE serveradmin=1

IF @login IS NULL
	print '-- none --'

WHILE @rc <> 0
BEGIN
    
	SET @SQL = N'EXEC master..sp_addsrvrolemember @loginame = N''' + @login + N''', @rolename = N''serveradmin'''

	print @SQL

    SELECT TOP 1 @login = name
    FROM #Lins
    WHERE name > @login AND serveradmin=1
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

print '
---------------------------------------- setupadmin ------------------------------------'
SET @login = NULL
SELECT @rc = 1, @login = MIN(name)
FROM #Lins
WHERE setupadmin=1

IF @login IS NULL
	print '-- none --'

WHILE @rc <> 0
BEGIN
    
	SET @SQL = N'EXEC master..sp_addsrvrolemember @loginame = N''' + @login + N''', @rolename = N''setupadmin'''

	print @SQL

    SELECT TOP 1 @login = name
    FROM #Lins
    WHERE name > @login AND setupadmin=1
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

print '
---------------------------------------- processadmin ------------------------------------'
SET @login = NULL
SELECT @rc = 1, @login = MIN(name)
FROM #Lins
WHERE processadmin=1

IF @login IS NULL
	print '-- none --'

WHILE @rc <> 0
BEGIN
    
	SET @SQL = N'EXEC master..sp_addsrvrolemember @loginame = N''' + @login + N''', @rolename = N''processadmin'''

	print @SQL

    SELECT TOP 1 @login = name
    FROM #Lins
    WHERE name > @login AND processadmin=1
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

print '
---------------------------------------- diskadmin ------------------------------------'
SET @login = NULL
SELECT @rc = 1, @login = MIN(name)
FROM #Lins
WHERE diskadmin=1

IF @login IS NULL
	print '-- none --'

WHILE @rc <> 0
BEGIN
    
	SET @SQL = N'EXEC master..sp_addsrvrolemember @loginame = N''' + @login + N''', @rolename = N''diskadmin'''

	print @SQL

    SELECT TOP 1 @login = name
    FROM #Lins
    WHERE name > @login AND diskadmin=1
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

print '
---------------------------------------- dbcreator ------------------------------------'
SET @login = NULL
SELECT @rc = 1, @login = MIN(name)
FROM #Lins
WHERE dbcreator=1

IF @login IS NULL
	print '-- none --'

WHILE @rc <> 0
BEGIN
    
	SET @SQL = N'EXEC master..sp_addsrvrolemember @loginame = N''' + @login + N''', @rolename = N''dbcreator'''

	print @SQL

    SELECT TOP 1 @login = name
    FROM #Lins
    WHERE name > @login AND dbcreator=1
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

print '
---------------------------------------- bulkadmin ------------------------------------'
SET @login = NULL
SELECT @rc = 1, @login = MIN(name)
FROM #Lins
WHERE bulkadmin=1

IF @login IS NULL
	print '-- none --'

WHILE @rc <> 0
BEGIN
    
	SET @SQL = N'EXEC master..sp_addsrvrolemember @loginame = N''' + @login + N''', @rolename = N''bulkadmin'''

	print @SQL

    SELECT TOP 1 @login = name
    FROM #Lins
    WHERE name > @login AND bulkadmin=1
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

DROP TABLE #Lins 

--name, isntname, sysadmin, securityadmin, serveradmin, setupadmin, processadmin, diskadmin, dbcreator, bulkadmin
--DROP TABLE #Lins
--EXEC master..sp_addsrvrolemember @loginame = N'byaccount\mygwt', @rolename = N'securityadmin'

