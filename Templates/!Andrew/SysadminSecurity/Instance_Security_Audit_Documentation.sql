/* ====================================================================================================================== */
/* Instance Security Audit Documentation */
/* Runs for all databases, unless a specific database is used in the WHERE clause below */
/* */
/* By VikingDBA 12/28/2011 */
/* ====================================================================================================================== */


Use MASTER

SET NOCOUNT ON

PRINT '============================================================================================================='
PRINT ' Security Audit For Server Instance ' + CONVERT(varchar(128),@@servername)
PRINT ' For ' + CONVERT(varchar(128),getdate(),101) + ' ' + CONVERT(varchar(128),getdate(),108)
PRINT '============================================================================================================='
PRINT 'NOTE: Make sure to get list of logins using the sp_help_revlogin stored procedure in the master database.'
PRINT ' '
PRINT ' '
PRINT '============================================================================================================='
PRINT ' Server Role Security Settings'
PRINT ' '
PRINT ' '

/* ==================================================================================================================== */
-- Security Audit for SERVER Roles
DECLARE @sr varchar(100)
DECLARE @mn varchar(150)
DECLARE @cmd varchar(4000)
DECLARE @col1nm varchar(200)
DECLARE @col2nm varchar(200)
DECLARE @col3nm varchar(200)
DECLARE @col4nm varchar(200)
DECLARE @col5nm varchar(200)
DECLARE @col6nm varchar(200)
DECLARE @col7nm varchar(200)
DECLARE @col8nm varchar(200)
DECLARE @col9nm varchar(200)
DECLARE @col10nm varchar(200)
DECLARE @col11nm varchar(200)
DECLARE @col12nm varchar(200)
DECLARE @col13nm varchar(200)
DECLARE @col14nm varchar(200)
DECLARE @col15nm varchar(200)
DECLARE @col16nm varchar(200)
DECLARE @col17nm varchar(200)
DECLARE @col18nm varchar(200)
DECLARE @col19nm varchar(200)
DECLARE @col20nm varchar(200)
DECLARE @col1len int
DECLARE @col2len int
DECLARE @col3len int
DECLARE @col4len int
DECLARE @col5len int
DECLARE @col6len int
DECLARE @col7len int
DECLARE @col8len int
DECLARE @col9len int
DECLARE @col10len int
DECLARE @col11len int
DECLARE @col12len int
DECLARE @col13len int
DECLARE @col14len int
DECLARE @col15len int
DECLARE @col16len int
DECLARE @col17len int
DECLARE @col18len int
DECLARE @col19len int
DECLARE @col20len int
DECLARE @rn varchar(200)
DECLARE @un varchar(200)
DECLARE @ut varchar(200)
DECLARE @sd varchar(200)
DECLARE @pn varchar(200)
DECLARE @sn varchar(200)
DECLARE @on varchar(200)
DECLARE @pd varchar(200)
DECLARE @sdmax int
DECLARE @pnmax int
DECLARE @snmax int
DECLARE @onmax int
DECLARE @pdmax int
DECLARE @unmax int
DECLARE @rnmax int
DECLARE @utmax int
DECLARE @outputtype int

SET @outputtype = 1 -- 1=columnar 2=assignment statements

CREATE TABLE #rolememberdummy
(ServerRole varchar(100),
MemberName varchar(150),
MemberSID varchar(2000)
)
CREATE TABLE #dummyDBPerms
( StateDesc varchar(200),
PermName varchar(200),
SchemaName varchar(200),
ObjectName varchar(200),
UserName varchar(200),
ObjectType varchar(200),
UserType varchar(200)
)


-- Security Audit
INSERT INTO #rolememberdummy
EXEC sp_helpsrvrolemember 'sysadmin'
INSERT INTO #rolememberdummy
EXEC sp_helpsrvrolemember 'securityadmin'
INSERT INTO #rolememberdummy
EXEC sp_helpsrvrolemember 'serveradmin'
INSERT INTO #rolememberdummy
EXEC sp_helpsrvrolemember 'dbcreator'
INSERT INTO #rolememberdummy
EXEC sp_helpsrvrolemember 'diskadmin'
INSERT INTO #rolememberdummy
EXEC sp_helpsrvrolemember 'processadmin'
INSERT INTO #rolememberdummy
EXEC sp_helpsrvrolemember 'setupadmin'
INSERT INTO #rolememberdummy
EXEC sp_helpsrvrolemember 'bulkadmin'



