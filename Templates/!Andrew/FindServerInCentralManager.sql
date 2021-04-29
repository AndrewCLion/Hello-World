-- USE in BYYM5Q
-- see also https://www.simple-talk.com/sql/sql-tools/registered-servers-and--central-management-server-stores/
-- Andrew Craven 2014

DECLARE @Name2Find varchar(80) 

SET @Name2Find = 'by-bdcsqlr212'
--SET @Name2Find = 'BY0J5P'

SELECT	ParentParentGroup.name AS ParentParent, ParentGroup.name AS ParentGroup, TheGroup.name AS [Server Group], TheServer.name, TheServer.server_name AS [Server name], 
		ParentParentGroup.description AS [ParentParent Description], ParentGroup.description AS [Parent Description], TheGroup.description AS [Group Description], TheServer.description AS Description 
FROM	BYYM5Q.msdb.dbo.sysmanagement_shared_server_groups_internal AS ParentParentGroup RIGHT OUTER JOIN
		BYYM5Q.msdb.dbo.sysmanagement_shared_server_groups_internal AS ParentGroup ON ParentParentGroup.server_group_id = ParentGroup.parent_id RIGHT OUTER JOIN
		BYYM5Q.msdb.dbo.sysmanagement_shared_server_groups_internal AS TheGroup ON ParentGroup.server_group_id = TheGroup.parent_id LEFT OUTER JOIN
		BYYM5Q.msdb.dbo.sysmanagement_shared_registered_servers_internal AS TheServer ON TheGroup.server_group_id = TheServer.server_group_id
WHERE	(TheGroup.server_type = 0) AND (TheServer.server_name IS NOT NULL) AND (TheServer.name LIKE '%' + @Name2Find + '%')
	OR	(TheGroup.server_type = 0) AND (TheServer.server_name IS NOT NULL) AND (TheServer.server_name LIKE '%' + @Name2Find + '%')
ORDER BY [Server Group], [Server name]