DECLARE @path VARCHAR(MAX)

SELECT @path=SUBSTRING(path, 1, LEN(path) - CHARINDEX('_', REVERSE(path))) + '.trc' 
FROM sys.traces
WHERE is_default = 1

SELECT e.name, t.* 
FROM sys.fn_trace_gettable(@path,0) t
	INNER JOIN sys.trace_events e ON t.EventClass = e.trace_event_id
--WHERE t.StartTime BETWEEN CONVERT(datetime,'20141015 22:30',120) AND CONVERT(datetime,'20141015 23:30',120)
--ORDER BY t.StartTime 

--SELECT TOP 10 e.name, t.* 
--FROM sys.fn_trace_gettable(@path,0) t
--	INNER JOIN sys.trace_events e ON t.EventClass = e.trace_event_id
----WHERE t.StartTime BETWEEN CONVERT(datetime,'20141015 22:30',120) AND CONVERT(datetime,'20141015 23:30',120)
--ORDER BY t.StartTime