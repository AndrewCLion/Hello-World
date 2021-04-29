USE master
GO

DECLARE @chkAdHocDistributedQueries AS SQL_VARIANT
DECLARE @chkAdvOptions AS SQL_VARIANT

SELECT @chkAdHocDistributedQueries = value FROM sys.configurations WHERE name LIKE 'Ad Hoc Distributed Queries'
SELECT @chkAdvOptions = value FROM sys.configurations WHERE name LIKE 'show advanced options'

SELECT @chkAdvOptions, @chkAdHocDistributedQueries

IF @chkAdHocDistributedQueries = 0
BEGIN
	PRINT 'Ad Hoc Distributed Queries is not enabled'
	IF @chkAdvOptions = 0
	BEGIN
	 PRINT 'advanced options are not enabled'
	 EXEC sp_configure 'show advanced options', 1
	 RECONFIGURE;
	END
	ELSE
	 PRINT 'advanced options already enabled'
	EXEC sp_configure 'Ad Hoc Distributed Queries', 1
	RECONFIGURE;
END;
ELSE
	PRINT 'Ad Hoc Distributed Queries already enabled'

--EXEC sp_configure;

--SELECT * INTO Monitoring.msdb_sp_help_job
--FROM OPENROWSET('SQLNCLI', 'server=.\MONITORDEV;trusted_connection=yes', 'exec msdb..sp_help_job')
--SELECT * INTO #JobInfo
--	FROM OPENROWSET('sqloledb', 'server=(local);trusted_connection=yes'
-- , 'set fmtonly off exec msdb.dbo.sp_help_job @execution_status=4')
--EXEC xp_sqlagent_enum_jobs 1,''

--SELECT a.* 
--FROM OPENROWSET('SQLNCLI', 'server=MUCNR90HMPDJ\MONITORDEV;trusted_connection=yes', 'exec msdb..sp_help_job') AS a

IF @chkAdHocDistributedQueries = 0
BEGIN
	EXEC sp_configure 'Ad Hoc Distributed Queries', 0
	PRINT 'Ad Hoc Distributed Queries was disabled'
	RECONFIGURE;
END

IF @chkAdvOptions = 0
BEGIN
	EXEC sp_configure 'show advanced options', 0
	PRINT 'show advanced options was disabled'
	RECONFIGURE;
END
GO

--EXEC sp_configure;
--GO
