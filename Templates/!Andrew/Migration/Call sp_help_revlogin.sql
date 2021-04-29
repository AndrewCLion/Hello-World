USE [shifttakeover-Sandbox]
 
DECLARE @login nvarchar(50)
 
DECLARE logins_cursor CURSOR FOR
SELECT
    l.name
FROM
    sys.database_principals u INNER  JOIN
    sys.server_principals l ON u.sid=l.sid
 
OPEN logins_cursor
FETCH NEXT FROM logins_cursor INTO @login
 
WHILE @@FETCH_STATUS = 0
 BEGIN
    EXEC sp_help_revlogin  @login
    FETCH NEXT FROM logins_cursor INTO @login
 END
 
CLOSE logins_cursor
DEALLOCATE logins_cursor
GO