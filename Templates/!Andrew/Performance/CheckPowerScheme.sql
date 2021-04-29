DECLARE		@PowerScheme	VARCHAR(120);

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

SELECT @PowerScheme AS ActivePowerScheme