SET @col1nm = 'Role'
SET @col1len = 20
SET @col2nm = ''
SET @col2len = 8
SET @col3nm = 'Member Name'
SET @col3len = 30
PRINT @col1nm + SPACE(@col1len-len(@col1nm)) + SPACE(@col2len) + @col3nm
PRINT REPLICATE('=',@col1len) + SPACE(@col2len) + REPLICATE('=',@col3len)






--SELECT CONVERT(varchar(30),ServerRole) as ServerRole, CONVERT(varchar(30),MemberName) AS MemberName FROM #rolememberdummy
DECLARE backupFiles CURSOR FOR
SELECT ServerRole, MemberName FROM #rolememberdummy

OPEN backupFiles

-- Loop through all the files for the database
FETCH NEXT FROM backupFiles INTO @sr, @mn

WHILE @@FETCH_STATUS = 0
BEGIN
SET @col1nm = @sr
SET @col1len = 20
SET @col2nm = ''
SET @col2len = 8
SET @col3nm = @mn
SET @col3len = 30
PRINT @col1nm + SPACE(@col1len-len(@col1nm)) + SPACE(@col2len) + @col3nm


FETCH NEXT FROM backupFiles INTO @sr, @mn
END

CLOSE backupFiles
DEALLOCATE backupFiles

DROP TABLE #rolememberdummy
PRINT ' '
PRINT ' '
PRINT '==========================================================================================================='
PRINT ' Information By Database'
PRINT ' '
PRINT ' '

CREATE TABLE #DummyDBDesc
( RecID int IDENTITY NOT NULL,
ServerName varchar(128) NULL,
DBName varchar(100) NULL,
RecoveryModel varchar(10) NULL,
CompatibilityLevel varchar(30) NULL,
ReadWriteDesc varchar(10) NULL
)
CREATE TABLE #dummyDBRoles
( RoleName varchar(200),
UserName varchar(200),
UserType varchar(200)
)
CREATE TABLE #dummyDBUsers
( UserName varchar(200),
UserType varchar(200)
)
INSERT INTO #DummyDBDesc
select CONVERT(varchar(128),@@servername) AS ServerName, CONVERT(varchar(100),name) as DBName, CONVERT(varchar(10),recovery_model_desc) as RecoveryModel, --database_id,
CASE compatibility_level
WHEN 80 THEN CONVERT(varchar(4),compatibility_level) + ' - SQL 2000 *'
WHEN 90 THEN CONVERT(varchar(4),compatibility_level) + ' - SQL 2005'
WHEN 100 THEN CONVERT(varchar(4),compatibility_level) + ' - SQL 2008'
WHEN 105 THEN CONVERT(varchar(4),compatibility_level) + ' - SQL 2008 R2'
WHEN 110 THEN CONVERT(varchar(4),compatibility_level) + ' - Denali'
ELSE CONVERT(varchar(4),compatibility_level)
END AS CompatibilityLevel,
CASE is_read_only
WHEN 0 THEN CONVERT(varchar(10),'RW')
ELSE CONVERT(varchar(10),'R')
END as ReadWriteDesc
FROM sys.databases
WHERE name NOT IN('tempdb','master','msdb','model') and name NOT LIKE '%ReportServer%'
--AND name = 'PRO_Clarity'
ORDER BY name



DECLARE backupFiles CURSOR FOR
SELECT DBName, RecoveryModel, CompatibilityLevel, ReadWriteDesc FROM #DummyDBDesc ORDER BY DBName
OPEN backupFiles

DECLARE @dbn varchar(100)
DECLARE @rm varchar(10)
DECLARE @cl varchar(30)
DECLARE @rwd varchar(10)


-- Loop through all the files for the database
FETCH NEXT FROM backupFiles INTO @dbn, @rm, @cl, @rwd

WHILE @@FETCH_STATUS = 0
BEGIN

PRINT 'Database Name : ' + @dbn
PRINT 'Recovery Model : ' + @rm
PRINT 'Compatibility Level: ' + @cl
PRINT 'Read/Write : ' + @rwd
PRINT ' '
PRINT ' '


/* ================================================================================================================================================================= */
/* Database User Information */

--Start with a clean table to load the values
TRUNCATE TABLE #dummyDBUsers

-- Get roles for this database and load into the temp table
SET @cmd = 'USE [' + @dbn + ']; INSERT INTO #dummyDBUsers SELECT CONVERT(varchar(100),name) AS UserName, CONVERT(varchar(100),type_desc) as UserType FROM sys.database_principals WHERE (type = ''S'' OR type = ''U'' OR type = ''G'') AND is_fixed_role = 0 AND (name NOT IN (''guest'',''dbo'',''INFORMATION_SCHEMA'',''sys''))'
--PRINT @cmd
EXEC (@cmd)





