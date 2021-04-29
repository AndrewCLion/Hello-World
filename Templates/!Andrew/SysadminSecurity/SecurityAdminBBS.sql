--08.10.2014: Andrew Craven (EOAMF) - corrected and activated SecurityAdminBBS creation
USE [master];
DECLARE @command NVARCHAR(MAX);
IF CONVERT(float,CONVERT(varchar(4),SERVERPROPERTY('ProductVersion'))) >= 11
BEGIN
	IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'SecurityAdminBBS' AND type = 'R')
		BEGIN
		SET @command = 'CREATE SERVER ROLE [SecurityAdminBBS] AUTHORIZATION [BYACCOUNT\Server-GDC.DB-Server]';
		EXECUTE(@command);
		END
	GRANT CONNECT SQL TO SecurityAdminBBS			WITH GRANT OPTION AS [sa];
	GRANT ALTER ANY LOGIN to SecurityAdminBBS		WITH GRANT OPTION AS [sa];
	GRANT VIEW ANY DATABASE TO SecurityAdminBBS		WITH GRANT OPTION AS [sa];
	GRANT VIEW ANY DEFINITION TO SecurityAdminBBS	WITH GRANT OPTION AS [sa];
	GRANT VIEW SERVER STATE to SecurityAdminBBS		WITH GRANT OPTION AS [sa];
	--May be necessary for logins/groups:
	--GRANT EXECUTE ON OBJECT::[sys].[xp_readerrorlog] TO []
	--GRANT EXECUTE ON OBJECT::[sys].[sp_addlinkedserver] TO []
	--GRANT EXECUTE ON OBJECT::[sys].[sp_addlogin] TO []
	--GRANT EXECUTE ON OBJECT::[sys].[sp_defaultdb] TO []
	--GRANT EXECUTE ON OBJECT::[sys].[sp_defaultlanguage] TO []
	--GRANT EXECUTE ON OBJECT::[sys].[sp_denylogin] TO []
	--GRANT EXECUTE ON OBJECT::[sys].[sp_droplinkedsrvlogin] TO []
	--GRANT EXECUTE ON OBJECT::[sys].[sp_droplogin] TO []
	--GRANT EXECUTE ON OBJECT::[sys].[sp_dropremotelogin] TO []
	--GRANT EXECUTE ON OBJECT::[sys].[sp_grantlogin] TO []
	--GRANT EXECUTE ON OBJECT::[sys].[sp_helplogins] TO []
	--GRANT EXECUTE ON OBJECT::[sys].[sp_password] TO []
	--??--GRANT EXECUTE ON OBJECT::[sys].[sp_remoteoption (update)] TO []
	--GRANT EXECUTE ON OBJECT::[sys].[sp_revokelogin] TO []
	PRINT 'SecurityAdminBBS angelegt, diese Rolle statt Securityadmin vergeben';
END
ELSE 
BEGIN
	PRINT 'Achtung, SecurityAdminBBS konnte nicht angelegt werden (pre 2012)';
END;

GO
--sp_srvrolepermission
--sp_srvrolepermission 'dbcreator'
--sp_srvrolepermission 'securityadmin'
--sp_srvrolepermission 'sysadmin'
--sp_dbfixedrolepermission [[@rolename =] 'role']

--USE [master]
--GO
--IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'db_securityadminBBS' AND type = 'R')
--CREATE ROLE [db_securityadminBBS] AUTHORIZATION [dbo]
--GO
