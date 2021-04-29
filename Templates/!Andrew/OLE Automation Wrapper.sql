USE master
GO

DECLARE @chkOleAutomationProcedures AS SQL_VARIANT
DECLARE @chkAdvOptions AS SQL_VARIANT

SELECT @chkOleAutomationProcedures = value FROM sys.configurations WHERE name LIKE 'Ole Automation Procedures'
SELECT @chkAdvOptions = value FROM sys.configurations WHERE name LIKE 'show advanced options'

SELECT @chkAdvOptions AS AdvancedOptions, @chkOleAutomationProcedures AS OleAutomationProcedures

IF @chkOleAutomationProcedures = 0
BEGIN
	PRINT 'Ole Automation Procedures is not enabled'
	IF @chkAdvOptions = 0
	BEGIN
	 PRINT 'advanced options are not enabled'
	 EXEC sp_configure 'show advanced options', 1
	 RECONFIGURE;
	END
	ELSE
	 PRINT 'advanced options already enabled'
	EXEC sp_configure 'Ole Automation Procedures', 1
	RECONFIGURE;
END;
ELSE
	PRINT 'Ole Automation Procedures already enabled'

--EXEC sp_configure;

--exec master..xp_cmdshell @cmd

EXEC sp_configure 'Ole Automation Procedures', 0 -- we always disable this at the end
PRINT 'Ole Automation Procedures was disabled'
RECONFIGURE;

IF @chkAdvOptions = 0
BEGIN
	EXEC sp_configure 'show advanced options', 0
	PRINT 'show advanced options was disabled'
	RECONFIGURE;
END
GO

--EXEC sp_configure;
--GO