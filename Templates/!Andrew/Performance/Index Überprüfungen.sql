--UpdateStatistics
PRINT '######################### Tables with Missing UpdateStats ######################################'
SET NOCOUNT ON
IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%##DBRESULTS%')
	DROP TABLE ##DBRESULTS
CREATE TABLE ##DBRESULTS(InstanceName SYSNAME, DatabaseName SYSNAME, NbOccurrence INT, SchemaName SYSNAME, TableName SYSNAME, ClusteredHeap VARCHAR(10), IndexCount INT, ColumnCount INT, StatCount INT, ApproximateRows BIGINT, RowModCtr BIGINT, schema_id INT, object_id INT)
DECLARE DB_Crs CURSOR STATIC FOR SELECT name FROM sys.databases WHERE source_database_id IS NULL AND name NOT IN ('master', 'model', 'msdb', 'distribution', 'tempdb', 'SSISDB')
DECLARE @DB_Name sysname
DECLARE @SqlCmdTemp NVARCHAR(max)
DECLARE @SqlCmd NVARCHAR(max)
SET @SqlCmdTemp = 
 N'USE [##database_name##];
;WITH StatTables AS(
	SELECT 	so.schema_id AS ''schema_id'',      
             		so.name  AS ''TableName'',
		so.object_id AS ''object_id'',
		CASE indexproperty(so.object_id, dmv.name, ''IsStatistics'') 
                    	WHEN 0 THEN dmv.rows
                    	ELSE (SELECT TOP 1 row_count FROM sys.dm_db_partition_stats ps (NOLOCK) WHERE ps.object_id=so.object_id AND ps.index_id in (1,0))
			END AS ''ApproximateRows'',
			 dmv.rowmodctr AS ''RowModCtr''
	FROM sys.objects so (NOLOCK)
		JOIN sysindexes dmv (NOLOCK) ON so.object_id = dmv.id 
		LEFT JOIN sys.indexes si (NOLOCK) ON so.object_id = si.object_id AND so.type in (''U'',''V'') AND si.index_id  = dmv.indid
	WHERE so.is_ms_shipped = 0
		AND dmv.indid<>0
		AND so.object_id not in (SELECT major_id FROM sys.extended_properties (NOLOCK) WHERE name = N''microsoft_database_tools_support'')
),
StatTableGrouped AS
(
SELECT   TOP 10
	ROW_NUMBER() OVER(ORDER BY TableName) AS seq1, 
	ROW_NUMBER() OVER(ORDER BY TableName DESC) AS seq2,
	TableName,
	cast(Max(ApproximateRows) AS bigint) AS ApproximateRows,
	cast(Max(RowModCtr) AS bigint) AS RowModCtr,
	schema_id,object_id
FROM StatTables st
GROUP BY schema_id,object_id,TableName
HAVING (Max(ApproximateRows) > 500 AND Max(RowModCtr) > (Max(ApproximateRows)*0.2 + 500 ))
)
SELECT
	@@SERVERNAME AS InstanceName,
	''##database_name##'' DatabaseName,
	seq1 + seq2 - 1 AS NbOccurences,
	SCHEMA_NAME(stg.schema_id) AS ''SchemaName'',  
	stg.TableName,
	CASE OBJECTPROPERTY(stg.object_id, ''TableHasClustIndex'')
                   WHEN 1 THEN ''Clustered''
                   WHEN 0 THEN ''Heap''
                   ELSE ''Indexed View''
             END AS ClusteredHeap,
	CASE objectproperty(stg.object_id, ''TableHasClustIndex'')
                    WHEN 0 THEN (SELECT count(*) FROM sys.indexes i (NOLOCK) where i.object_id= stg.object_id) - 1
                    ELSE (SELECT count(*) FROM sys.indexes i  (NOLOCK) where i.object_id= stg.object_id)
    	END AS IndexCount,
	(SELECT count(*) FROM sys.columns c (NOLOCK) WHERE c.object_id = stg.object_id ) AS ColumnCount ,
	(SELECT count(*) FROM sys.stats s (NOLOCK) WHERE s.object_id = stg.object_id) AS StatCount ,
	stg.ApproximateRows,
	stg.RowModCtr,
	stg.schema_id,
	stg.object_id
FROM StatTableGrouped stg'

OPEN DB_Crs
FETCH NEXT FROM DB_Crs INTO @DB_Name
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SqlCmd = REPLACE(@SqlCmdTemp, '##database_name##', @DB_Name)
	INSERT INTO ##DBRESULTS
	EXEC (@SqlCmd)
	FETCH NEXT FROM DB_Crs INTO @DB_Name
END
CLOSE DB_Crs
DEALLOCATE DB_Crs
SELECT * FROM ##DBRESULTS
IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%##DBRESULTS%')
	DROP TABLE ##DBRESULTS
SET NOCOUNT OFF
go
-- Foreign keys
PRINT '######################### Foreign Keys without supp. index ######################################'
SET NOCOUNT ON
IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%##DBRESULTS%')
	DROP TABLE ##DBRESULTS
