-- alternatively, enable trace flags 3004 and 3605, create a temporary DB, check error log for messages about zeroing out file messages.
-- If you do *NOT* have instant initialization enabled, you’ll see a message for zeroing out the data file of the new database.
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

INSERT INTO #xp_cmdshell_output EXEC ('xp_cmdshell "whoami"');

--SELECT [Output] FROM #xp_cmdshell_output ;
--SELECT TOP 1 [Output] FROM #xp_cmdshell_output WHERE [Output] IS NOT NULL;

SELECT TOP 1 @RunAs = [Output] FROM #xp_cmdshell_output WHERE [Output] IS NOT NULL;
--SELECT @RunAs AS RunAs, [Output] FROM #xp_cmdshell_output ;

DELETE FROM #xp_cmdshell_output;

INSERT INTO #xp_cmdshell_output EXEC ('xp_cmdshell "whoami /priv"');

IF NOT EXISTS (SELECT * FROM #xp_cmdshell_output WHERE Output LIKE '%SeManageVolumePrivilege%Enabled%')
	INSERT INTO #xp_cmdshell_output ([Output]) VALUES ('SeManageVolumePrivilege         Perform volume maintenance tasks          NOT Enabled ') ;

SELECT SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS ComputerNamePhysicalNetBIOS, @RunAs AS RunAs, [Output] FROM #xp_cmdshell_output WHERE Output LIKE '%SeManageVolumePrivilege%';

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

