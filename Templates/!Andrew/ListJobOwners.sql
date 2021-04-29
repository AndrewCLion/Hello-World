SELECT	j.name AS [JobName], CASE WHEN j.Enabled = 0 THEN 'No' ELSE 'Yes' END AS JobEnabled, 
        CASE WHEN ISNULL(s.Enabled,99) = 99 THEN 'NONE' WHEN ISNULL(s.Enabled,0) = 0 THEN 'No' ELSE 'Yes' END AS SchedEnabled,
		l.name AS [OwnerName], js.next_run_date, js.next_run_time, s.active_start_date, 
        s.active_end_date, s.active_start_time, s.active_end_time
FROM	msdb..sysschedules AS s INNER JOIN
        msdb..sysjobschedules AS js ON s.schedule_id = js.schedule_id RIGHT OUTER JOIN
        msdb..sysjobs AS j LEFT OUTER JOIN
        master.dbo.syslogins AS l ON j.owner_sid = l.sid ON js.job_id = j.job_id
ORDER BY j.name

GO

-------------------------------------------------------------------
--EXEC MSDB.dbo.sp_update_job 
--@job_name = 'DailyBackups',
--@owner_login_name = 'sa'
--GO-------------------------------------------------------------------
--SET NOCOUNT ON

--SELECT 'EXEC MSDB.dbo.sp_update_job ' + char(13) +
--'@job_name = ' + char(39) + j.[Name] + char(39) + ',' + char(13) + 
--'@owner_login_name = ' + char(39) + 'sa' + char(39) + char(13) + char(13)
--FROM MSDB.dbo.sysjobs j
--INNER JOIN Master.dbo.syslogins l
--ON j.owner_sid = l.sid
--WHERE l.[name] <> 'sa' 
--ORDER BY j.[name] 
--GO-------------------------------------------------------------------
--SELECT * FROM dbo.sysjobschedules
--SELECT * FROM dbo.sysschedules 