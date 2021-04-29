--SELECT * FROM [msdb].[dbo].[sysjobs] where owner_sid = SUSER_SID('BYACCOUNT\EVEJQ')
--USE msdb ;
--GO

--EXEC dbo.sp_manage_jobs_by_login
--    @action = N'REASSIGN',
--    @current_owner_login_name = N'BYACCOUNT\EVEJQ',
--    @new_owner_login_name = N'sa' ;
--GO