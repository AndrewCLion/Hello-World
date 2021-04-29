--http://jongurgul.com/blog/sql-server-login-password-hash 
USE [tempdb] 
GO 
IF NOT EXISTS(SELECT * FROM [tempdb].sys.tables WHERE name = 'WordList') 
BEGIN 
 CREATE TABLE [dbo].[WordList]([Plain] NVARCHAR(MAX)) 

 --USERNAME//PASSWORD COMBOS 
 INSERT INTO [WordList]([Plain]) 
 SELECT [name] FROM sys.sql_logins 
 UNION 
 SELECT REPLACE(REPLACE(REPLACE([name],'o','0'),'i','1'),'e','3') FROM sys.sql_logins 
 UNION 
 SELECT REPLACE(REPLACE(REPLACE([name],'o','0'),'i','1'),'e','3')+'.' FROM sys.sql_logins --example added character 
 UNION 
 SELECT REPLACE(REPLACE(REPLACE([name],'o','0'),'i','1'),'e','3')+'!' FROM sys.sql_logins --example added character 
  
 --No Comment 
 INSERT INTO [WordList]([Plain]) VALUES (N'') 
 INSERT INTO [WordList]([Plain]) VALUES (N'password') 
 INSERT INTO [WordList]([Plain]) VALUES (N'passw0rd') 
 INSERT INTO [WordList]([Plain]) VALUES (N'password!') 
 INSERT INTO [WordList]([Plain]) VALUES (N'passw0rd!') 
 INSERT INTO [WordList]([Plain]) VALUES (N'sa') 
 INSERT INTO [WordList]([Plain]) VALUES (N'dev') 
 INSERT INTO [WordList]([Plain]) VALUES (N'test') 
END 
--SELECT * FROM [WordList]

DECLARE @Algorithm VARCHAR(10) 
SET @Algorithm = CASE WHEN @@MICROSOFTVERSION/0x01000000 > 10 THEN 'SHA2_512' ELSE 'SHA1' END 

SELECT 
 [name] 
,[password_hash] 
,SUBSTRING([password_hash],3,4) [Salt] 
,SUBSTRING([password_hash],7,(LEN([password_hash])-6)) [Hash] 
,HASHBYTES(@Algorithm,CAST(w.[Plain] AS VARBINARY(MAX))+SUBSTRING([password_hash],3,4)) [ComputedHash] 
,w.[Plain] 
FROM sys.sql_logins 
INNER JOIN [tempdb].[dbo].[WordList] w 
ON SUBSTRING([password_hash],7,(LEN([password_hash])-6)) = HASHBYTES(@Algorithm,CAST(w.[Plain] AS VARBINARY(MAX))+SUBSTRING([password_hash],3,4)) 
  
IF EXISTS(SELECT * FROM [tempdb].sys.tables WHERE name = 'WordList') 
BEGIN 
 DROP TABLE [tempdb].[dbo].[WordList] 
END 
GO 

SELECT 
	[name] 
	,[password_hash] 
	,SUBSTRING([password_hash],3,4) [Salt] 
	,SUBSTRING([password_hash],7,(LEN([password_hash])-6)) [Hash] 
FROM sys.sql_logins 
GO 
/*
DECLARE @TargetSQLVersion INT;
DECLARE @pswd NVARCHAR(MAX);
DECLARE @salt VARBINARY(4);
DECLARE @hash VARBINARY(MAX);
DECLARE @base64hash varchar(514);

SET @TargetSQLVersion = 12;
SET @pswd = 'A!Valid!Password!';

IF @TargetSQLVersion < 11
	BEGIN
	SET @salt = CAST(NEWID() AS VARBINARY(4));
	SET @hash = 0x0100 + @salt + HASHBYTES('SHA1', CAST(@pswd AS VARBINARY(MAX)) + @salt);
	END
ELSE
	BEGIN
	SET @salt = CRYPT_GEN_RANDOM(4);
	SET @hash = 0x0200 + @salt + HASHBYTES('SHA2_512', CAST(@pswd AS VARBINARY(MAX)) + @salt);
	END

EXECUTE AdminDB.[dbo].[IFX_Base64FromVarBinary] @hash, @base64hash OUTPUT

SELECT @hash AS HashValue, @base64hash AS HasBase64, PWDCOMPARE(@pswd,@hash) AS IsPasswordHash;
*/