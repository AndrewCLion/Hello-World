-- TokenAndPermUserStore
/*
select * from sys.dm_os_memory_clerks where name = 'TokenAndPermUserStore'
*/

declare @sqlver nvarchar(50), @SQL_Major_Version smallint;
select @sqlver = convert(nvarchar(50),serverproperty(N'ProductVersion'))
select @SQL_Major_Version = convert(smallint, substring(@sqlver , 1, charindex(N'.', @sqlver, 0)-1))

IF @SQL_Major_Version <= 10
	BEGIN
	EXECUTE ('select name, convert(nvarchar(50),serverproperty(N''ProductVersion'')) AS ProductVersion, single_pages_kb/CAST(1024 AS BIGINT) AS [Single_Pages_MB], multi_pages_kb/CAST(1024 AS BIGINT) AS [Multi_Pages_MB], CAST(NULL AS BIGINT) AS Pages_MB from sys.dm_os_memory_clerks where name = ''TokenAndPermUserStore'';')
	END
ELSE
	BEGIN
	IF @SQL_Major_Version = 11
		BEGIN
		EXECUTE ('select name, convert(nvarchar(50),serverproperty(N''ProductVersion'')) AS ProductVersion, CAST(NULL AS BIGINT) AS [Single_Pages_MB], CAST(NULL AS BIGINT) AS [Multi_Pages_MB], pages_kb/CAST(1024 AS BIGINT) AS Pages_MB from sys.dm_os_memory_clerks where name = ''TokenAndPermUserStore'';')
		END
	ELSE
		BEGIN
		IF @SQL_Major_Version = 12
			BEGIN
			EXECUTE ('select name, convert(nvarchar(50),serverproperty(N''ProductVersion'')) AS ProductVersion, CAST(NULL AS BIGINT) AS [Single_Pages_MB], CAST(NULL AS BIGINT) AS [Multi_Pages_MB], pages_kb/CAST(1024 AS BIGINT) AS Pages_MB from sys.dm_os_memory_clerks where name = ''TokenAndPermUserStore'';')
			END
		ELSE
			BEGIN
			IF  @SQL_Major_Version = 13
				BEGIN
				EXECUTE ('select name, convert(nvarchar(50),serverproperty(N''ProductVersion'')) AS ProductVersion, CAST(NULL AS BIGINT) AS [Single_Pages_MB], CAST(NULL AS BIGINT) AS [Multi_Pages_MB], pages_kb/CAST(1024 AS BIGINT) AS Pages_MB from sys.dm_os_memory_clerks where name = ''TokenAndPermUserStore'';')
				END
			ELSE
				PRINT @@SERVERNAME + ' : neue SQL Server Version ' + @sqlver + ' Script bitte anpassen';
			END
		END
	END
--2008 R2
--single_pages_kb: Amount of single page memory allocated in kilobytes (KB). This is the amount of memory allocated by using the single page allocator of a memory node.
	--This single page allocator steals pages directly from the buffer pool.
--multi_pages_kb: Amount of multipage memory allocated in KB. This is the amount of memory allocated by using the multiple page allocator of the memory nodes. 
	--This memory is allocated outside the buffer pool and takes advantage of the virtual allocator of the memory nodes.
--2012 and later
--pages_kb: Specifies the amount of page memory allocated in kilobytes (KB) for this memory clerk.
