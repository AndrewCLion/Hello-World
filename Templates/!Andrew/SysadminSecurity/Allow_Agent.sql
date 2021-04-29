USE [msdb]
GO
CREATE USER [BYACCOUNT\?????] FOR LOGIN [BYACCOUNT\?????]
GO
USE [msdb]
GO
ALTER USER [BYACCOUNT\?????] WITH DEFAULT_SCHEMA=[dbo]
GO
USE [msdb]
GO
EXEC sp_addrolemember N'SQLAgentOperatorRole', N'BYACCOUNT\?????'
GO
USE [msdb]
GO
EXEC sp_addrolemember N'SQLAgentReaderRole', N'BYACCOUNT\?????'
GO
USE [msdb]
GO
EXEC sp_addrolemember N'SQLAgentUserRole', N'BYACCOUNT\?????'
GO
