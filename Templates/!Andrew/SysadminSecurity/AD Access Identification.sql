------------------------------------------------------------
-- The SQLBlimp AD Access Identification Script Version 2.5
-- By John F. Tamburo 2016-06-30
-- Feel free to use this - Freely given to the SQL community
------------------------------------------------------------
set nocount on;
declare @ctr nvarchar(max) = '', @AcctName sysname = '', @x int = 1

-- Create a table to store xp_logininfo commands
-- We have to individually execute them in case the login no longer exists

create table #ExecuteQueue(
	AcctName sysname
	,CommandToRun nvarchar(max)
	,RowID int identity(1,1)
);

-- Create a command list for windows-based SQL Logins
insert into #ExecuteQueue(AcctName,CommandToRun)
SELECT 
	[name]
	,CONVERT(NVARCHAR(max),'INSERT INTO #LoginsList EXEC xp_logininfo ''' + [name] + ''', ''all''; --insert group information' + CHAR(13) + CHAR(10)
		+ CASE 
			WHEN [TYPE] = 'G' THEN ' INSERT INTO #LoginsList EXEC xp_logininfo  ''' + [name] + ''', ''members''; --insert member information'  + CHAR(13) + CHAR(10)
            else '-- ' + rtrim([name]) + ' IS NOT A GROUP BABY!' + CHAR(13) + CHAR(10)
        END) as CMD_TO_RUN
FROM sys.server_principals 
WHERE 1=1
and TYPE IN ('U','G')    -- *Windows* Users and Groups.
and name not like '%##%' -- Eliminate Microsoft 
and name not like 'NT SERVICE\%' -- xp_logininfo does not work with NT SERVICE accounts
ORDER BY name, type_desc;

-- Create the table that the commands above will fill.
create table #LoginsList(
       [Account Name] nvarchar(128),
       [Type] nvarchar(128),
       [Privilege] nvarchar(128),
       [Mapped Login Name] nvarchar(128),
       [Permission Path] nvarchar(128));

-- Jeff Moden: I got rid of the cursor!  Be Proud!  
-- I couldn't get rid of the loop since I have to error handle each SQL command for accurate results. :(
set @x=1

while @x=1
begin
	select 
	top 1 
		@ctr = CommandToRun
	from #ExecuteQueue
	order by RowID;
	IF @@ROWCOUNT = 0
		set @X=0
	ELSE
	BEGIN
		BEGIN TRY
			print @ctr
			EXEC sp_executesql @ctr
		END TRY
		BEGIN CATCH
			print ERROR_MESSAGE() + CHAR(13) + CHAR(10);
			IF ERROR_MESSAGE() like '%0x534%' -- Windows SQL Login no longer in AD
			BEGIN
				print '0x534 Logic'
				insert into #LoginsList([Account Name],[Type],[Privilege],[Mapped Login Name],[Permission Path])
				select @AcctName AccountName,'WINDOWS_USER','DELETED Windows User',@AcctName MappedLogin,@AcctName PermissionPath
			END
			ELSE
				print ERROR_MESSAGE();
		END CATCH;
		with CTE as 
		(
			Select 
			top 1 
				RowId 
			from #ExecuteQueue
			order by RowID
		)
		delete from CTE;
	END;
	Print '-------------------------------'
END;


--add SID
alter table #LoginsList add sid varbinary(85);

-- Add SQL Logins to the result
insert into #LoginsList([Account Name],[Type],[Privilege],[Mapped Login Name],[Permission Path],[sid])
select 
	[name] AccountName
	,(case 
		when [type] = 'S' then 'SQL_USER' 
		when [type] = 'U' then 'WINDOWS_USER' 
		when [type] = 'G' then 'WINDOWS_GROUP' 
		else '?WTF' 
	  END)
	,'user'
	,[name] MappedLogin
	,[name] PermissionPath
	,[sid]
FROM sys.server_principals 
WHERE 1=1
and (TYPE = 'S'		     -- SQL Server Logins only
and name not like '%##%') -- Eliminate Microsoft 
or (TYPE in('U','G') /*and [name] like 'NT SERVICE\%'*/) -- capture NT Service information
ORDER BY [name];

-- Get Server Roles into the mix
-- Add column to table
alter table #LoginsList add Server_Roles nvarchar(max);


-- Fill column with server roles
update LL 
set 
	Server_Roles = ISNULL(STUFF((SELECT ', ' + CONVERT(VARCHAR(500),role.name)
					FROM sys.server_role_members
					JOIN sys.server_principals AS role
						ON sys.server_role_members.role_principal_id = role.principal_id
					JOIN sys.server_principals AS member
						ON sys.server_role_members.member_principal_id = member.principal_id
					WHERE member.name= (case when [Permission Path] is not null then [Permission Path] else [Account Name] end)
							FOR XML PATH('')),1,1,''),'public')
from #LoginsList LL;

-- Create a table to hold the users of each database.
create table #DB_Users(
	DBName sysname
	, UserName sysname
	, LoginType sysname
	, AssociatedRole varchar(max)
	,create_date datetime
	,modify_date datetime
	,[sid] varbinary(85)
)

-- Iterate the each database for its users and store them in the table.
INSERT #DB_Users
EXEC sp_MSforeachdb
'
use [?]
SELECT ''?'' AS DB_Name,
ISNULL(case prin.name when ''dbo'' then (select SUSER_SNAME(owner_sid) from master.sys.databases where name =''?'') else prin.name end,'''') AS UserName,
prin.type_desc AS LoginType,
isnull(USER_NAME(mem.role_principal_id),'''') AS AssociatedRole ,create_date,modify_date, [sid]
FROM sys.database_principals prin
LEFT OUTER JOIN sys.database_role_members mem ON prin.principal_id=mem.member_principal_id
WHERE prin.sid IS NOT NULL 
and prin.sid NOT IN (0x00) 
and prin.is_fixed_role <> 1 
AND prin.name is not null
AND prin.name NOT LIKE ''##%'''

-- Refine the user permissions into a concatenated field by DB and user
SELECT
	dbname
	,username 
	,[sid]
	,logintype 
	,create_date 
	,modify_date 
	,STUFF((SELECT ', ' + CONVERT(VARCHAR(500),associatedrole)
		FROM #DB_Users user2
		WHERE user1.DBName=user2.DBName 
		AND user1.UserName=user2.UserName
		FOR XML PATH('')),1,1,'') AS Permissions_user
into #UserPermissions
FROM #DB_Users user1
where logintype != 'DATABASE_ROLE'
GROUP BY
	dbname
	,username 
	,[sid]
	,logintype 
	,create_date 
	,modify_date
ORDER BY DBName,username;

-- Report out the results
with CTE as
(
Select 
	DISTINCT
	LL.[Account Name]
	,LL.[sid]
	,@@SERVERNAME as [Database Server]
	,(case when UP.dbname is null then '[none]' else UP.DBName end) as [Database Name]
	,( case when ll.Type = 'user' then 'WINDOWS_USER' else ll.type end) as LoginType
	,LL.Privilege
	,LL.[Server_Roles]
	,LL.[Permission Path]
	,UP.Permissions_user as [User Privileges]
from #LoginsList LL
left join #UserPermissions UU
	on LL.[Account Name] = UU.UserName
left join #UserPermissions UP
	on (LL.[sid] = UP.[sid] OR ((LL.SID is null) and LL.[Permission Path] = UP.[UserName]))
-- Comment out the where clause to see all logins that have no database users
-- and their server roles.
-- where exists(select 1 from #LoginsList U2 where U2.[sid] = UP.[sid])
union all
-- orphaned users
select 
	UserName as [Account Name]
	,A.[sid]
	,@@SERVERNAME as [Database Server]
	,DBName as [Database Name]
	,LoginType
	,'ORPHANED USER NO LOGIN' as Privilege
	,'NONE' as [Server_Roles]
	,null as [Permission Path]
	,null as [User Privileges]
from #db_Users A
where 1=1
and A.LoginType != 'database_role'
--and A.LoginType != 'windows_group' -- groups no logins???
and UserName not like 'MS_%' -- no internal users
and not exists(select 1 from #LoginsList B where A.[sid] = B.[sid])
)
select 
	distinct
	* 
from CTE 
where 1=1
--and [LoginType] != 'Windows_Group'
--and [sid] is not null
and ([Permission Path] is not null or ([Permission Path] is null and [Privilege] like 'orphan%'))
order by 
	[Account Name]
	,[sid]
	,[Database Name];

-- Clean up my mess
drop table #ExecuteQueue;
drop table #LoginsList;
drop table #DB_Users;
drop table #UserPermissions;