--Get the length of the longest occurance of the columns
SELECT @unmax = ISNULL(MAX(len(UserName)),0) FROM #dummyDBUsers
SELECT @utmax = ISNULL(MAX(len(UserType)),0) FROM #dummyDBUsers

--Set some minimum values so column doesn't print short
if @unmax < 25 SET @unmax = 25
if @utmax < 25 SET @utmax = 25

--Set and print the column headings for the role information
SET @col1nm = 'UserName'
SET @col1len = @unmax
SET @col2nm = ''
SET @col2len = 5
SET @col3nm = 'UserType'
SET @col3len = @utmax
PRINT ' '
PRINT SPACE(10) + @col1nm + SPACE(@col1len-len(@col1nm)) + SPACE(@col2len) + @col3nm + SPACE(@col3len-len(@col3nm))
PRINT SPACE(10) + REPLICATE('=',@col1len) + SPACE(@col2len) + REPLICATE('=',@col3len)

DECLARE backupFiles2 CURSOR FOR
SELECT UserName, UserType FROM #dummyDBUsers ORDER BY UserName

OPEN backupFiles2

-- Loop through all the files for the database
FETCH NEXT FROM backupFiles2 INTO @un, @ut

WHILE @@FETCH_STATUS = 0
BEGIN
--Set and print the row details for the role information
SET @col1nm = SUBSTRING(@un,1,@unmax)
SET @col3nm = SUBSTRING(@ut,1,@utmax)

PRINT SPACE(10) + @col1nm + SPACE(@col1len-len(@col1nm)) + SPACE(@col2len) + @col3nm + SPACE(@col3len-len(@col3nm))

FETCH NEXT FROM backupFiles2 INTO @un, @ut
END

CLOSE backupFiles2
DEALLOCATE backupFiles2

PRINT ' '
PRINT ' '

/* ================================================================================================================================================================= */
/* Role Information */

--Start with a clean table to load the values
TRUNCATE TABLE #dummyDBRoles

-- Get roles for this database and load into the temp table
SET @cmd = 'USE [' + @dbn + ']; INSERT INTO #dummyDBRoles select CONVERT(varchar(200),roles.name) AS RoleName, CONVERT(varchar(200),members.name) AS UserName, CONVERT(varchar(200),members.type_desc) AS UserType from sys.database_principals members inner join sys.database_role_members drm on members.principal_id = drm.member_principal_id inner join sys.database_principals roles on drm.role_principal_id = roles.principal_id where members.name <> ''dbo'' ORDER BY members.name, roles.name'
--PRINT @cmd
EXEC (@cmd)

