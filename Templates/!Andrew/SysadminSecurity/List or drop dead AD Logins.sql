-- beware, reports all logins as dead even if there's only a collation sequence problem.
declare @user sysname
declare @type varchar(8)
declare @domainsearch varchar(100)
 
set @domainsearch = '%\%'
 
CREATE TABLE #AllResults (name sysname, type varchar(8), privilege varchar(8), [mapped login name] sysname, [permission path] sysname NULL)

declare recscan cursor for
select name, type from sys.server_principals
where type IN ('G', 'U')
 and name like @domainsearch
 and name not like 'NT %'
 
open recscan 
fetch next from recscan into @user, @type
 
while @@fetch_status = 0
begin
    begin try
        if @type = 'G'
			INSERT INTO #AllResults exec xp_logininfo @acctname = @user, @option = 'members'
		ELSE
			INSERT INTO #AllResults exec xp_logininfo @user
    end try
    begin catch
        --Error on xproc because login doesn't exist
        print 'drop login '+convert(varchar,@user)
    end catch
 
    fetch next from recscan into @user, @type
end

close recscan
deallocate recscan

--SELECT * FROM #AllResults ORDER BY 1
SELECT ar.*,sl.sysadmin,sl.securityadmin,sl.dbcreator FROM #AllResults ar
LEFT JOIN sys.syslogins sl ON ar.name = sl.loginname 
WHERE [permission path] IS NULL
UNION
SELECT ar.*,sl.sysadmin,sl.securityadmin,sl.dbcreator FROM #AllResults ar
LEFT JOIN sys.syslogins sl ON ar.[permission path] = sl.loginname 
WHERE [permission path] IS NOT NULL
ORDER BY 1

DROP TABLE #AllResults
