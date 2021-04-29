DECLARE @DomainSQLSysAdminGroup VARCHAR(255), @DomainSQLSysAdminGroupBU VARCHAR(255), @DomainSQLSysAdminGroupBUCG VARCHAR(255), @DomainSQLSysAdminGroupUS VARCHAR(255)
SET @DomainSQLSysAdminGroup = 'BYACCOUNT\Server-GDC.DB-Server'
SET @DomainSQLSysAdminGroupBU = 'BYACCOUNT\Server-GDC.Backup-Storage'
SET @DomainSQLSysAdminGroupBUCG = 'BYACCOUNT\Server-BDC.Backup-Storage.CG'
SET @DomainSQLSysAdminGroupUS = 'BAYER1\NA.BBTS.MSSQLDB.US'
DECLARE @NamedInstance bit
IF CAST(SERVERPROPERTY('ServerName') AS varchar) LIKE '%\%' SET @NamedInstance = 1 ELSE SET @NamedInstance = 0

DECLARE @SQLEngineServiceName varchar(100)
DECLARE @SQLAgentServiceName varchar(100)
DECLARE @SQLEngineServiceSID varchar(100)
DECLARE @SQLAgentServiceSID varchar(100)

IF @NamedInstance = 0
BEGIN
SET @SQLEngineServiceName = 'MSSQLSERVER'
SET @SQLAgentServiceName = 'SQLSERVERAGENT'
END
ELSE
BEGIN
SET @SQLEngineServiceName = 'MSSQL$' + RIGHT(CAST(SERVERPROPERTY('ServerName') AS varchar),LEN(CAST(SERVERPROPERTY('ServerName') AS varchar)) - CHARINDEX('\',CAST(SERVERPROPERTY('ServerName') AS varchar),1))
SET @SQLAgentServiceName = 'SQLAGENT$' + RIGHT(CAST(SERVERPROPERTY('ServerName') AS varchar),LEN(CAST(SERVERPROPERTY('ServerName') AS varchar)) - CHARINDEX('\',CAST(SERVERPROPERTY('ServerName') AS varchar),1))
END
SET @SQLEngineServiceSID = 'NT Service\' + @SQLEngineServiceName
SET @SQLAgentServiceSID =  'NT Service\' + @SQLAgentServiceName

DECLARE @KEY_VALUE varchar(255)
DECLARE @SQLEngineServiceAccountName varchar(255)
DECLARE @SQLAgentServiceAccountName varchar(255) 
DECLARE @SQLEngineGroup varchar(255)
DECLARE @SQLAgentGroup varchar(255)

SET @KEY_VALUE = 'SYSTEM\CurrentControlSet\Services\' + @SQLEngineServiceName
EXECUTE master..xp_regread 'HKEY_LOCAL_MACHINE', @KEY_VALUE, 'ObjectName', @SQLEngineServiceAccountName OUTPUT
SET @KEY_VALUE = 'SYSTEM\CurrentControlSet\Services\' + @SQLAgentServiceName
EXECUTE master..xp_regread 'HKEY_LOCAL_MACHINE', @KEY_VALUE, 'ObjectName', @SQLAgentServiceAccountName OUTPUT
EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',N'Software\Microsoft\MSSQLServer\Setup',N'SQLGroup', @SQLEngineGroup output
EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',N'Software\Microsoft\MSSQLServer\Setup',N'AGTGroup', @SQLAgentGroup output

DECLARE @SQLEngineGroupName varchar(255)
DECLARE @SQLAgentGroupName varchar(255)

DECLARE @oneInt BIGINT        
DECLARE @xStrSid VARCHAR(100)
DECLARE @xBinSid VARBINARY(100)         

SET @xStrSid = @SQLEngineGroup
SET @xBinSid = CAST(CAST(SUBSTRING(@xStrSid , 3,1) AS TINYINT) AS VARBINARY)        
SET @xBinSid = @xBinSid + 0x05        
SET @xBinSid = @xBinSid + CAST(CAST(SUBSTRING(@xStrSid , 5,1) AS TINYINT) AS BINARY(6))        
SET @xStrSid = SUBSTRING(@xStrSid,7,LEN(@xStrSid)-6)        
WHILE CHARINDEX('-',@xStrSid) > 0        
BEGIN                
	SET @oneInt = CAST(SUBSTRING(@xStrSid,1,CHARINDEX('-',@xStrSid)-1) AS BIGINT)                
	SET @xBinSid = @xBinSid + CAST(REVERSE(CAST(@oneInt AS VARBINARY)) AS VARBINARY(4))                
	SET @xStrSid = SUBSTRING(@xStrSid,CHARINDEX('-',@xStrSid)+1,LEN(@xStrSid))        
END        
SET @oneInt = CAST(@xStrSid AS BIGINT)        
SET @xBinSid = @xBinSid + CAST(REVERSE(CAST(@oneInt AS VARBINARY)) AS VARBINARY(4))
SET @SQLEngineGroupName = (SELECT name FROM sys.server_principals WHERE SID = @xBinSid)
SET @SQLEngineGroupName = ISNULL(@SQLEngineGroupName, '')

SET @xStrSid = @SQLAgentGroup
SET @xBinSid = CAST(CAST(SUBSTRING(@xStrSid , 3,1) AS TINYINT) AS VARBINARY)        
SET @xBinSid = @xBinSid + 0x05        
SET @xBinSid = @xBinSid + CAST(CAST(SUBSTRING(@xStrSid , 5,1) AS TINYINT) AS BINARY(6))        
SET @xStrSid = SUBSTRING(@xStrSid,7,LEN(@xStrSid)-6)        
WHILE CHARINDEX('-',@xStrSid) > 0        
BEGIN                
	SET @oneInt = CAST(SUBSTRING(@xStrSid,1,CHARINDEX('-',@xStrSid)-1) AS BIGINT)                
	SET @xBinSid = @xBinSid + CAST(REVERSE(CAST(@oneInt AS VARBINARY)) AS VARBINARY(4))                
	SET @xStrSid = SUBSTRING(@xStrSid,CHARINDEX('-',@xStrSid)+1,LEN(@xStrSid))        
END        
SET @oneInt = CAST(@xStrSid AS BIGINT)        
SET @xBinSid = @xBinSid + CAST(REVERSE(CAST(@oneInt AS VARBINARY)) AS VARBINARY(4))
SET @SQLAgentGroupName = (SELECT name FROM sys.server_principals WHERE SID = @xBinSid)
SET @SQLAgentGroupName = ISNULL(@SQLAgentGroupName, '')

SELECT  p.name AS [loginname] ,
        p.type ,
        p.type_desc ,
        p.is_disabled,
        CONVERT(VARCHAR(10),p.create_date ,101) AS [created],
        CONVERT(VARCHAR(10),p.modify_date , 101) AS [update]
FROM    sys.server_principals p
        JOIN sys.syslogins s ON p.sid = s.sid
WHERE   p.type_desc IN ('SQL_LOGIN', 'WINDOWS_LOGIN', 'WINDOWS_GROUP')
        -- Logins that are not process logins
        AND p.name NOT LIKE '##%'
		AND UPPER(p.name) NOT IN (
			UPPER('sa'), 
			UPPER('NT AUTHORITY\SYSTEM'), 
			UPPER('NT SERVICE\SQLWriter'), 
			UPPER('NT SERVICE\Winmgmt'), 
			UPPER('NT SERVICE\ClusSvc'), 
			UPPER(@SQLEngineServiceAccountName), 
			UPPER(@SQLAgentServiceAccountName), 
			UPPER(@SQLEngineGroupName), 
			UPPER(@SQLAgentGroupName), 
			UPPER(@SQLEngineServiceSID), 
			UPPER(@SQLAgentServiceSID), 
			UPPER(@DomainSQLSysAdminGroup), 
			UPPER(@DomainSQLSysAdminGroupBU), 
			UPPER(@DomainSQLSysAdminGroupBUCG), 
			UPPER(@DomainSQLSysAdminGroupUS)
			)
        -- Logins that are sysadmins
        AND s.sysadmin = 1
GO
