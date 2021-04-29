DECLARE       @DBEngineLogin       VARCHAR(100)
DECLARE       @AgentLogin          VARCHAR(100)
DECLARE       @MSOLAPLogin         VARCHAR(100)
DECLARE       @ReportSLogin        VARCHAR(100)

EXECUTE       master.dbo.xp_instance_regread
              @rootkey      = N'HKEY_LOCAL_MACHINE',
              @key          = N'SYSTEM\CurrentControlSet\Services\MSSQLServer',
              @value_name   = N'ObjectName',
              @value        = @DBEngineLogin OUTPUT

EXECUTE       master.dbo.xp_instance_regread
              @rootkey      = N'HKEY_LOCAL_MACHINE',
              @key          = N'SYSTEM\CurrentControlSet\Services\SQLServerAgent',
              @value_name   = N'ObjectName',
              @value        = @AgentLogin OUTPUT

BEGIN TRY
EXECUTE       master.dbo.xp_instance_regread
              @rootkey      = N'HKEY_LOCAL_MACHINE',
              @key          = N'SYSTEM\CurrentControlSet\Services\MSSQLSERVEROLAPSERVICE',
              @value_name   = N'ObjectName',
              @value        = @MSOLAPLogin OUTPUT
END TRY
BEGIN CATCH
	SET @MSOLAPLogin = ERROR_MESSAGE()
END CATCH

BEGIN TRY
EXECUTE       master.dbo.xp_instance_regread
              @rootkey      = N'HKEY_LOCAL_MACHINE',
              @key          = N'SYSTEM\CurrentControlSet\Services\REPORTSERVER',
              @value_name   = N'ObjectName',
              @value        = @ReportSLogin OUTPUT
END TRY
BEGIN CATCH
	SET @ReportSLogin = ERROR_MESSAGE()
END CATCH

SELECT        [DBEngineLogin] = @DBEngineLogin, [AgentLogin] = @AgentLogin, [MSOLAPLogin] = @MSOLAPLogin, [ReportSLogin] = @ReportSLogin
GO