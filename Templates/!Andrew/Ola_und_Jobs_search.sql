SELECT * FROM msdb.dbo.CommandLog 
WHERE 
StartTime BETWEEN GETDATE()-1 AND GETDATE()
--StartTime BETWEEN '20140818 01:00:00' and '20140818 18:00:00' 
--Objectname LIKE '%ECMChangeLog%'
ORDER BY StartTime DESC
/*
select * from sys.dm_exec_requests
select * from sys.dm_exec_sessions
select * from sys.dm_tran_session_transactions where session_id = 80
select * from sys.dm_tran_active_transactions where transaction_id = 745322927
select * from sys.dm_os_wait_stats order by wait_time_ms desc
*/