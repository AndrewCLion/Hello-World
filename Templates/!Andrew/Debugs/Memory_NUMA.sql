SELECT	'Server Info' AS FindingsGroup ,
		'Hardware - NUMA Config' AS Finding ,
		'Node: ' + CAST(n.node_id AS NVARCHAR(10)) + ' State: ' + node_state_desc
			+ ' Online schedulers: ' + CAST(n.online_scheduler_count AS NVARCHAR(10)) + ' Processor Group: ' + CAST(n.processor_group AS NVARCHAR(10))
			+ ' Memory node: ' + CAST(n.memory_node_id AS NVARCHAR(10)) + ' Memory VAS Reserved GB: ' + CAST(CAST((m.virtual_address_space_reserved_kb / 1024.0 / 1024) AS INT) AS NVARCHAR(100))
FROM sys.dm_os_nodes n
INNER JOIN sys.dm_os_memory_nodes m ON n.memory_node_id = m.memory_node_id
WHERE n.node_state_desc NOT LIKE '%DAC%'
ORDER BY n.node_id
GO
-- http://mssqlwiki.com/sqlwiki/sql-performance/troubleshooting-sql-server-memory/
--
IF (CONVERT(float , SUBSTRING(CAST(SERVERPROPERTY('ProductVersion') AS varchar(10)),1,4) )>10.5)
--OR ((CONVERT(float , SUBSTRING(CAST(SERVERPROPERTY('ProductVersion') AS varchar(10)),1,4) )=10.5) AND (CONVERT(float , SUBSTRING(CAST(SERVERPROPERTY('ProductVersion') AS varchar(10)),4,5) )>50.25))
	SELECT memory_node_id as node, virtual_address_space_reserved_kb/(1024) as VAS_reserved_mb,
			virtual_address_space_committed_kb/(1024) as virtual_committed_mb,
			locked_page_allocations_kb/(1024) as locked_pages_mb,
			pages_kb/(1024) as pages_mb,
			shared_memory_committed_kb/(1024) as shared_memory_mb
	FROM sys.dm_os_memory_nodes
	WHERE memory_node_id != 64
GO
IF (CONVERT(float , SUBSTRING(CAST(SERVERPROPERTY('ProductVersion') AS varchar(10)),1,4) )<=10.5)
	SELECT memory_node_id as node, virtual_address_space_reserved_kb/(1024) as VAS_reserved_mb,
			virtual_address_space_committed_kb/(1024) as virtual_committed_mb,
			locked_page_allocations_kb/(1024) as locked_pages_mb,
			single_pages_kb/(1024) as single_pages_mb,
			multi_pages_kb/(1024) as multi_pages_mb,
			shared_memory_committed_kb/(1024) as shared_memory_mb
	FROM sys.dm_os_memory_nodes
	WHERE memory_node_id != 64
GO
SELECT SERVERPROPERTY('ComputerNamePhysicalNetBIOS')AS ComputerNamePhysicalNetBIOS, name, value, value_in_use--, [description] 
FROM sys.configurations
WHERE name like '%server memory%' AND value <> 0
--ORDER BY name OPTION (RECOMPILE);
GO
--
select * from sys.dm_os_schedulers WHERE status LIKE '%OFFLINE%'