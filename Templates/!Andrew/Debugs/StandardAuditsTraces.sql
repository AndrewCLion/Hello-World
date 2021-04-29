--SELECT * FROM ::fn_trace_getinfo(0)

SELECT 
     loginname,
     loginsid,
     spid,
     hostname,
     applicationname,
     servername,
     databasename,
     objectName,
     e.category_id,
     cat.name as [CategoryName],
     textdata,
     starttime,
     eventclass,
     eventsubclass,--0=begin,1=commit
     e.name as EventName
FROM ::fn_trace_gettable('E:\MSSQL11.CD01\MSSQL\Log\log_17.trc',0)
     INNER JOIN sys.trace_events e
          ON eventclass = trace_event_id
     INNER JOIN sys.trace_categories AS cat
          ON e.category_id = cat.category_id
WHERE databasename LIKE '%CUR1_D_33%' --AND
      --objectname IS NULL AND --filter by objectname
      --e.category_id = 5 AND --category 5 is objects
      --e.trace_event_id = 46 
      --trace_event_id: 46=Create Obj,47=Drop Obj,164=Alter Obj

SELECT top 10 * FROM fn_get_audit_file(
'E:\MSSQL11.CD01\MSSQL\Log\*.sqlaudit',
default, default) WHERE database_name LIKE '%_CUR1_D_33%'