-- only usable from SQL Server 2008 and later
USE [master]
GO

DECLARE @ErrorDumpDir nvarchar(255)
DECLARE @SQL nvarchar(4000)

----- GET TCPIP Ports
EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
										,N'Software\Microsoft\MSSQLServer\CPE'
										,N'ErrorDumpDir', @ErrorDumpDir OUTPUT
--print @ErrorDumpDir

SET @SQL = 'EXEC master.dbo.xp_create_subdir ''' + @ErrorDumpDir + 'LoginAudits\Successful\' + '''
;
CREATE SERVER AUDIT [Audit_LoginsSuccessful]
TO FILE 
(	FILEPATH = ''' + @ErrorDumpDir + 'LoginAudits\Successful\' + '''
	,MAXSIZE = 100 MB
	,MAX_ROLLOVER_FILES = 10
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
	--,AUDIT_GUID = 12de9735-50ea-44ab-9e9f-70596fee1a55
)
;
CREATE SERVER AUDIT SPECIFICATION [Audit_LoginsSuccessful]
FOR SERVER AUDIT [Audit_LoginsSuccessful]
ADD (SUCCESSFUL_LOGIN_GROUP)
WITH (STATE = OFF)
;
ALTER SERVER AUDIT [Audit_LoginsSuccessful]
WITH (STATE = ON)
;
ALTER SERVER AUDIT SPECIFICATION [Audit_LoginsSuccessful]
WITH (STATE = ON)
;
'

print @SQL
--EXEC (@SQL)

SET @SQL = 'EXEC master.dbo.xp_create_subdir ''' + @ErrorDumpDir + 'LoginAudits\Failed\' + '''
;
CREATE SERVER AUDIT [Audit_LoginsFailed]
TO FILE 
(	FILEPATH = ''' + @ErrorDumpDir + 'LoginAudits\Failed\' + '''
	,MAXSIZE = 100 MB
	,MAX_ROLLOVER_FILES = 10
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
	--,AUDIT_GUID = 12de9735-50ea-44ab-9e9f-70596fee1a55
)
;
CREATE SERVER AUDIT SPECIFICATION [Audit_LoginsFailed]
FOR SERVER AUDIT [Audit_LoginsFailed]
ADD (FAILED_LOGIN_GROUP)
WITH (STATE = OFF)
;
ALTER SERVER AUDIT [Audit_LoginsFailed]
WITH (STATE = ON)
;
ALTER SERVER AUDIT SPECIFICATION [Audit_LoginsFailed]
WITH (STATE = ON)
;
'

print @SQL
--EXEC (@SQL)
GO
