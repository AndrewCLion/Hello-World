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

DECLARE		@TCPPort		NVARCHAR(19);
DECLARE		@DBEngineLogin	VARCHAR(100);
DECLARE		@AgentLogin		VARCHAR(100);
DECLARE		@MSOLAPLogin	VARCHAR(100);
DECLARE		@ReportSLogin	VARCHAR(100);

--SELECT DISTINCT local_tcp_port FROM sys.dm_exec_connections WHERE local_tcp_port IS NOT NULL
----- GET TCPIP Port
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

BEGIN TRY
EXECUTE       master.dbo.xp_instance_regread
              @rootkey      = N'HKEY_LOCAL_MACHINE',
              @key          = N'SYSTEM\CurrentControlSet\Services\MSSQLSERVEROLAPSERVICE',
              @value_name   = N'ObjectName',
              @value        = @MSOLAPLogin OUTPUT;
END TRY
BEGIN CATCH
	SET @MSOLAPLogin = ERROR_MESSAGE();
END CATCH

BEGIN TRY
EXECUTE       master.dbo.xp_instance_regread
              @rootkey      = N'HKEY_LOCAL_MACHINE',
              @key          = N'SYSTEM\CurrentControlSet\Services\REPORTSERVER',
              @value_name   = N'ObjectName',
              @value        = @ReportSLogin OUTPUT;
END TRY
BEGIN CATCH
	SET @ReportSLogin = ERROR_MESSAGE();
END CATCH

--SELECT        [DBEngineLogin] = @DBEngineLogin, [AgentLogin] = @AgentLogin, [MSOLAPLogin] = @MSOLAPLogin, [ReportSLogin] = @ReportSLogin
--GO
	
SELECT DISTINCT local_net_address, local_tcp_port, net_transport, protocol_type, encrypt_option, @TCPPort AS RegistryPort, [DBEngineLogin] = @DBEngineLogin, [AgentLogin] = @AgentLogin, [MSOLAPLogin] = @MSOLAPLogin, [ReportSLogin] = @ReportSLogin FROM sys.dm_exec_connections;
GO
SELECT name, protocol_desc, port, state_desc FROM sys.tcp_endpoints -- WHERE type_desc = 'SERVICE_BROKER'
GO
SELECT * FROM sys.dm_os_sys_info dosi; 
GO
xp_msver;
GO
/*
USE MASTER
GO
xp_enumerrorlogs 1
GO
xp_readerrorlog 0, 1, N'Server is listening on'
GO
xp_readerrorlog 1, 1, N'Server is listening on'
GO
xp_readerrorlog 2, 1, N'Server is listening on'
GO
xp_readerrorlog 3, 1, N'Server is listening on'
GO
xp_readerrorlog 4, 1, N'Server is listening on'
GO
xp_readerrorlog 5, 1, N'Server is listening on'
GO
xp_readerrorlog 6, 1, N'Server is listening on'
GO
xp_readerrorlog 7, 1, N'Server is listening on'
GO
xp_readerrorlog 8, 1, N'Server is listening on'
GO
xp_readerrorlog 9, 1, N'Server is listening on'
GO
*/