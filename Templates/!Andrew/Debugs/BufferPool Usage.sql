--SELECT * FROM sys.dm_os_performance_counters WHERE object_name LIKE '%buffer%man%'  OR [object_name] LIKE '%batch%' OR counter_name LIKE '%batch%';

--SELECT total_physical_memory_kb, 
--		available_physical_memory_kb, 
--		total_page_file_kb, 
--		available_page_file_kb, 
--		system_memory_state_desc 
--FROM sys.dm_os_sys_memory WITH (NOLOCK) OPTION (RECOMPILE);

-- Note: querying sys.dm_os_buffer_descriptors
-- requires the VIEW_SERVER_STATE permission.
DECLARE @total_buffer INT;

SELECT @total_buffer = cntr_value
   FROM sys.dm_os_performance_counters 
   WHERE (RTRIM([object_name]) LIKE '%Buffer Manager'
   AND counter_name = 'Total Pages')
   ;

WITH src AS
(
   SELECT 
       database_id, db_buffer_pages = COUNT_BIG(*)
       FROM sys.dm_os_buffer_descriptors
       --WHERE database_id BETWEEN 5 AND 32766
       GROUP BY database_id
)
SELECT
   [db_name] = CASE [database_id] WHEN 32767 
       THEN 'Resource DB' 
       ELSE DB_NAME([database_id]) END,
   db_buffer_pages,
   db_buffer_MB = db_buffer_pages / 128,
   db_buffer_percent = CONVERT(DECIMAL(6,3), 
       db_buffer_pages * 100.0 / @total_buffer)
FROM src
ORDER BY db_buffer_MB DESC;

SELECT CAST(COUNT(*) * 8 / 1024.0 AS NUMERIC(10, 2)) AS CachedDataMB , 
CASE database_id WHEN 32767 THEN 'ResourceDb' ELSE DB_NAME(database_id) END AS DatabaseName 
FROM sys.dm_os_buffer_descriptors 
GROUP BY DB_NAME(database_id) , database_id 
ORDER BY 1 DESC;

SELECT 
    CASE database_id WHEN 32767 THEN 'ResourceDb' ELSE DB_NAME(database_id) END AS [Database Name],
	CAST(COUNT(*) / 128.0 AS DECIMAL (10,2))  AS [Cached Size (MB)] --  / 128.0 => * 8/1024.0
FROM sys.dm_os_buffer_descriptors WITH (NOLOCK)
--WHERE database_id not in (1,3,4) -- system databases
--AND database_id <> 32767 -- ResourceDB
GROUP BY database_id, DB_NAME(database_id)
ORDER BY [Cached Size (MB)] DESC OPTION (RECOMPILE);

select 
    name
    ,sum(pages_allocated_count)/128.0 [Cache Size (MB)]
    ,count(pages_allocated_count) [Allocations]
from sys.dm_os_memory_cache_entries
where pages_allocated_count > 0
group by name
order by sum(pages_allocated_count) desc

--select pages_allocated_count/128.0 AS [Cache Size (MB)], *
--from sys.dm_os_memory_cache_entries
--where pages_allocated_count != 0
--ORDER BY pages_allocated_count DESC

-- https://support.microsoft.com/en-us/kb/271624
--DBCC MEMORYSTATUS