-- Now add in any roles that are present in the database that do not have anyone assigned to them (those that are already in the temp table)
SET @cmd = 'USE [' + @dbn + ']; INSERT INTO #dummyDBRoles SELECT CONVERT(varchar(200),name) AS RoleName, ''--none--'' As UserName, '''' AS UserType FROM sys.database_principals SQL_Latin1_General_CP1_CI_AS WHERE type = ''R'' and is_fixed_role = 0 and name <> ''public'' AND (name NOT IN (SELECT RoleName FROM #dummyDBRoles))'
--PRINT @cmd
EXEC (@cmd)

--Get the length of the longest occurance of the columns
SELECT @rnmax = ISNULL(MAX(len(RoleName)),0) FROM #dummyDBRoles
SELECT @unmax = ISNULL(MAX(len(UserName)),0) FROM #dummyDBRoles
SELECT @utmax = ISNULL(MAX(len(UserType)),0) FROM #dummyDBRoles

--Set some minimum values so column doesn't print short
if @rnmax < 25 SET @rnmax = 25
if @unmax < 25 SET @unmax = 25
if @utmax < 25 SET @utmax = 25

--Set and print the column headings for the role information
SET @col1nm = 'RoleName'
SET @col1len = @rnmax
SET @col2nm = ''
SET @col2len = 5
SET @col3nm = 'UserName'
SET @col3len = @unmax
SET @col4nm = ''
SET @col4len = 5
SET @col5nm = 'UserType'
SET @col5len = @utmax
PRINT ' '
PRINT SPACE(10) + @col1nm + SPACE(@col1len-len(@col1nm)) + SPACE(@col2len) + @col3nm + SPACE(@col3len-len(@col3nm)) + SPACE(@col4len) + @col5nm + SPACE(@col5len-len(@col5nm))
PRINT SPACE(10) + REPLICATE('=',@col1len) + SPACE(@col2len) + REPLICATE('=',@col3len) + SPACE(@col4len) + REPLICATE('=',@col5len)

-- Print the script to set the database context
if @outputtype = 2
BEGIN
PRINT 'USE ' + @dbn
PRINT 'GO'
PRINT ' '
END

-- Now loop through the roles
DECLARE backupFiles2 CURSOR FOR
SELECT RoleName, UserName, UserType FROM #dummyDBRoles ORDER BY RoleName

OPEN backupFiles2

-- Loop through all the files for the database
FETCH NEXT FROM backupFiles2 INTO @rn, @un, @ut

WHILE @@FETCH_STATUS = 0
BEGIN
--Set and print the row details for the role information
SET @col1nm = SUBSTRING(@rn,1,@rnmax)
SET @col3nm = SUBSTRING(@un,1,@unmax)
SET @col5nm = SUBSTRING(@ut,1,@utmax)
if @outputtype = 1
PRINT SPACE(10) + @col1nm + SPACE(@col1len-len(@col1nm)) + SPACE(@col2len) + @col3nm + SPACE(@col3len-len(@col3nm)) + SPACE(@col4len) + @col5nm + SPACE(@col5len-len(@col5nm))
if @outputtype = 2
BEGIN
if @col3nm <> '--none--'
PRINT 'exec sp_addrolemember [' + @col1nm + '], [' + @col3nm + '] --Usertype= ' + @col5nm
else
PRINT SPACE(10) + @col1nm + SPACE(@col1len-len(@col1nm)) + SPACE(@col2len) + @col3nm + SPACE(@col3len-len(@col3nm)) + SPACE(@col4len) + @col5nm + SPACE(@col5len-len(@col5nm))
END

FETCH NEXT FROM backupFiles2 INTO @rn, @un, @ut
END

CLOSE backupFiles2
DEALLOCATE backupFiles2

PRINT ' '
PRINT ' '


/* ================================================================================================================================================================= */
/* Object-Level Permissions Information */
--Start with a clean table to load the values
TRUNCATE TABLE #dummyDBPerms

-- Get permissions for this database and load into the temp table
-- I'm sure some of this part came from elsewhere. My appologies to the originator.
SET @cmd = 'USE [' + @dbn + ']; INSERT INTO #dummyDBPerms '
SET @cmd = @cmd + 'select p.state_desc, p.permission_name, s.name, o.name, u.name, CASE o.type WHEN ''P'' THEN ''SPROC''
WHEN ''V'' THEN ''View''
WHEN ''U'' THEN ''Table''
WHEN ''FN'' THEN ''Function (scaler)''
WHEN ''TF'' THEN ''Function (table-valued)''
ELSE o.type_desc END AS ObjectType,
CONVERT(varchar(200),u.type_desc) AS UserType
from sys.database_permissions p
inner join sys.objects o on p.major_id = o.object_id
inner join sys.schemas s on s.schema_id = o.schema_id
inner join sys.database_principals u on p.grantee_principal_id = u.principal_id
ORDER BY o.type, o.name collate Latin1_general_CI_AS, u.name collate Latin1_general_CI_AS'
--PRINT @cmd
EXEC (@cmd)

--Get the length of the longest occurance of each of the columns
SELECT @sdmax = ISNULL(MAX(len(StateDesc)),0) FROM #dummyDBPerms
SELECT @pnmax = ISNULL(MAX(len(PermName)),0) FROM #dummyDBPerms
SELECT @snmax = ISNULL(MAX(len(SchemaName)),0) FROM #dummyDBPerms
SELECT @onmax = ISNULL(MAX(len(ObjectName)),0) FROM #dummyDBPerms
SELECT @unmax = ISNULL(MAX(len(UserName)),0) FROM #dummyDBPerms
SELECT @pdmax = ISNULL(MAX(len(ObjectType)),0) FROM #dummyDBPerms
SELECT @utmax = ISNULL(MAX(len(UserType)),0) FROM #dummyDBPerms

--Set some minimum values so column doesn't print short
if @sdmax < 15 SET @sdmax = 15
if @pnmax < 15 SET @pnmax = 15
if @snmax < 10 SET @snmax = 10
if @onmax < 15 SET @onmax = 15
if @unmax < 15 SET @unmax = 15
if @pdmax < 15 SET @pdmax = 15 --ObjectType
if @utmax < 15 SET @utmax = 15 --UserType

--Set and print the column headings for the permissions information
SET @col1nm = 'StateDesc'
SET @col1len = @sdmax
SET @col2nm = ''
SET @col2len = 5
SET @col3nm = 'PermName'
SET @col3len = @pnmax
SET @col4nm = ''
SET @col4len = 5
SET @col5nm = 'Schema'
SET @col5len = @snmax
SET @col6nm = ''
SET @col6len = 5
SET @col7nm = 'Object'
SET @col7len = @onmax
SET @col8nm = ''
SET @col8len = 5
SET @col9nm = 'User'
SET @col9len = @unmax
SET @col10nm = ''
SET @col10len = 5
SET @col11nm = 'ObjectType'
SET @col11len = @pdmax
SET @col12nm = ''
SET @col12len = 5
SET @col13nm = 'UserType'
SET @col13len = @utmax

PRINT ' '
PRINT SPACE(10) + @col1nm + SPACE(@col1len-len(@col1nm)) + SPACE(@col2len) + @col3nm + SPACE(@col3len-len(@col3nm)) + SPACE(@col4len)+ @col5nm + SPACE(@col5len-len(@col5nm)) + SPACE(@col6len)+ @col7nm + SPACE(@col7len-len(@col7nm)) + SPACE(@col8len) + @col9nm + SPACE(@col9len-len(@col9nm)) + SPACE(@col10len) + @col11nm + SPACE(@col11len-len(@col11nm)) + SPACE(@col12len) + @col13nm + SPACE(@col13len-len(@col13nm))
PRINT SPACE(10) + REPLICATE('=',@col1len) + SPACE(@col2len) + REPLICATE('=',@col3len) + SPACE(@col4len) + REPLICATE('=',@col5len) + SPACE(@col6len) + REPLICATE('=',@col7len) + SPACE(@col8len) + REPLICATE('=',@col9len) + SPACE(@col10len) + REPLICATE('=',@col11len) + SPACE(@col12len) + REPLICATE('=',@col13len)

--Loop through the permissions for this database and format and print them
DECLARE backupFiles2 CURSOR FOR
SELECT StateDesc,PermName,SchemaName,ObjectName,UserName,ObjectType,UserType FROM #dummyDBPerms ORDER BY Schemaname,ObjectName,UserName

OPEN backupFiles2

-- Loop through all the files for the database
FETCH NEXT FROM backupFiles2 INTO @sd, @pn, @sn, @on, @un, @pd, @ut

WHILE @@FETCH_STATUS = 0
BEGIN
--Set and print the row details for the permissions information
SET @col1nm = SUBSTRING(@sd,1,@sdmax)
SET @col3nm = SUBSTRING(@pn,1,@pnmax)
SET @col5nm = SUBSTRING(@sn,1,@snmax)
SET @col7nm = SUBSTRING(@on,1,@onmax)
SET @col9nm = SUBSTRING(@un,1,@unmax)
SET @col11nm = SUBSTRING(@pd,1,@pdmax)
SET @col13nm = SUBSTRING(@ut,1,@utmax)

--print the detail record for the permissions
if @outputtype = 1
PRINT SPACE(10) + @col1nm + SPACE(@col1len-len(@col1nm)) + SPACE(@col2len) + @col3nm + SPACE(@col3len-len(@col3nm)) + SPACE(@col4len)+ @col5nm + SPACE(@col5len-len(@col5nm)) + SPACE(@col6len)+ @col7nm + SPACE(@col7len-len(@col7nm)) + SPACE(@col8len) + @col9nm + SPACE(@col9len-len(@col9nm)) + SPACE(@col10len) + @col11nm + SPACE(@col11len-len(@col11nm)) + SPACE(@col12len) + @col13nm + SPACE(@col13len-len(@col13nm))
if @outputtype = 2
PRINT @col1nm + ' ' + @col3nm + ' ON [' + @col5nm + '].[' + @col7nm + '] TO [' + @col9nm + '] --ObjectType=' + @col11nm + ' UserType=' + @col13nm


FETCH NEXT FROM backupFiles2 INTO @sd, @pn, @sn, @on, @un, @pd,@ut
END

CLOSE backupFiles2
DEALLOCATE backupFiles2

PRINT ' '
PRINT ' '

PRINT '==========================================================================================================='

--Get the next database name and info to use in the database loop
FETCH NEXT FROM backupFiles INTO @dbn, @rm, @cl, @rwd
END

CLOSE backupFiles
DEALLOCATE backupFiles

/* =============================================================================================== */
--Dispose of the temporary tables
DROP TABLE #DummyDBDesc
DROP TABLE #dummyDBRoles
DROP TABLE #dummyDBUsers
DROP TABLE #dummyDBPerms

SET NOCOUNT OFF