CREATE TABLE ##DBRESULTS(InstanceName SYSNAME, DatabaseName SYSNAME, NbOccurrence INT, SchemaName SYSNAME, TableName SYSNAME, ReferencedSchemaName SYSNAME, ReferencedTableName SYSNAME, ConstraintName SYSNAME)
DECLARE DB_Crs CURSOR STATIC FOR SELECT name FROM sys.databases WHERE source_database_id IS NULL AND name NOT IN ('master', 'model', 'msdb', 'distribution', 'tempdb', 'SSISDB')
DECLARE @DB_Name sysname
DECLARE @SqlCmdTemp NVARCHAR(max)
DECLARE @SqlCmd NVARCHAR(max)
SET @SqlCmdTemp = 
 N'USE [##database_name##];
;WITH FKTable 
as(
		SELECT schema_name(o.schema_id) AS ''parent_schema_name'',object_name(FKC.parent_object_id) ''parent_table_name'',
		object_name(constraint_object_id) AS ''constraint_name'',schema_name(RO.Schema_id) AS ''referenced_schema'',object_name(referenced_object_id) AS ''referenced_table_name'',
		(SELECT ''[''+col_name(k.parent_object_id,parent_column_id) +'']''  AS [data()]
			FROM  sys.foreign_key_columns (NOLOCK) AS k
			INNER JOIN sys.foreign_keys  (NOLOCK)
			ON k.constraint_object_id =object_id
			AND k.constraint_object_id =FKC.constraint_object_id
			ORDER BY constraint_column_id
			FOR XML PATH('''') 
		) AS ''parent_colums'',
		(SELECT ''[''+col_name(k.referenced_object_id,referenced_column_id) +'']''  AS [data()]
			FROM  sys.foreign_key_columns  (NOLOCK) AS k
			INNER JOIN sys.foreign_keys  (NOLOCK)
			ON k.constraint_object_id =object_id
			AND k.constraint_object_id =FKC.constraint_object_id
			ORDER BY constraint_column_id
			FOR XML PATH('''') 
		) AS ''referenced_columns''
	FROM  sys.foreign_key_columns FKC  (NOLOCK)
	INNER JOIN sys.objects o  (NOLOCK) ON FKC.parent_object_id = o.object_id
	INNER JOIN sys.objects RO  (NOLOCK) ON FKC.referenced_object_id = RO.object_id
	WHERE o.type =''U'' AND RO.type =''U''
	group by o.schema_id,RO.schema_id,FKC.parent_object_id,constraint_object_id,referenced_object_id
),
/* Index Columns */
IndexColumnsTable AS
(
	SELECT schema_name (o.schema_id) AS ''schema_name'',object_name(o.object_id) AS TableName,
	(SELECT case key_ordinal when 0 then NULL else ''[''+col_name(k.object_id,column_id) +'']'' end AS [data()]
		FROM  sys.index_columns  (NOLOCK) AS k
		WHERE k.object_id = i.object_id
		AND k.index_id = i.index_id
		ORDER BY key_ordinal, column_id
		FOR XML PATH('''')
	) AS cols
	FROM  sys.indexes (NOLOCK) AS i
	INNER JOIN sys.objects o  (NOLOCK) ON i.object_id =o.object_id 
	INNER JOIN sys.index_columns ic (NOLOCK) ON ic.object_id =i.object_id AND ic.index_id =i.index_id
	INNER JOIN sys.columns c (NOLOCK) ON c.object_id = ic.object_id AND c.column_id = ic.column_id
	WHERE o.type =''U'' AND i.index_id > 0
	group by o.schema_id,o.object_id,i.object_id,i.Name,i.index_id,i.type
),
FKWithoutIndexTable AS(
SELECT 
	fk.parent_schema_name AS SchemaName,
	fk.parent_table_name AS TableName,
	fk.referenced_schema AS ReferencedSchemaName,
	fk.referenced_table_name AS ReferencedTableName,
	fk.constraint_name AS ConstraintName,
	ROW_NUMBER() OVER(ORDER BY fk.parent_schema_name, fk.parent_table_name,fk.constraint_name ) AS seq1, 
    	ROW_NUMBER() OVER(ORDER BY fk.parent_schema_name  DESC, fk.parent_table_name  DESC,fk.constraint_name DESC) AS seq2
FROM  FKTable fk 
WHERE NOT EXISTS (SELECT 1 FROM  IndexColumnsTable ict 
		WHERE fk.parent_schema_name = ict.schema_name 
			AND fk.parent_table_name = ict.TableName 
			AND fk.parent_colums = ict.cols
	) 
)
SELECT TOP 10
	@@SERVERNAME AS InstanceName,
	''##database_name##'' DatabaseName,
	seq1 + seq2 - 1 AS NbOccurences,
	SchemaName,
	TableName,
	ReferencedSchemaName,
	ReferencedTableName,
	ConstraintName
FROM  FKWithoutIndexTable'

OPEN DB_Crs
FETCH NEXT FROM DB_Crs INTO @DB_Name
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SqlCmd = REPLACE(@SqlCmdTemp, '##database_name##', @DB_Name)
	INSERT INTO ##DBRESULTS
	EXEC (@SqlCmd)
	FETCH NEXT FROM DB_Crs INTO @DB_Name
END
CLOSE DB_Crs
DEALLOCATE DB_Crs
SELECT * FROM ##DBRESULTS
IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%##DBRESULTS%')
	DROP TABLE ##DBRESULTS
SET NOCOUNT OFF
go
--MoreThan900Bytes
PRINT '######################### Index Key Length > 900 ######################################'
SET NOCOUNT ON
IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%##DBRESULTS%')
	DROP TABLE ##DBRESULTS
CREATE TABLE ##DBRESULTS(InstanceName SYSNAME, DatabaseName SYSNAME, NbOccurrence INT, SchemaName SYSNAME, TableName SYSNAME, IndexName SYSNAME, IndexType TINYINT, RowLength INT, object_id INT, index_id INT, ColumnCount INT)
DECLARE DB_Crs CURSOR STATIC FOR SELECT name FROM sys.databases WHERE source_database_id IS NULL AND name NOT IN ('master', 'model', 'msdb', 'distribution', 'tempdb', 'SSISDB')
DECLARE @DB_Name sysname
DECLARE @SqlCmdTemp NVARCHAR(max)
DECLARE @SqlCmd NVARCHAR(max)
SET @SqlCmdTemp = 
 N'USE [##database_name##];
;WITH BigIndexTable AS
(SELECT  schema_name (o.schema_id) AS ''SchemaName'',o.name AS TableName, i.name AS IndexName, o.object_id,i.index_id,i.type AS IndexType,
	sum(max_length) AS RowLength, count (ic.index_id) AS ''ColumnCount'',ROW_NUMBER() OVER(ORDER BY o.schema_id, o.object_id,i.index_id ) AS seq1, 
    ROW_NUMBER() OVER(ORDER BY o.schema_id  DESC, o.object_id  DESC,i.index_id DESC) AS seq2
FROM sys.indexes i (NOLOCK) 
INNER JOIN sys.objects o (NOLOCK)  ON i.object_id =o.object_id 
INNER JOIN sys.index_columns ic  (NOLOCK) ON ic.object_id =i.object_id and ic.index_id =i.index_id
INNER JOIN sys.columns c  (NOLOCK) ON c.object_id = ic.object_id and c.column_id = ic.column_id
WHERE o.type =''U'' and i.index_id >0 and ic.is_included_column=0
GROUP BY o.schema_id,o.object_id,o.name,i.object_id,i.name,i.index_id,i.type
HAVING (sum(max_length) > 900)
)
SELECT TOP 10
	@@SERVERNAME AS InstanceName, ''##database_name##'' DatabaseName, seq1 + seq2 - 1 AS NbOccurences,
	SchemaName, TableName, IndexName, IndexType, RowLength, object_id, index_id,ColumnCount
FROM BigIndexTable'

OPEN DB_Crs
FETCH NEXT FROM DB_Crs INTO @DB_Name
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SqlCmd = REPLACE(@SqlCmdTemp, '##database_name##', @DB_Name)
	INSERT INTO ##DBRESULTS
	EXEC (@SqlCmd)
	FETCH NEXT FROM DB_Crs INTO @DB_Name
END
CLOSE DB_Crs
DEALLOCATE DB_Crs
SELECT * FROM ##DBRESULTS
IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%##DBRESULTS%')
	DROP TABLE ##DBRESULTS
SET NOCOUNT OFF
go
--MoreIndexesThanColumns
PRINT '######################### More Indexes than Columns ######################################'
SET NOCOUNT ON
IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%##DBRESULTS%')
	DROP TABLE ##DBRESULTS
CREATE TABLE ##DBRESULTS(InstanceName SYSNAME, DatabaseName SYSNAME, NbOccurrence INT, SchemaName SYSNAME, ObjectName SYSNAME, IndexCount INT, ColumnCount INT, schema_id INT, object_id INT)
DECLARE DB_Crs CURSOR STATIC FOR SELECT name FROM sys.databases WHERE source_database_id IS NULL AND name NOT IN ('master', 'model', 'msdb', 'distribution', 'tempdb', 'SSISDB')
DECLARE @DB_Name sysname
DECLARE @SqlCmdTemp NVARCHAR(max)
DECLARE @SqlCmd NVARCHAR(max)
SET @SqlCmdTemp = 
 N'USE [##database_name##];
;WITH ResultTable AS (
SELECT 	schema_name(so.schema_id) AS ''SchemaName'', 
	so.schema_id AS ''schema_id'',
	MAX(so.name) AS ''ObjectName'',
	so.object_id AS ''object_id'',
	CASE MIN(si.index_id)
		WHEN 0 THEN COUNT(si.index_id) - 1 
		ELSE COUNT(si.index_id)
	END   AS ''IndexCount'',
	MAX(d.ColumnCount) AS ''ColumnCount'',
	ROW_NUMBER() OVER(ORDER BY so.schema_id, so.object_id) AS seq1, 
    ROW_NUMBER() OVER(ORDER BY so.schema_id  DESC, so.object_id  DESC) AS seq2
	
FROM sys.objects so (NOLOCK)
JOIN sys.indexes si (NOLOCK) ON so.object_id = si.object_id AND so.type in (''U'',''V'')
FULL OUTER JOIN (SELECT object_id, count(1) AS ColumnCount FROM sys.columns (NOLOCK) GROUP BY object_id) d 
       ON d.object_id = so.object_id
WHERE so.is_ms_shipped = 0
	AND so.object_id not in (select major_id FROM sys.extended_properties (NOLOCK) where name = N''microsoft_database_tools_support'')
	--AND indexproperty(so.object_id, si.name, ''IsStatistics'') = 0
GROUP BY so.schema_id, so.object_id
HAVING( CASE MIN(si.index_id) WHEN 0 THEN COUNT(si.index_id) - 1 
		ELSE COUNT(si.index_id)	END       >   MAX(d.ColumnCount))
)
SELECT TOP 10
	@@SERVERNAME AS InstanceName,
	''##database_name##'' DatabaseName,
	seq1 + seq2 - 1 AS NbOccurences,
	SchemaName, 
	ObjectName,
	IndexCount,
	ColumnCount,
	schema_id,
	object_id
FROM ResultTable rt'

OPEN DB_Crs
FETCH NEXT FROM DB_Crs INTO @DB_Name
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SqlCmd = REPLACE(@SqlCmdTemp, '##database_name##', @DB_Name)
	INSERT INTO ##DBRESULTS
	EXEC (@SqlCmd)
	FETCH NEXT FROM DB_Crs INTO @DB_Name
END
CLOSE DB_Crs
DEALLOCATE DB_Crs
SELECT * FROM ##DBRESULTS
IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%##DBRESULTS%')
	DROP TABLE ##DBRESULTS
SET NOCOUNT OFF
go
--NoIndexes
PRINT '######################### Tables with no indexes ######################################'
SET NOCOUNT ON
IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%##DBRESULTS%')
	DROP TABLE ##DBRESULTS
CREATE TABLE ##DBRESULTS(InstanceName SYSNAME, DatabaseName SYSNAME, NbOccurrence INT, SchemaName SYSNAME, TableName SYSNAME, ApproximateRows BIGINT, ColumnCount INT, schema_id INT, object_id INT)
DECLARE DB_Crs CURSOR STATIC FOR SELECT name FROM sys.databases WHERE source_database_id IS NULL AND name NOT IN ('master', 'model', 'msdb', 'distribution', 'tempdb', 'SSISDB')
DECLARE @DB_Name sysname
DECLARE @SqlCmdTemp NVARCHAR(max)
DECLARE @SqlCmd NVARCHAR(max)
SET @SqlCmdTemp = 
 N'USE [##database_name##];
;WITH ResultTable AS (
SELECT schema_name(so.schema_id) AS ''SchemaName'',
	so.schema_id AS ''schema_id'',      
	object_name(so.object_id) AS ''TableName'',
	so.object_id AS ''object_id'',
	max (d.ColumnCount) AS ''ColumnCount'',
	ROW_NUMBER() OVER(ORDER BY so.schema_id, so.object_id ) AS seq1, 
    ROW_NUMBER() OVER(ORDER BY so.schema_id  DESC, so.object_id  DESC) AS seq2
FROM sys.objects so (NOLOCK)
JOIN sys.indexes si (NOLOCK) ON so.object_id = si.object_id AND so.type in (''U'',''V'') 
FULL OUTER JOIN (SELECT object_id, count(1) AS ColumnCount FROM sys.columns (NOLOCK) GROUP BY object_id) d 
	ON d.object_id = so.object_id
WHERE so.is_ms_shipped = 0
	AND so.object_id NOT IN (SELECT major_id FROM sys.extended_properties (NOLOCK) WHERE name = N''microsoft_database_tools_support'')
GROUP BY so.schema_id, so.object_id
HAVING( 
	CASE MIN(si.index_id)
		WHEN 0 THEN COUNT(si.index_id) - 1 
		ELSE COUNT(si.index_id)
	END    
	= 0)
),
ResultTableTMP AS (
SELECT TOP 10
	@@SERVERNAME AS InstanceName,
	seq1 + seq2 - 1 AS NbOccurences,
	SchemaName,
	TableName,
	ColumnCount,
	schema_id,
	object_id
FROM ResultTable rt
)
SELECT InstanceName,
	''##database_name##'' DatabaseName,
	NbOccurences,
	SchemaName,
	TableName,
	CAST((SELECT SUM (row_count) FROM sys.dm_db_partition_stats 
WHERE object_id=rtt.object_id AND (index_id=0 or index_id=1)) AS bigint) AS ApproximateRows,
	ColumnCount,
	schema_id,
	object_id
FROM ResultTableTMP rtt'

OPEN DB_Crs
FETCH NEXT FROM DB_Crs INTO @DB_Name
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SqlCmd = REPLACE(@SqlCmdTemp, '##database_name##', @DB_Name)
	INSERT INTO ##DBRESULTS
	EXEC (@SqlCmd)
	FETCH NEXT FROM DB_Crs INTO @DB_Name
END
CLOSE DB_Crs
DEALLOCATE DB_Crs
SELECT * FROM ##DBRESULTS
IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%##DBRESULTS%')
	DROP TABLE ##DBRESULTS
SET NOCOUNT OFF
go
--Does not have clustered Index
PRINT '######################### Tables without clustered Index ######################################'
SET NOCOUNT ON
IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%##DBRESULTS%')
	DROP TABLE ##DBRESULTS
CREATE TABLE ##DBRESULTS(InstanceName SYSNAME, DatabaseName SYSNAME, NbOccurrence INT, SchemaName SYSNAME, TableName SYSNAME, ApproximateRows BIGINT, ColumnCount INT, IndexCount INT, schema_id INT, object_id INT)
DECLARE DB_Crs CURSOR STATIC FOR SELECT name FROM sys.databases WHERE source_database_id IS NULL AND name NOT IN ('master', 'model', 'msdb', 'distribution', 'tempdb', 'SSISDB')
DECLARE @DB_Name sysname
DECLARE @SqlCmdTemp NVARCHAR(max)
DECLARE @SqlCmd NVARCHAR(max)
SET @SqlCmdTemp = 
 N'USE [##database_name##];
;WITH ResultTable AS (
SELECT schema_name(so.schema_id) AS ''SchemaName'',
	so.schema_id AS ''schema_id'',      
	MIN(so.name) AS ''TableName'',
	so.object_id AS ''object_id'',
	CASE MIN(si.index_id) WHEN 0 THEN COUNT(si.index_id) - 1 
		ELSE COUNT(si.index_id)	END   as ''IndexCount'',
	MAX(d.ColumnCount) AS ''ColumnCount'',
	ROW_NUMBER() OVER(ORDER BY so.schema_id, so.object_id) AS seq1, 
    ROW_NUMBER() OVER(ORDER BY so.schema_id  DESC, so.object_id  DESC) AS seq2
FROM sys.objects so (NOLOCK)
JOIN sys.indexes si (NOLOCK) ON so.object_id = si.object_id AND so.type in (''U'',''V'') 
FULL OUTER JOIN (SELECT object_id, count(1) AS ColumnCount FROM sys.columns (NOLOCK) GROUP BY object_id) d 
	ON d.object_id = so.object_id
WHERE so.is_ms_shipped = 0
	AND so.object_id NOT IN (SELECT major_id FROM sys.extended_properties (NOLOCK) WHERE name = N''microsoft_database_tools_support'')
GROUP BY so.schema_id, so.object_id
having (MIN(si.index_id) = 0 AND count(si.index_id)-1 > 0)
),	   
ResultTableTMP AS (
SELECT TOP 10
	@@SERVERNAME AS InstanceName,
	seq1 + seq2 - 1 AS NbOccurences,
	SchemaName,
	TableName,
	ColumnCount,
	IndexCount,
	schema_id,
	object_id
FROM ResultTable rt
)
SELECT InstanceName,
	''##database_name##'' DatabaseName,
	NbOccurences,
	SchemaName,
	TableName,
	CAST((SELECT SUM (row_count) FROM sys.dm_db_partition_stats st
WHERE object_id=rtt.object_id AND (st.index_id=0 or st.index_id=1)) AS bigint) AS ApproximateRows,
	ColumnCount,
	IndexCount,
	schema_id,
	object_id
FROM ResultTableTMP rtt'

OPEN DB_Crs
FETCH NEXT FROM DB_Crs INTO @DB_Name
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SqlCmd = REPLACE(@SqlCmdTemp, '##database_name##', @DB_Name)
	INSERT INTO ##DBRESULTS
	EXEC (@SqlCmd)
	FETCH NEXT FROM DB_Crs INTO @DB_Name
END
CLOSE DB_Crs
DEALLOCATE DB_Crs
SELECT * FROM ##DBRESULTS
IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%##DBRESULTS%')
	DROP TABLE ##DBRESULTS
SET NOCOUNT OFF
go
--DoublicateIndexes
PRINT '######################### Dublicate Indexes ######################################'
SET NOCOUNT ON
IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%##DBRESULTS%')
	DROP TABLE ##DBRESULTS
CREATE TABLE ##DBRESULTS(InstanceName SYSNAME, DatabaseName SYSNAME, NbOccurrence INT, SchemaName SYSNAME, TableName SYSNAME, IndexName SYSNAME, DuplicateIndexName SYSNAME, IndexCols VARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AS, index_id INT, object_id INT, IsXML TINYINT)
DECLARE DB_Crs CURSOR STATIC FOR SELECT name FROM sys.databases WHERE source_database_id IS NULL AND name NOT IN ('master', 'model', 'msdb', 'distribution', 'tempdb', 'SSISDB')
DECLARE @DB_Name sysname
DECLARE @SqlCmdTemp NVARCHAR(max)
DECLARE @SqlCmd NVARCHAR(max)
SET @SqlCmdTemp = 
 N'USE [##database_name##];
;with XMLTable AS (
select object_name (x.object_id) as ''TableName'' ,schema_name(o.schema_id) as SchemaName ,x.object_id,x.name,x.index_id,x.using_xml_index_id,x.secondary_type,CONVERT(nvarchar(max),x.secondary_type_desc) as secondary_type_desc, ic.column_id 
from 
	sys.xml_indexes x (NOLOCK)  
	join sys.objects o  (NOLOCK) on x.object_id = o.object_id
	join sys.index_columns  (NOLOCK) ic on x.object_id = ic.object_id and x.index_id = ic.index_id
),
DuplicatesXMLTable AS(
select 
	x1.SchemaName,x1.TableName,x1.name as IndexName,x2.name as DuplicateIndexName, x1.secondary_type_desc as IndexType, x1.index_id, x1.object_id
	,ROW_NUMBER() OVER(ORDER BY x1.SchemaName, x1.TableName,x1.name, x2.name) AS seq1, ROW_NUMBER() OVER(ORDER BY x1.SchemaName DESC, x1.TableName DESC,x1.name DESC, x2.name DESC) AS seq2
from XMLTable x1
	join XMLTable x2
	on x1.object_id = x2.object_id
	and x1.index_id < x2.index_id
	and x1.using_xml_index_id = x2.using_xml_index_id
	and x1.secondary_type = x2.secondary_type
	
),IndexColumns AS(
select distinct  schema_name (o.schema_id) as ''SchemaName'',object_name(o.object_id) as TableName, i.Name as IndexName, o.object_id,i.index_id,i.type,
(select case key_ordinal when 0 then NULL else ''[''+col_name(k.object_id,column_id) +'']'' end as [data()]
from sys.index_columns  (NOLOCK) as k
where k.object_id = i.object_id
and k.index_id = i.index_id
order by key_ordinal, column_id
for xml path('''')) as cols
from sys.indexes  (NOLOCK) as i
inner join sys.objects o  (NOLOCK) on i.object_id =o.object_id 
inner join sys.index_columns ic  (NOLOCK) on ic.object_id =i.object_id and ic.index_id =i.index_id
inner join sys.columns c  (NOLOCK) on c.object_id = ic.object_id and c.column_id = ic.column_id
where  o.type = ''U'' and i.index_id <>0 and i.type <>3 and i.type <>6
group by o.schema_id,o.object_id,i.object_id,i.Name,i.index_id,i.type
),
DuplicatesTable AS
(
SELECT	ic1.SchemaName,ic1.TableName,ic1.IndexName,ic1.object_id, ic2.IndexName as DuplicateIndexName, ic1.cols as IndexCols, ic1.index_id,
ROW_NUMBER() OVER(ORDER BY ic1.SchemaName, ic1.TableName,ic1.IndexName, ic2.IndexName) AS seq1, ROW_NUMBER() OVER(ORDER BY ic1.SchemaName DESC, ic1.TableName DESC, ic1.IndexName DESC, ic2.IndexName DESC) AS seq2
from IndexColumns ic1
	join IndexColumns ic2
	on ic1.object_id = ic2.object_id
	and ic1.index_id < ic2.index_id
	and ic1.cols = ic2.cols
)
SELECT TOP 10 
	@@SERVERNAME AS InstanceName, ''##database_name##'' DatabaseName, dt.seq1 + dt.seq2 - 1 AS NbOccurences,
	SchemaName,TableName, IndexName,DuplicateIndexName, IndexCols, index_id, object_id, 0 AS IsXML
	FROM DuplicatesTable dt
UNION ALL
SELECT TOP 10
	@@SERVERNAME AS InstanceName, ''##database_name##'' DatabaseName, dtxml.seq1 + dtxml.seq2 - 1  AS NbOccurences,
	SchemaName,TableName,IndexName,DuplicateIndexName, IndexType COLLATE SQL_Latin1_General_CP1_CI_AS, index_id, object_id, 1 AS IsXML
FROM DuplicatesXMLTable dtxml
'

OPEN DB_Crs
FETCH NEXT FROM DB_Crs INTO @DB_Name
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SqlCmd = REPLACE(@SqlCmdTemp, '##database_name##', @DB_Name)
	INSERT INTO ##DBRESULTS
	EXEC (@SqlCmd)
	FETCH NEXT FROM DB_Crs INTO @DB_Name
END
CLOSE DB_Crs
DEALLOCATE DB_Crs
SELECT * FROM ##DBRESULTS
IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%##DBRESULTS%')
	DROP TABLE ##DBRESULTS
SET NOCOUNT OFF
go
--RedundantIndexes
PRINT '######################### Redundant Indexes ######################################'
SET NOCOUNT ON
IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%##DBRESULTS%')
	DROP TABLE ##DBRESULTS
CREATE TABLE ##DBRESULTS(InstanceName SYSNAME, DatabaseName SYSNAME, NbOccurrence INT, SchemaName SYSNAME, TableName SYSNAME, IndexName SYSNAME, IndexCols VARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AS, RedundantIndexName SYSNAME, RedundantIndexCols VARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AS, object_id INT, index_id INT)
DECLARE DB_Crs CURSOR STATIC FOR SELECT name FROM sys.databases WHERE source_database_id IS NULL AND name NOT IN ('master', 'model', 'msdb', 'distribution', 'tempdb', 'SSISDB')
DECLARE @DB_Name sysname
DECLARE @SqlCmdTemp NVARCHAR(max)
DECLARE @SqlCmd NVARCHAR(max)
SET @SqlCmdTemp = 
 N'USE [##database_name##];
;with IndexColumns as(
SELECT 	schema_name (o.schema_id) AS ''SchemaName'',
	object_name(o.object_id) AS TableName, 
	i.Name AS IndexName, 
	o.object_id,i.index_id,i.type,
	(SELECT 
		CASE key_ordinal 
			WHEN 0 THEN NULL 
			ELSE ''[''+col_name(k.object_id,column_id) +'']'' 
		END AS [data()]
	FROM sys.index_columns AS k (NOLOCK)
	WHERE k.object_id = o.object_id
		AND k.index_id = i.index_id
	ORDER BY key_ordinal, column_id
	FOR XML PATH('''')) AS cols

FROM sys.indexes (NOLOCK) AS i
INNER JOIN sys.objects o (NOLOCK) ON i.object_id =o.object_id 
INNER JOIN sys.index_columns ic  (NOLOCK) ON ic.object_id =i.object_id AND ic.index_id =i.index_id
INNER JOIN sys.columns c  (NOLOCK) ON c.object_id = ic.object_id AND c.column_id = ic.column_id
WHERE o.type = ''U'' AND i.index_id <>0 AND i.type <>3 AND i.type <>6
GROUP BY o.schema_id,o.object_id,i.Name,i.index_id,i.type
), 
ResultTable AS(
SELECT 
	ic1.SchemaName,ic1.TableName,ic1.object_id, ic1.index_id, ic1.IndexName,ic1.cols AS IndexCols,	ic2.IndexName AS RedundantIndexName, ic2.cols AS RedundantIndexCols,
	ROW_NUMBER() OVER(ORDER BY ic1.SchemaName, ic1.object_id,ic1.index_id,ic2.index_id ) AS seq1, 
    ROW_NUMBER() OVER(ORDER BY ic1.SchemaName  DESC, ic1.object_id  DESC,ic1.index_id DESC, ic2.index_id DESC) AS seq2
FROM IndexColumns ic1  (NOLOCK)
	JOIN IndexColumns ic2  (NOLOCK) ON ic1.object_id = ic2.object_id
	AND ic1.index_id <> ic2.index_id
	AND ic1.cols <> ic2.cols
	AND ic2.cols like REPLACE (ic1.cols, ''['',''[[]'') + '' %''
)
SELECT TOP 10
	@@SERVERNAME AS InstanceName, ''##database_name##'' DatabaseName, seq1 + seq2 - 1 AS NbOccurences,
	SchemaName,TableName, IndexName, IndexCols,	RedundantIndexName, RedundantIndexCols, object_id, index_id
FROM ResultTable'

OPEN DB_Crs
FETCH NEXT FROM DB_Crs INTO @DB_Name
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SqlCmd = REPLACE(@SqlCmdTemp, '##database_name##', @DB_Name)
	INSERT INTO ##DBRESULTS
	EXEC (@SqlCmd)
	FETCH NEXT FROM DB_Crs INTO @DB_Name
END
CLOSE DB_Crs
DEALLOCATE DB_Crs
SELECT * FROM ##DBRESULTS
IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%##DBRESULTS%')
	DROP TABLE ##DBRESULTS
SET NOCOUNT OFF
go
--Fragmentation
PRINT '######################### Index Fragmentation ######################################'
SET NOCOUNT ON
IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%##DBRESULTS%')
	DROP TABLE ##DBRESULTS
CREATE TABLE ##DBRESULTS(InstanceName SYSNAME, DatabaseName SYSNAME, SchemaName SYSNAME, TableName SYSNAME, IndexName SYSNAME, AllocUnitType VARCHAR(50), IndexType VARCHAR(50), PageCount BIGINT, IndexDepth INT, AvgFragmentationPercent FLOAT, FragmentCount BIGINT, AvgFragmentPageCount FLOAT, user_seeks BIGINT, user_scans BIGINT, object_id INT, index_id INT, partition_number INT)
DECLARE DB_Crs CURSOR STATIC FOR SELECT name FROM sys.databases WHERE source_database_id IS NULL AND name NOT IN ('master', 'model', 'msdb', 'distribution', 'tempdb', 'SSISDB')
DECLARE @DB_Name sysname
DECLARE @SqlCmdTemp NVARCHAR(max)
DECLARE @SqlCmd NVARCHAR(max)
SET @SqlCmdTemp = 
 N'USE [##database_name##];
IF( upper(db_name()) NOT IN (''MASTER'',''TEMPDB'',''MODEL'',''MSDB'') )
BEGIN
	SET NOCOUNT ON
	DECLARE @obj TABLE
	(
		seq int identity primary key
		, object_id int
		, index_id int
		,AllocUnitType nvarchar(60)
		,IndexType nvarchar(60)
		,PageCount bigint
		,IndexDepth tinyint
		,AvgFragmentationPercent float
		,FragmentCount bigint
		,AvgFragmentPageCount float
		,partition_number int
		, isFrag bit)
	DECLARE @object_id int, @index_id int, @cnt int, @avg_fragmentation_in_percent float, @rows int, @seq int, @isFrag bit
	SET @cnt= 0
	SET @seq =1

	;WITH TableList AS (
		SELECT  TOP 100 PERCENT
	--	object_name(si.object_id) As ''tableName''
	--, si.name As ''indexName'',
	si.object_id
	, si.index_id
	--, SUM(sau.data_pages) AS ''dataPages''
	--, SUM(ISNULL(ius.user_scans, 0)) AS ''scanCounts''
	FROM sys.indexes AS si INNER JOIN sys.partitions AS sp WITH (NOLOCK) ON si.object_id = sp.object_id AND si.index_id = sp.index_id
											INNER JOIN sys.allocation_units AS sau WITH (NOLOCK) ON sp.hobt_id = sau.container_id
											INNER JOIN sys.objects AS so WITH (NOLOCK) ON si.object_id = so.object_id
											LEFT OUTER JOIN sys.dm_db_index_usage_stats AS ius WITH (NOLOCK) ON ius.database_id = DB_ID() AND ius.object_id = si.object_id AND ius.index_id = si.index_id
	WHERE sau.type_desc = ''IN_ROW_DATA'' 
				AND so.is_ms_shipped = 0
				AND si.object_id NOT IN (SELECT major_id FROM sys.extended_properties (NOLOCK) WHERE name = N''microsoft_database_tools_support'')
				AND si.index_id > 0
				AND si.is_disabled = 0
				AND si.is_hypothetical = 0  
	GROUP BY --object_name(si.object_id), si.name,
		 si.object_id
		, si.index_id
	HAVING SUM(sau.data_pages) > 500
	ORDER BY SUM(ISNULL(ius.user_scans, 0)) DESC,  SUM(sau.data_pages) DESC)
	INSERT @obj(object_id, index_id) SELECT object_id, index_id FROM TableList
	SET @rows=@@ROWCOUNT
	SELECT @object_id=object_id, @index_id=index_id FROM @obj WHERE seq=1
	--PRINT ''Entering the loop''
	
			WHILE (@cnt < 10 AND @rows>=@seq)
			BEGIN
				--PRINT '''' + CAST (@object_id AS VARCHAR(50))+'' '' + CAST (@index_id AS VARCHAR(50))
			
				UPDATE @obj 
				SET @isFrag = isFrag = CASE WHEN frag.avg_fragmentation_in_percent > 10  THEN 1 ELSE 0 END,
						AllocUnitType = frag.alloc_unit_type_desc,
						IndexType =  frag.index_type_desc ,
						PageCount = frag.page_count ,
						IndexDepth = frag.index_depth ,
						AvgFragmentationPercent = frag.avg_fragmentation_in_percent,
						FragmentCount = frag.fragment_count ,
						AvgFragmentPageCount = frag.avg_fragment_size_in_pages ,
						partition_number = frag.partition_number
				FROM sys.dm_db_index_physical_stats(DB_ID(),@object_id,@index_id,null,''LIMITED'') frag 
				WHERE seq = @seq

				SET @cnt = @cnt + CONVERT(INT, @isFrag)
				--PRINT ''Fragmented ? '' + CAST (@isFrag AS VARCHAR(50))

				SET @seq = @seq + 1
				SELECT @object_id=object_id, @index_id=index_id FROM @obj WHERE seq=@seq
			END

			SELECT 
				@@SERVERNAME AS InstanceName,
				''##database_name##'' DatabaseName,
				s.name AS ''SchemaName'',
				o.name AS ''TableName'', 
				si.name AS ''IndexName'',
				AllocUnitType,
				IndexType,
				PageCount,
				IndexDepth,
				AvgFragmentationPercent,
				FragmentCount,
				AvgFragmentPageCount,
				ius.user_seeks,ius.user_scans,
				ifg.object_id,
				ifg.index_id,
				partition_number
			FROM @obj ifg LEFT OUTER JOIN sys.indexes si (NOLOCK) ON si.object_id = ifg.object_id AND si.index_id = ifg.index_id 
										INNER JOIN sys.objects o (NOLOCK) ON ifg.object_id = o.object_id
										INNER JOIN sys.schemas AS s (NOLOCK) ON s.schema_id = o.schema_id
										LEFT OUTER JOIN sys.dm_db_index_usage_stats ius ON ius.database_id=DB_ID() AND ifg.object_id = ius.object_id AND ifg.index_id=ius.index_id
			WHERE isFrag = 1
			ORDER BY PageCount DESC
END
'

OPEN DB_Crs
FETCH NEXT FROM DB_Crs INTO @DB_Name
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SqlCmd = REPLACE(@SqlCmdTemp, '##database_name##', @DB_Name)
	INSERT INTO ##DBRESULTS
	EXEC (@SqlCmd)
	FETCH NEXT FROM DB_Crs INTO @DB_Name
END
CLOSE DB_Crs
DEALLOCATE DB_Crs
SELECT * FROM ##DBRESULTS
IF EXISTS (SELECT * FROM tempdb.sys.objects WHERE name LIKE '%##DBRESULTS%')
	DROP TABLE ##DBRESULTS
SET NOCOUNT OFF
go
