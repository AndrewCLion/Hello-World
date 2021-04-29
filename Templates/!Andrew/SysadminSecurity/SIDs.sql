SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Andrew Craven
-- Create date: 20.07.2016
-- Description:	Returns SIS in two forms from a DOMAIN\LOGIN
-- =============================================
--CREATE FUNCTION SidsFromDomainLogin_fn 
ALTER FUNCTION SidsFromDomainLogin_fn 
(
	-- Add the parameters for the function here
	@p1 nvarchar(64)
)
RETURNS 
@Table_Var TABLE 
(
	-- Add the column definitions for the TABLE variable here
	BinarySID VARBINARY(85), 
	StringSID VARCHAR(100),
	Authority VARCHAR(64)
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	
DECLARE @varBinarySID VARBINARY(85)
DECLARE @StringSID VARCHAR(100)
DECLARE @Authority INT
DECLARE @len AS INT
DECLARE @loop AS INT
DECLARE @temp_var BINARY (4)

------ assign the value in below variable ---------------------------------------
SELECT @varBinarySID = SUSER_SID(@p1) -- 0x010500000000000515000000B506317AC46C9B28BC30F47B174A1000

SET @len = LEN(@varBinarySID)
SELECT @StringSID = 'S-'
SELECT @StringSID = @StringSID + CONVERT(VARCHAR, CONVERT(INT, CONVERT(VARBINARY, SUBSTRING(@varBinarySID, 1, 1))))
SELECT @StringSID = @StringSID + '-'
SET @Authority = CONVERT(INT, CONVERT(VARBINARY, SUBSTRING(@varBinarySID, 3, 6)))
SELECT @StringSID = @StringSID + CONVERT(VARCHAR, @Authority)


SET @loop = 9
WHILE @loop < @len
BEGIN
    SELECT @temp_var = SUBSTRING(@varBinarySID, @loop, 4)
    SELECT @StringSID = @StringSID + '-' + CONVERT(VARCHAR, CONVERT(BIGINT, CONVERT(VARBINARY, REVERSE(CONVERT(VARBINARY, @temp_var)))))
    SET @loop = @loop + 4
END
INSERT INTO @Table_Var
SELECT @varBinarySID AS BinarySID, @StringSID AS StringSID, 
	CASE @Authority 
	WHEN 0 THEN 'Null Authority'
	WHEN 1 THEN 'World Authority'
	WHEN 2 THEN 'Local Authority'
	WHEN 3 THEN 'Creator Authority'
	WHEN 4 THEN 'Non-unique Authority'
	WHEN 5 THEN 'NT Authority'
	WHEN 9 THEN 'Resource Manager Authority'
	WHEN 11 THEN 'Microsoft Account Authority'
	WHEN 16 THEN 'Mandatory Label\ Authority'
	ELSE 'Unknown' + CONVERT(VARCHAR, @Authority)
	END AS Authority
	RETURN 
END
GO
--SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\IMYMV')--DECLARE @varBinarySID VARBINARY(85)

--DECLARE @varBinarySID VARBINARY(85)
--DECLARE @StringSID VARCHAR(100)
--DECLARE @len AS INT
--DECLARE @loop AS INT
--DECLARE @temp_var BINARY (4)

-------- assign the value in below variable ---------------------------------------
--SELECT @varBinarySID = 0x010500000000000515000000B506317AC46C9B28BC30F47BB33A1400

--SET @len = LEN(@varBinarySID)
--SELECT @StringSID = 'S-'
--SELECT @StringSID = @StringSID + CONVERT(VARCHAR, CONVERT(INT, CONVERT(VARBINARY, SUBSTRING(@varBinarySID, 1, 1))))
--SELECT @StringSID = @StringSID + '-'
--SELECT @StringSID = @StringSID + CONVERT(VARCHAR, CONVERT(INT, CONVERT(VARBINARY, SUBSTRING(@varBinarySID, 3, 6))))
--SET @loop = 9
--WHILE @loop < @len
--BEGIN
--    SELECT @temp_var = SUBSTRING(@varBinarySID, @loop, 4)
--    SELECT @StringSID = @StringSID + '-' + CONVERT(VARCHAR, CONVERT(BIGINT, CONVERT(VARBINARY, REVERSE(CONVERT(VARBINARY, @temp_var)))))
--    SET @loop = @loop + 4
--END
--SELECT @varBinarySID AS BinarySID, @StringSID 'String SID'

--SELECT * FROM sys.syslogins where name like '%eve%'

--SELECT SUSER_SID('BYACCOUNT\EVEJQ')
--0x010500000000000515000000B506317AC46C9B28BC30F47B174A1000
--0x01 05 000000000005 1500 0000 B506 317A C46C 9B28 BC30 F47B 174A 1000
--0x01 05 000000000005 0000 1500 317A B506 9B28 C46C F47B BC30 1000 174A (reverse the bits in pair of two)
--0x01 05 000000000005 00 00 15 00 31 7A B5 06 9B 28 C4 6C F4 7B BC 30 10 00 17 4A (break them in group of 2) 
--0x01 05 000000000005 00 00 00 15 7A 31 06 B5 28 9B 6C C4 7B F4 30 BC 00 10 4A 17 (reverse the bit in pair of two)
--0x01 05 000000000005 00000015 7A3106B5 289B6CC4 7BF430BC 00104A17 (join together)
-- number of dashes = second number + 2 = 7 ?
-- S-1-5-21-2050033333-681274564-2079600828-1067543

/*
SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\INBV') UNION
SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\INYBV') UNION
SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\EVEGP') UNION
SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\EVEJQ') UNION
SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\EOICD') UNION
SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\EOIGW') UNION
SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\EOSTJ') UNION
SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\EOUOI') UNION
SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\IMMBR') UNION
SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\IMYMR') UNION
SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\ENDUO') UNION
SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\ENDVA') UNION
SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\IMVEM') UNION
SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\EOFVB') UNION
SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\EOGMV') UNION
SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\ENNIJ') UNION
SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\ENOCA') UNION
SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\ENOQJ') UNION
SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\ENOUB') UNION
SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\EOAMF') UNION
SELECT * FROM dbo.SidsFromDomainLogin_fn(N'BYACCOUNT\EQZWL')
*/
