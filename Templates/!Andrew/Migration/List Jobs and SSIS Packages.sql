--select s.name AS Jobname ,l.name as Ownername
-- from  msdb..sysjobs s 
-- left join master.sys.syslogins l on s.owner_sid = l.sid

select s.name as SSISname,l.name  AS Ownername
from msdb..sysssispackages s 
 left join master.sys.syslogins l on s.ownersid = l.sid
ORDER BY s.name

EXEC msdb.dbo.sp_help_job
