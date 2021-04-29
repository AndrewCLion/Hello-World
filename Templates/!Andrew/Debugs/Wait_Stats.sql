
SELECT objtype,count(*) FROM sys.dm_exec_cached_plans
GROUP BY objtype

SELECT * FROM sys.dm_os_wait_stats ORDER BY wait_time_ms DESC

SELECT * FROM sys.dm_os_waiting_tasks order by wait_duration_ms desc

--SP_CONFIGURE	