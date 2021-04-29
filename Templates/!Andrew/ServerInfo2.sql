DECLARE		@TCPPort		NVARCHAR(19);
DECLARE		@DBEngineLogin	VARCHAR(100);
DECLARE		@AgentLogin		VARCHAR(100);
DECLARE		@MSOLAPLogin	VARCHAR(100);
DECLARE		@ReportSLogin	VARCHAR(100);
DECLARE		@TDPSQLversion	VARCHAR(100);
DECLARE		@PowerScheme	VARCHAR(100);
DECLARE		@key			NVARCHAR(256);

DECLARE @xp_msver TABLE (
    [idx] [int] NULL
    ,[c_name] [varchar](100) NULL
    ,[int_val] [float] NULL
    ,[c_val] [varchar](256) NULL
    )

SET NOCOUNT ON

EXECUTE		master.dbo.xp_instance_regread
              @rootkey      = N'HKEY_LOCAL_MACHINE',
              @key          = N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\IPAll',
              @value_name   = N'TcpPort',
              @value        = @TCPPort OUTPUT;

EXECUTE       master.dbo.xp_instance_regread
              @rootkey      = N'HKEY_LOCAL_MACHINE',
              @key          = N'SYSTEM\CurrentControlSet\Services\MSSQLServer',
              @value_name   = N'ObjectName',
              @value        = @DBEngineLogin OUTPUT;

EXECUTE       master.dbo.xp_instance_regread
              @rootkey      = N'HKEY_LOCAL_MACHINE',
              @key          = N'SYSTEM\CurrentControlSet\Services\SQLServerAgent',
              @value_name   = N'ObjectName',
              @value        = @AgentLogin OUTPUT;

SET @key = N'SYSTEM\CurrentControlSet\Services\MSSQLSERVEROLAPSERVICE$' + CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(16))

BEGIN TRY
EXECUTE       master.dbo.xp_instance_regread
              @rootkey      = N'HKEY_LOCAL_MACHINE',
              @key          = @key,
              @value_name   = N'ObjectName',
              @value        = @MSOLAPLogin OUTPUT;
END TRY
BEGIN CATCH
	SET @MSOLAPLogin = ERROR_MESSAGE();
END CATCH

IF @MSOLAPLogin IS NULL
	BEGIN
	SET @key = N'SYSTEM\CurrentControlSet\Services\MSOLAP$' + CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(16))

	BEGIN TRY
	EXECUTE       master.dbo.xp_instance_regread
				  @rootkey      = N'HKEY_LOCAL_MACHINE',
				  @key          = @key,
				  @value_name   = N'ObjectName',
				  @value        = @MSOLAPLogin OUTPUT;
	END TRY
	BEGIN CATCH
		SET @MSOLAPLogin = ERROR_MESSAGE();
	END CATCH
	END

SET @key = N'SYSTEM\CurrentControlSet\Services\REPORTSERVER$' + CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(16))

BEGIN TRY
EXECUTE       master.dbo.xp_instance_regread
              @rootkey      = N'HKEY_LOCAL_MACHINE',
              @key          = @key,
              @value_name   = N'ObjectName',
              @value        = @ReportSLogin OUTPUT;
END TRY
BEGIN CATCH
	SET @ReportSLogin = ERROR_MESSAGE();
END CATCH

BEGIN TRY
EXECUTE       master.dbo.xp_instance_regread
              @rootkey      = N'HKEY_LOCAL_MACHINE',
              @key          = N'SOFTWARE\IBM\ADSM\CurrentVersion\TDPSQL',
              @value_name   = N'PTFLevel',
              @value        = @TDPSQLversion OUTPUT;
END TRY
BEGIN CATCH
	SET @TDPSQLversion = ERROR_MESSAGE();
END CATCH

BEGIN TRY
EXECUTE       master.dbo.xp_regread
              @rootkey      = N'HKEY_LOCAL_MACHINE',
              @key          = N'SYSTEM\CurrentControlSet\Control\Power\User\Default\PowerSchemes',
              @value_name   = N'ActivePowerScheme',
              @value        = @PowerScheme OUTPUT;
IF @PowerScheme = '381b4222-f694-41f0-9685-ff5bb260df2e'
	SET @PowerScheme = 'Balanced: ' + @PowerScheme
ELSE IF @PowerScheme = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
	SET @PowerScheme = 'High Performance: ' + @PowerScheme
ELSE IF @PowerScheme = 'a1841308-3541-4fab-bc81-f71556f20b4a'
	SET @PowerScheme = 'PowerSaver: ' + @PowerScheme
ELSE SET @PowerScheme = 'UnKnown: ' + @PowerScheme
END TRY
BEGIN CATCH
	SET @PowerScheme = ERROR_MESSAGE();
END CATCH

INSERT INTO @xp_msver
EXEC ('[master]..[xp_msver]');;
 
