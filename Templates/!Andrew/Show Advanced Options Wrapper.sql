USE master
GO
DECLARE @RunAs VARCHAR(8000);

DECLARE @chkAdvOptions AS SQL_VARIANT

SELECT @chkAdvOptions = value FROM sys.configurations WHERE name LIKE 'show advanced options'

IF @chkAdvOptions = 0
BEGIN
	PRINT 'advanced options are not enabled'
	EXEC sp_configure 'show advanced options', 1
	RECONFIGURE;
END

--do your stuff here
EXEC sp_configure ;

IF @chkAdvOptions = 0
BEGIN
	PRINT 'show advanced options was disabled'
	EXEC sp_configure 'show advanced options', 0
	RECONFIGURE;
END
GO

