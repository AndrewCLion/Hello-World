DECLARE @path VARCHAR(MAX)

SET NOCOUNT ON

SELECT @path=SUBSTRING(path, 1, LEN(path) - CHARINDEX('_', REVERSE(path))) + '.trc' 
FROM sys.traces
WHERE is_default = 1

SET NOCOUNT OFF

SELECT	e.name, t.TextData, t.DatabaseID, t.TransactionID, t.NTUserName, t.NTDomainName, t.HostName, t.ClientProcessID, t.ApplicationName, 
        t.LoginName, t.SPID, t.Duration, t.StartTime, t.EndTime, t.Reads, t.Writes, t.CPU, t.[Permissions], t.Severity, t.EventSubClass, t.ObjectID, t.Success, t.IndexID, 
        t.IntegerData, t.ServerName, t.EventClass, t.ObjectType, t.NestLevel, t.[State], t.Error, t.Mode, t.Handle, t.ObjectName, t.DatabaseName, t.[FileName], t.OwnerName, 
        t.RoleName, t.TargetUserName, t.DBUserName, t.TargetLoginName, t.ColumnPermissions, t.LinkedServerName, t.ProviderName, 
        t.MethodName, t.RowCounts, t.RequestID, t.XactSequence, t.EventSequence, t.BigintData1, t.BigintData2, t.[GUID], t.IntegerData2, t.ObjectID2, t.[Type], t.OwnerID, 
        t.ParentName, t.IsSystem, t.Offset, t.SourceDatabaseID, t.SqlHandle, t.SessionLoginName, t.PlanHandle, t.GroupID
-- , t.BinaryData, t.LineNumber, t.LoginSid, t.TargetLoginSid
FROM	::fn_trace_gettable(@path, 0) AS t INNER JOIN
		sys.trace_events AS e ON t.EventClass = e.trace_event_id
--WHERE 1=1
--and (e.name LIKE '%Addlogin%'
--	or e.name LIKE '%User%'
--	or e.name LIKE '%ADD%'
--		or e.name LIKE '%Role%'
--)
WHERE RoleName IN ( 'sysadmin', 'securityadmin' )
--AND SessionLoginName LIKE 'SA'
ORDER BY StartTime