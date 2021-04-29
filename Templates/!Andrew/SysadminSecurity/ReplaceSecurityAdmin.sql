use [master]
GO
GRANT ALTER ANY LOGIN TO [BYACCOUNT\?]
GO
EXEC master..sp_dropsrvrolemember @loginame = N'BYACCOUNT\?', @rolename = N'securityadmin'
GO
