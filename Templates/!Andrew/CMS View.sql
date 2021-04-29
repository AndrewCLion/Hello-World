SELECT DISTINCT grandparents.name AS 'Grandparent Group Name', parents.name AS 'Parent Group Name', groups.name AS 'Server Group Name'
     ,svr.server_name AS 'Server Name'
FROM msdb.dbo.sysmanagement_shared_server_groups_internal grandparents 
INNER JOIN msdb.dbo.sysmanagement_shared_server_groups_internal parents 
 ON grandparents.server_group_id = parents.parent_id 
INNER JOIN msdb.dbo.sysmanagement_shared_server_groups_internal groups 
 ON parents.server_group_id = groups.parent_id 
INNER JOIN msdb.dbo.sysmanagement_shared_registered_servers_internal svr
 ON groups.server_group_id = svr.server_group_id;
