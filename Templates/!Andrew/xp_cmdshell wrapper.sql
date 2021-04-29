USE master
GO
DECLARE @RunAs VARCHAR(8000);

DECLARE @chkCMDShell AS SQL_VARIANT
DECLARE @chkAdvOptions AS SQL_VARIANT

SELECT @chkCMDShell = value FROM sys.configurations WHERE name LIKE 'xp_cmdshell'
SELECT @chkAdvOptions = value FROM sys.configurations WHERE name LIKE 'show advanced options'

IF @chkCMDShell = 0
BEGIN
	PRINT 'xp_cmdshell is not enabled'
	IF @chkAdvOptions = 0
	BEGIN
	 PRINT 'advanced options are not enabled'
	 EXEC sp_configure 'show advanced options', 1
	 RECONFIGURE;
	END
	EXEC sp_configure 'xp_cmdshell', 1
	RECONFIGURE;
END;

CREATE TABLE #xp_cmdshell_output ([Output] VARCHAR (8000));

-- code here
INSERT INTO #xp_cmdshell_output EXEC ('xp_cmdshell "dir"');
SELECT [Output] FROM #xp_cmdshell_output WHERE Output LIKE '%Volume Serial Number%';
-- code end

DROP TABLE #xp_cmdshell_output;

IF @chkCMDShell = 0
BEGIN
	PRINT 'xp_cmdshell was disabled'
	EXEC sp_configure 'xp_cmdshell', 0
	RECONFIGURE;
END

IF @chkAdvOptions = 0
BEGIN
	PRINT 'show advanced options was disabled'
	EXEC sp_configure 'show advanced options', 0
	RECONFIGURE;
END
GO

