declare @chkCMDShell as sql_variant
select @chkCMDShell = value from sys.configurations where name = 'xp_cmdshell'
if @chkCMDShell = 0
begin
 Print 'xp_cmdshell is not enabled'
 --EXEC sp_configure 'xp_cmdshell', 1
 --RECONFIGURE;
end
else
begin
 Print 'xp_cmdshell is already enabled'
 --EXEC sp_configure 'xp_cmdshell', 0
 --RECONFIGURE;
end