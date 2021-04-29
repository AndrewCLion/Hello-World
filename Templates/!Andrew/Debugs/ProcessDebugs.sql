select DATEDIFF(minute, StartTime,EndTime),* from msdb.dbo.CommandLog 
--where StartTime BETWEEN '20141009 00:00:00' and '20141012 23:00:00' 
where StartTime BETWEEN DATEADD(minute,-10,GETDATE()) and GETDATE() 
AND DATEDIFF(minute, StartTime,EndTime) > 0
order by StartTime
--select * from msdb.dbo.CommandLog where StartTime BETWEEN DATEADD(minute,-10,GETDATE()) AND GETDATE() ORDER BY StartTime

select * from sys.dm_exec_requests  where session_id > 50
select * from sys.dm_os_waiting_tasks where session_id > 50
select * from sys.dm_exec_sessions where session_id = 83
select * from sys.dm_tran_session_transactions where session_id = 80
select * from sys.dm_tran_active_transactions where transaction_id = 745322927
select * from sys.dm_os_wait_stats order by wait_time_ms desc

select * from sys.dm_exec_sql_text(
0x020000002F338D1C32F968EC42E44CABA70BF73F56A1E770
)

select * from sys.dm_exec_query_plan(
0x06000E009CCF7836406103EF000000000000000000000000
)

select db_name(14)