INSERT INTO @xp_msver ( [idx], [c_name], [int_val], [c_val]) VALUES (0, 'Port in Registry',CAST(@TCPPort AS float),'');
INSERT INTO @xp_msver ( [idx], [c_name], [c_val]) VALUES (0, 'Login Agent',@AgentLogin);
INSERT INTO @xp_msver ( [idx], [c_name], [c_val]) VALUES (0, 'Login DBEngine',@DBEngineLogin);
INSERT INTO @xp_msver ( [idx], [c_name], [c_val]) VALUES (0, 'Login MSOLAP',@MSOLAPLogin);
INSERT INTO @xp_msver ( [idx], [c_name], [c_val]) VALUES (0, 'Login Report Server',@ReportSLogin);
INSERT INTO @xp_msver ( [idx], [c_name], [c_val]) VALUES (0, 'TDP SQL version',@TDPSQLversion);
INSERT INTO @xp_msver ( [idx], [c_name], [c_val]) VALUES (-5, 'ActivePowerScheme',@PowerScheme);
INSERT INTO @xp_msver ( [idx], [c_name], [c_val]) VALUES (-99, 'Servername', CONVERT(VARCHAR(128),SERVERPROPERTY('Servername')));
INSERT INTO @xp_msver ( [idx], [c_name], [c_val]) VALUES (0, 'Product Level', CONVERT(VARCHAR(128),SERVERPROPERTY('ProductLevel')));
INSERT INTO @xp_msver ( [idx], [c_name], [c_val]) VALUES (0, 'Product Edition', CONVERT(VARCHAR(128),SERVERPROPERTY('Edition')));
INSERT INTO @xp_msver ( [idx], [c_name], [c_val]) VALUES (-98, 'Computer Name PhysicalNetBIOS', CONVERT(VARCHAR(128),SERVERPROPERTY('ComputerNamePhysicalNetBIOS')));
INSERT INTO @xp_msver ( [idx], [c_name], [c_val]) VALUES (-97, 'DEFAULT_DOMAIN()', CONVERT(VARCHAR(128),DEFAULT_DOMAIN()));
IF SERVERPROPERTY('IsClustered') <> 0
INSERT INTO @xp_msver ( [idx], [c_name], [int_val], [c_val]) VALUES (0, 'Is Clustered', CAST(SERVERPROPERTY('IsClustered') AS INT), CONVERT(VARCHAR(128),SERVERPROPERTY('IsClustered')));
ELSE
INSERT INTO @xp_msver ( [idx], [c_name], [int_val], [c_val]) VALUES (0, 'Is Clustered', 0, 'No');

INSERT INTO @xp_msver ( [idx], [c_name], [c_val]) VALUES (0, '@@VERSION', CONVERT(VARCHAR(256),@@VERSION));

INSERT INTO @xp_msver ( [idx], [c_name], [c_val])
SELECT -9, 'tempDB Created', CONVERT(VARCHAR(256),create_date,120)
FROM            sys.databases
WHERE        (name = 'tempdb')

IF (CONVERT(float , SUBSTRING(CAST(SERVERPROPERTY('ProductVersion') AS varchar(10)),1,4) )>10)
BEGIN
INSERT INTO @xp_msver ( [idx], [c_name], [c_val])
EXEC ('SELECT 0, ''virtual_machine_type'', virtual_machine_type_desc FROM sys.dm_os_sys_info dosi ;')
INSERT INTO @xp_msver ( [idx], [c_name], [c_val])
EXEC ('SELECT -96, ''sqlserver_start_time'', CONVERT(VARCHAR(256),sqlserver_start_time,120) FROM sys.dm_os_sys_info dosi ;')
INSERT INTO @xp_msver ( [idx], [c_name], [c_val])
EXEC ('SELECT -91, ''server start time (ms_ticks)'', CONVERT(VARCHAR(256),DATEADD(SECOND, -ms_ticks/1000, GETDATE()),120) FROM sys.dm_os_sys_info dosi ;')
END
ELSE
BEGIN
INSERT INTO @xp_msver ( [idx], [c_name], [c_val]) VALUES (0, 'virtual_machine_type', 'Information not available in sys.dm_os_sys_info')
END

SET NOCOUNT OFF

SELECT * FROM @xp_msver ORDER BY [idx], c_name
GO
-- only until here for Front-End --------------------------------------------------------------------------------------------------------------------------
IF (CONVERT(float , SUBSTRING(CAST(SERVERPROPERTY('ProductVersion') AS varchar(10)),1,4) )>10.5)
OR ((CONVERT(float , SUBSTRING(CAST(SERVERPROPERTY('ProductVersion') AS varchar(10)),1,4) )=10.5) ) --AND (CONVERT(float , SUBSTRING(CAST(SERVERPROPERTY('ProductVersion') AS varchar(10)),4,5) )>=50.25))
BEGIN
SELECT servicename, startup_type_desc, status_desc, last_startup_time
FROM sys.dm_server_services
END
GO
SELECT DISTINCT local_net_address, local_tcp_port, net_transport, protocol_type, encrypt_option
FROM sys.dm_exec_connections;
GO
/*
SELECT --@@SERVERNAME AS AtAtServername,
	   SERVERPROPERTY('Servername'
					 )AS Servername, 
	   SERVERPROPERTY('MachineName'
					 )AS MachineName, 
	   SERVERPROPERTY('InstanceName'
					 )AS InstanceName, 
	   SERVERPROPERTY('ComputerNamePhysicalNetBIOS'
					 )AS ComputerNamePhysicalNetBIOS, 
	   SERVERPROPERTY('ProductVersion'
					 )AS ProductVersion, 
	   SERVERPROPERTY('ProductLevel'
					 )AS ProductLevel, 
	   SERVERPROPERTY('Edition'
					 )AS Edition,
	   --,SERVERPROPERTY('EngineEdition'
	   --			) AS EngineEdition
	   SERVERPROPERTY('IsClustered'
					 )AS IsClustered, 
	   @@VERSION AS Versions;
--select * from sys.configurations
*/
DECLARE @Domain varchar(100), @key varchar(100)

SET @key = 'SYSTEM\ControlSet001\Services\Tcpip\Parameters\'
EXEC master..xp_regread @rootkey='HKEY_LOCAL_MACHINE', @key=@key,@value_name='Domain',@value=@Domain OUTPUT 
SELECT @@servername AS Servername ,@Domain AS TCPIP_Domain,DEFAULT_DOMAIN() AS DefaultDomain 

EXEC Master.dbo.xp_LoginConfig 'Default Domain' 