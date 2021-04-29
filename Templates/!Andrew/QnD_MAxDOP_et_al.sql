USE master
GO
/*==========================================================================================
  File:     QnD_MAxDOP_et_al.sql

  Summary:  This script sets three "standard" configuration options to better than standard values.

  Version Updates:
  15.05.2018: Andrew Craven - First Version

  SQL Server Version: 2008-->2016
==========================================================================================*/
DECLARE @RunAs VARCHAR(8000);

DECLARE @chkAdvOptions AS SQL_VARIANT
DECLARE @ProcessorCount AS int = 4
DECLARE @MaxDOP AS int = 1 -- note, this is the default value for SharePoint and a few others
DECLARE @CostThreshold int = 42
DECLARE @OptimizeAdHoc int = 1

DECLARE @xp_msver TABLE (
    [idx] [int] NULL
    ,[c_name] [varchar](100) NULL
    ,[int_val] [float] NULL
    ,[c_val] [varchar](256) NULL
    )

INSERT INTO @xp_msver
EXEC ('[master]..[xp_msver]');;

SELECT @ProcessorCount = [int_val] FROM @xp_msver WHERE [c_name] = 'ProcessorCount'

SET @MaxDOP = (@ProcessorCount + 1) / 2
IF @MaxDOP > 8
	SET @MaxDOP = 8 -- only set to mre than 8 if analysis shows that higher values really would help

--SELECT @MaxDOP, @ProcessorCount

SELECT @chkAdvOptions = value FROM sys.configurations WHERE name LIKE 'show advanced options'

IF @chkAdvOptions = 0
BEGIN
	PRINT 'advanced options are not enabled'
	EXEC sp_configure 'show advanced options', 1
	RECONFIGURE;
END
;
--do your stuff here
EXEC sp_configure 'max degree of parallelism', @MaxDOP;
EXEC sp_configure 'cost threshold for parallelism', @CostThreshold;
EXEC sp_configure 'optimize for ad hoc workloads', @OptimizeAdHoc;
EXEC sp_configure;

--IF @chkAdvOptions = 0 -- Advanced Options should always be switched off so switch off even if previously on
--BEGIN
--	PRINT 'show advanced options was disabled'
	EXEC sp_configure 'show advanced options', 0;
	RECONFIGURE;
--END
GO

