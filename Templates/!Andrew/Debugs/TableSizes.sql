DECLARE @PageSize AS BIGINT
SELECT @PageSize = LOW/1024.0 FROM MASTER.DBO.SPT_VALUES WHERE NUMBER=1 AND TYPE='E'
SELECT 
    t.NAME AS TableName,
    s.Name AS SchemaName,
    p.rows AS [Row Count],
    SUM(a.total_pages) * @PageSize AS [Total Space (KB)], 
    SUM(a.used_pages) * @PageSize AS [Used Space (KB)], 
    (SUM(a.total_pages) - SUM(a.used_pages)) * @PageSize AS [Unused Space (KB)]
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
GROUP BY 
    t.Name, s.Name, p.Rows
ORDER BY 
    t.Name
------------------------
--SELECT	OBJECT_NAME(i.object_id) AS [Table Name], s.name as SchemaName, CONVERT(numeric(18, 3), CONVERT(numeric, 
--        @PageSize * SUM(a.used_pages - CASE WHEN a.type <> 1 THEN a.used_pages WHEN p.index_id < 2 THEN a.data_pages ELSE 0 END)) / 1024) 
--        AS [Data Space Used (In Mbs)], CONVERT(numeric(18, 3), CONVERT(numeric(18, 3), 
--        @PageSize * SUM(CASE WHEN a.type <> 1 THEN a.used_pages WHEN p.index_id < 2 THEN a.data_pages ELSE 0 END)) / 1024) AS [Index Space Used  (In Mbs)], 
--        SUM(CASE WHEN p.index_id = 1 AND a.type = 1 THEN p.rows ELSE 0 END) AS [Total No of Rows]
--FROM	sys.indexes AS i INNER JOIN
--		sys.partitions AS p ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN
--		sys.allocation_units AS a ON a.container_id = p.partition_id LEFT OUTER JOIN
--		sys.tables AS t ON i.object_id = t.object_id LEFT OUTER JOIN 
--		sys.schemas s ON t.schema_id = s.schema_id
--WHERE        (t.type = 'U')
--GROUP BY OBJECT_NAME(i.object_id), s.name 
--ORDER BY [Table Name]
---------------------
--select * from sys.tables
--EXEC sp_spaceused
---------------------


