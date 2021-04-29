SELECT * FROM sys.dm_io_virtual_file_stats(2,NULL)
GO
--------------------------------------------------------------------------
--USE [tempdb]
--GO
--ALTER DATABASE tempdb MODIFY FILE (NAME = N'tempdev', SIZE = 10GB)
--ALTER DATABASE tempdb MODIFY FILE (NAME = N'temp2', SIZE = 10GB)
--ALTER DATABASE tempdb MODIFY FILE (NAME = N'tempdb3', SIZE = 10GB)
--ALTER DATABASE tempdb MODIFY FILE (NAME = N'tempdb4', SIZE = 10GB)
--ALTER DATABASE tempdb MODIFY FILE (NAME = N'tempdb5', SIZE = 10GB)
--ALTER DATABASE tempdb MODIFY FILE (NAME = N'tempdb6', SIZE = 10GB)
--ALTER DATABASE tempdb MODIFY FILE (NAME = N'tempdb7', SIZE = 10GB)
--DBCC SHRINKFILE (N'tempdev' , 10000)
--GO
--------------------------------------------------------------------------
SELECT * FROM sys.master_files WHERE database_id=2
GO
--------------------------------------------------------------------------
-- http://technet.microsoft.com/en-us/library/cc966545.aspx
SELECT * 
FROM sys.sysprocesses  
WHERE lastwaittype like 'PAGE%LATCH_%' AND waitresource like '2:%'
--------------------------------------------------------------------------
SELECT 
   session_id,
   wait_type,
   wait_duration_ms,
   blocking_session_id,
   resource_description,
   ResourceType = CASE
   WHEN PageID = 1 OR PageID % 8088 = 0 THEN 'Is PFS Page'
   WHEN PageID = 2 OR PageID % 511232 = 0 THEN 'Is GAM Page'
   WHEN PageID = 3 OR (PageID - 1) % 511232 = 0 THEN 'Is SGAM Page'
       ELSE 'Is Not PFS, GAM, or SGAM page'
   END
FROM (  SELECT  
           session_id,
           wait_type,
           wait_duration_ms,
           blocking_session_id,
           resource_description,
           CAST(RIGHT(resource_description, LEN(resource_description)
           - CHARINDEX(':', resource_description, 3)) AS INT) AS PageID
       FROM sys.dm_os_waiting_tasks
       WHERE wait_type LIKE 'PAGE%LATCH_%'
         AND resource_description LIKE '2:%'
) AS tab; 
--------------------------------------------------------------------------
SELECT
SUM (user_object_reserved_page_count)*8 as usr_obj_kb,
SUM (internal_object_reserved_page_count)*8 as internal_obj_kb,
SUM (version_store_reserved_page_count)*8  as version_store_kb,
SUM (unallocated_extent_page_count)*8 as freespace_kb,
SUM (mixed_extent_page_count)*8 as mixedextent_kb
FROM sys.dm_db_file_space_usage
--------------------------------------------------------------------------
SELECT top 5 * 
FROM sys.dm_db_session_space_usage  
ORDER BY (user_objects_alloc_page_count +
 internal_objects_alloc_page_count) DESC
--------------------------------------------------------------------------
SELECT top 5 * 
FROM sys.dm_db_task_space_usage
ORDER BY (user_objects_alloc_page_count +
 internal_objects_alloc_page_count) DESC
--------------------------------------------------------------------------
SELECT t1.session_id, t1.request_id, t1.task_alloc,
  t1.task_dealloc, t2.sql_handle, t2.statement_start_offset, 
  t2.statement_end_offset, t2.plan_handle
FROM (Select session_id, request_id,
    SUM(internal_objects_alloc_page_count) AS task_alloc,
    SUM (internal_objects_dealloc_page_count) AS task_dealloc 
  FROM sys.dm_db_task_space_usage 
  GROUP BY session_id, request_id) AS t1, 
  sys.dm_exec_requests AS t2
WHERE t1.session_id = t2.session_id
  AND (t1.request_id = t2.request_id)
ORDER BY t1.task_alloc DESC
--------------------------------------------------------------------------
-- http://www.brentozar.com/archive/2011/11/how-tell-when-tempdb-problem-webcast-video/
--Monitoring file space used in TempDB:
SELECT  SUM (user_object_reserved_page_count)*8 as usr_obj_kb,
        SUM (internal_object_reserved_page_count)*8 as internal_obj_kb,
		SUM (version_store_reserved_page_count)*8 as version_store_kb,
		SUM (unallocated_extent_page_count)*8 as freespace_kb,
		SUM (mixed_extent_page_count)*8 as mixedextent_kb
FROM    sys.dm_db_file_space_usage;
--------------------------------------------------------------------------
--Historical information about TempDB usage:
SELECT  top 5 *
FROM    sys.dm_db_task_space_usage
ORDER BY (user_objects_alloc_page_count +
		internal_objects_alloc_page_count) DESC;
--------------------------------------------------------------------------
--Determine which queries are using large amounts of TempDB:
SELECT t1.session_id, t1.request_id, t1.task_alloc,
		t1.task_dealloc, t2.sql_handle, t2.statement_start_offset,
		t2.statement_end_offset, t2.plan_handle
FROM (SELECT session_id, request_id,
             SUM(internal_objects_alloc_page_count) AS task_alloc,
			 SUM(internal_objects_dealloc_page_count) AS task_dealloc
		FROM   sys.dm_db_task_space_usage
	GROUP BY session_id, request_id) AS t1
	JOIN sys.dm_exec_requests AS t2 ON t1.session_id = t2.session_id
	  AND t1.request_id = t2.request_id
ORDER BY t1.task_alloc DESC;
--------------------------------------------------------------------------
