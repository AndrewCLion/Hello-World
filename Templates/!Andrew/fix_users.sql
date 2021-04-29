-- fix_logins.sql

-- show users not mapped to a login
EXEC sp_change_users_login 'Report'

/* this script uses sp_change_users_login to tie up the database
   users with the server logins - use after restoring a db 
   from a different server */

DECLARE @User SYSNAME
DECLARE @SQL varchar(300)

DECLARE cur_FixUser CURSOR FOR
	SELECT name FROM SYSUSERS
	WHERE isLogin = 1
		AND isNTName = 0
		AND name not in ('guest', 'dbo', 'sys', 'INFORMATION_SCHEMA')
	ORDER BY NAME

OPEN cur_FixUser

FETCH NEXT FROM cur_FixUser INTO @User

WHILE @@FETCH_STATUS = 0
BEGIN

	SELECT @SQL='EXEC sp_change_users_login @Action=''Update_One'', @UserNamePattern=''' +
		 @User + ''' , @LoginName=''' + @User + ''''
	SELECT @SQL
	EXEC (@SQL)
	FETCH NEXT FROM cur_FixUser INTO @User
END

CLOSE cur_FixUser
DEALLOCATE cur_FixUser
