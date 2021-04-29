SELECT o.NAME
	,i.NAME AS [Index Name]
	,STATS_DATE(i.[object_id], i.index_id) AS [Statistics Date]
	,s.auto_created
	,s.no_recompute
	,s.user_created
FROM sys.objects AS o WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK) ON o.[object_id] = i.[object_id]
INNER JOIN sys.stats AS s WITH (NOLOCK) ON i.[object_id] = s.[object_id]
	AND i.index_id = s.stats_id
WHERE o.[type] = 'U'
ORDER BY STATS_DATE(i.[object_id], i.index_id) ASC;

-- The code below requires SQL Server 2008R2 SP2/SQL Server 2012 SP1 to execute
SELECT s.stats_id AS [Stat ID]
	,sc.NAME + '.' + t.NAME AS [Table]
	,s.NAME AS [Statistics]
	,p.last_updated
	,p.rows
	,p.rows_sampled
	,p.modification_counter AS [Mod Count]
FROM sys.stats s
INNER JOIN sys.tables t ON s.object_id = t.object_id
INNER JOIN sys.schemas sc ON t.schema_id = sc.schema_id
OUTER APPLY sys.dm_db_stats_properties(t.object_id, s.stats_id) p
	--where	
	--	sc.name = 'dbo' and t.name = 'Books'

--SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),NULL,NULL,NULL,NULL)
--SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),117575457,NULL,NULL,NULL)

-- Caution, this part of the script can take a long time, also, it will list, pause, list some more, pause, ... and so-on
SELECT
B.name AS TableName
, C.name AS IndexName
, C.fill_factor AS IndexFillFactor
, D.rows AS RowsCount --, D.partition_id, D.partition_number
, A.avg_fragmentation_in_percent
, A.page_count
, A.index_type_desc
, A.alloc_unit_type_desc 
FROM sys.dm_db_index_physical_stats(DB_ID(),NULL,NULL,NULL,NULL) A
INNER JOIN sys.objects B
ON A.object_id = B.object_id
INNER JOIN sys.indexes C
ON B.object_id = C.object_id AND A.index_id = C.index_id
INNER JOIN sys.partitions D
ON B.object_id = D.object_id AND A.index_id = D.index_id
WHERE C.index_id > 0
--AND A.avg_fragmentation_in_percent >30

--SELECT
--    OBJECT_NAME(i.OBJECT_ID) AS TableName,
--    i.name AS TableIndexName, phystat.avg_fragmentation_in_percent
--FROM
--    sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) phystat 
--    INNER JOIN sys.indexes i 
--        ON i.OBJECT_ID = phystat.OBJECT_ID AND i.index_id = phystat.index_id 
----WHERE 
----    phystat.avg_fragmentation_in_percent > 20 
----    AND OBJECT_NAME(i.OBJECT_ID) IS NOT NULL
----ORDER BY phystat.avg_fragmentation_in_percent DESC