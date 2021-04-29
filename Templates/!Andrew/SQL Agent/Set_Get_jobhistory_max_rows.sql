USE [msdb]
GO
EXEC msdb.dbo.sp_set_sqlagent_properties @jobhistory_max_rows=100000, @jobhistory_max_rows_per_job=100
GO
exec msdb.dbo.sp_get_sqlagent_properties
GO