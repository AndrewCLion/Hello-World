select 'ALTER AUTHORIZATION ON Database::' + name + ' to [' + suser_sname(owner_sid) + ']' from sys.databases
where name not in ('master', 'msdb', 'tempdb', 'model')
