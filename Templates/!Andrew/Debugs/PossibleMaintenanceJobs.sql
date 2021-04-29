USE msdb
SELECT	@@SERVERNAME AS AtAtServername,
		j.name AS JobName, CASE WHEN j.Enabled = 0 THEN 'No' ELSE 'Yes' END AS JobEnabled, 
        CASE WHEN ISNULL(s.Enabled,99) = 99 THEN 'NONE' WHEN ISNULL(s.Enabled,0) = 0 THEN 'No' ELSE 'Yes' END AS SchedEnabled, 
		l.name AS OwnerName, js.next_run_date, js.next_run_time, s.active_start_date, 
        s.active_end_date, s.active_start_time, s.active_end_time
FROM	sysschedules AS s INNER JOIN
        sysjobschedules AS js ON s.schedule_id = js.schedule_id RIGHT OUTER JOIN
        sysjobs AS j LEFT OUTER JOIN
        Master.dbo.syslogins AS l ON j.owner_sid = l.sid ON js.job_id = j.job_id
WHERE j.name LIKE '%Maint%' OR j.name LIKE '%ReorgDB%'
UNION ALL
SELECT	@@SERVERNAME AS AtAtServername, '  %Maint% Job Count', CAST(COUNT(1) AS varchar(14)), 
        NULL, 
		NULL, NULL, NULL, NULL, 
        NULL, NULL, NULL
FROM	sysjobs AS j
WHERE j.name LIKE '%Maint%' OR j.name LIKE '%ReorgDB%'
UNION ALL
SELECT	@@SERVERNAME AS AtAtServername, '  Enabled %Maint% Job Count', CAST(COUNT(1) AS varchar(14)), 
        NULL, 
		NULL, NULL, NULL, NULL, 
        NULL, NULL, NULL
FROM	sysschedules AS s INNER JOIN
        sysjobschedules AS js ON s.schedule_id = js.schedule_id RIGHT OUTER JOIN
        sysjobs AS j ON js.job_id = j.job_id
WHERE (j.name LIKE '%Maint%' OR j.name LIKE '%ReorgDB%') AND j.enabled = 1 AND ISNULL(s.enabled,0) = 1
ORDER BY j.name
GO