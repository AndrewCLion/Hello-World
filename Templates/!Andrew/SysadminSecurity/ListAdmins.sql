-- http://technet.microsoft.com/de-de/library/ms175892%28v=sql.105%29.aspx
/*
use [master]
GO
DECLARE @ThisLogin nvarchar(50), @ThisCommand nvarchar(1234)
SET @ThisLogin = N'BYACCOUNT\EQATF'

SET @ThisCommand = 'GRANT ALTER ANY LOGIN TO [' + @ThisLogin + ']'
EXECUTE (@ThisCommand)
SET @ThisCommand = 'sp_dropsrvrolemember @loginame = N''' + @ThisLogin + ''', @rolename = N''securityadmin'''
EXECUTE (@ThisCommand)
GO
*/
SELECT        name, dbname AS DBNAME, CASE l.sysadmin WHEN 1 THEN 'True' ELSE 'False' END AS SYSADMIN, 
                         CASE l.securityadmin WHEN 1 THEN 'True' ELSE 'False' END AS SECURITYADMIN, denylogin, isntname, isntgroup, isntuser, hasaccess
FROM            sys.syslogins AS l
WHERE     ( sid <> 1) AND (  (sysadmin = 1) OR
                         (securityadmin = 1) )
-------------
SELECT l.name,
l.dbname DBNAME,
CASE l.sysadmin
WHEN 1 then 'True' ELSE 'False' END SYSADMIN,
CASE l.securityadmin 
WHEN 1 then 'True' ELSE 'False' END SECURITYADMIN,
l.denylogin--,
--l.isntname,
--l.isntgroup,
--l.isntuser
FROM master.dbo.syslogins AS l
WHERE l.sid <> 1 AND (l.sysadmin = 1
OR l.securityadmin = 1); 
-------------
/* Returns too many, recurses through groups
SELECT    @@SERVERNAME As [Instancename],    name, IS_SRVROLEMEMBER('sysadmin', name) AS IsSysAdmin, IS_SRVROLEMEMBER('securityadmin', name) AS IsSecurityAdmin, is_disabled
FROM            sys.server_principals AS p
WHERE IS_SRVROLEMEMBER('sysadmin', name) = 1 OR IS_SRVROLEMEMBER('securityadmin', name) = 1
*/
-------------
/*
SELECT name, principal_id, type_desc, is_disabled,IS_SRVROLEMEMBER('sysadmin', name) as issysadmin , IS_SRVROLEMEMBER('securityadmin', name) as issecurityadmin,
       create_date, modify_date, default_database_name
FROM   sys.server_principals 
ORDER BY name
*/
/*
SELECT sp.name AS LoginName,sp.type_desc AS LoginType, sp.default_database_name AS DefaultDBName,slog.sysadmin AS SysAdmin,slog.securityadmin AS SecurityAdmin,slog.serveradmin AS ServerAdmin, slog.setupadmin AS SetupAdmin, slog.processadmin AS ProcessAdmin, slog.diskadmin AS DiskAdmin, slog.dbcreator AS DBCreator,slog.bulkadmin AS BulkAdmin
FROM sys.server_principals sp  JOIN master..syslogins slog
ON sp.sid=slog.sid 
WHERE (sp.name LIKE '%EVEJQ%' OR sp.name LIKE '%EVEGP%' )
--AND (slog.sysadmin <>0  OR slog.securityadmin <>0  OR slog.serveradmin <>0  OR slog.setupadmin <>0  OR slog.processadmin <>0  OR slog.diskadmin <>0  OR slog.dbcreator <>0  OR slog.bulkadmin <>0 )
*/