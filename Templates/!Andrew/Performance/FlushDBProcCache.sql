DECLARE @DBName sysname

SET @DBName = '<Database_Name, sysname, Database_Name>'

DECLARE @sSQL nvarchar(100)
DECLARE @DBID smallint

IF EXISTS (
	select 1 from sys.dm_exec_query_stats qs
	where 
	--1=1
	--and 
	--query_hash IN ( 0x03A552B6169E1246, 0x385A6F6B7A27A3FB)
	--and 
	max_logical_reads > 1000
	)
BEGIN
	SET @sSQL = 'Flushing ProcCache in DB [' + @DBName + '] ...'
	set @DBID = DB_ID(@DBName)
	RAISERROR (@sSQL,10,1) WITH LOG
	--PRINT 'Flushing ProcCache in DB OmadaEnt ...'
	DBCC FLUSHPROCINDB(@DBID)
END