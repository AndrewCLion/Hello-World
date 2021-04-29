/****** Object:  StoredProcedure [dbo].[SQL_Login_Password_Expriy_Notification] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[SQL_Login_Password_Expriy_Notification]
AS
BEGIN
Declare @servername varchar(500)
DECLARE @Days INT 
DECLARE @AlertMessage VARCHAR(500)
DECLARE @Count INT
DECLARE @intFlag INT
DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)
SET @intFlag = 1
set @Count=(SELECT COUNT(name)FROM master.sys.sql_logins where is_expiration_checked <> 0 and is_disabled=0 and name not in('ipsoft_monitor'))
WHILE (@intFlag <=@Count)
BEGIN
DECLARE @name NVARCHAR(50)
DECLARE @ExpDate DATETIME 

Set @servername=(Select @@SERVERNAME)

SET @name =(SELECT name FROM (select ROW_NUMBER () OVER (ORDER BY NAME ) AS 'SrNo',
name FROM master.sys.sql_logins where is_expiration_checked <> 0) AS pp

WHERE SrNo=@intFlag 
      )

SET @ExpDate=(SELECT GETDATE()+ CAST((select loginproperty(@name ,'DaysUntilExpiration')) AS int))

--SET @AlertMessage ='Servername |'+ @servername +'| SQL Login name |' + @name +    '| will exprie on'   + cast(@ExpDate as varchar(50))

Set @xml=  cast((select @@SERVERNAME as 'td','',(SELECT name FROM (select ROW_NUMBER () OVER (ORDER BY NAME ) AS 'SrNo',
name FROM master.sys.sql_logins where is_expiration_checked <> 0 and is_disabled=0 ) AS pp

WHERE SrNo=@intFlag) as 'td','',@ExpDate as 'td' FOR XML PATH('tr'), ELEMENTS )  as varchar(Max))
Set @body= '<html> <body> <H3> Microsoft SQL Server Login Password Expiration Notification </H3>
<tr>This is system generated Report, Please do not reply.</tr>
<tr> For Password Reset please contact Microsoft SQL server DBA Team or Drop mail to"DBATeamid@test.com"</tr>
<table border = 1>
<tr bgcolor="#C0C0C0">
<th> ServerName </th> <th> LoginName</th> <th> Expiry Date </th> </tr>'


SET @body = @body + @xml +'</table> </body> </html>'


IF @ExpDate = getdate() +20
BEGIN
EXEC msdb.dbo.sp_send_dbmail 
@profile_name = 'profilename', 
@recipients = 'test@test.com',
@body = @body,
@body_format ='HTML',
@subject = 'SQL Login Password Exipration' ;
end
Else if 
@ExpDate < getdate() +20
BEGIN
EXEC msdb.dbo.sp_send_dbmail 
@profile_name = ' Profilename', 
@recipients = 'test@test.com',
@body = @body,
@body_format ='HTML',
@subject = 'SQL Login Password Exipration' ;
end
ELSE
begin
PRINT 'Not Record Found'
end
SET @intFlag = @intFlag + 1

 END
END
GO