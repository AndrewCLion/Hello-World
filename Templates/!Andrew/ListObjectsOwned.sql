DECLARE @Login as SYSNAME
SET @Login = N'BUILTIN\Administrators'
/*
Display all objects in all DBs owned by the Login.

2008-07-06 RBarryYoung Created.

Test:
spLogin_OwnedObjects 'sa'
*/
DECLARE @sql VARCHAR(MAX), @DB_Objects VARCHAR(512)
SELECT @DB_Objects = ' L.name AS [Login], U.Name AS [User], O.*
FROM %D%.sys.objects o
JOIN %D%.sys.database_principals u
ON Coalesce(o.principal_id, (SELECT S.Principal_ID FROM %D%.sys.schemas S WHERE S.Schema_ID = O.schema_id))
= U.principal_id
LEFT JOIN %D%.sys.server_principals L ON L.sid = u.sid
'

SELECT @sql = 'SELECT * FROM
(SELECT '+Cast(database_id as varchar(9))+' AS DBID, ''master'' AS DBName, '
+ Replace(@DB_objects, '%D%', [name])
FROM master.sys.databases
WHERE [name] = 'master'

SELECT @sql = @sql + 'UNION ALL SELECT '+Cast(database_id AS VARCHAR(9))+', '''+[name]+''', '
+ Replace(@DB_objects, '%D%', [name])
FROM master.sys.databases
WHERE [name] != 'master'

SELECT @sql = @sql + ') oo WHERE [Login] LIKE ''' + @Login + ''''

--print @sql
EXEC (@sql)