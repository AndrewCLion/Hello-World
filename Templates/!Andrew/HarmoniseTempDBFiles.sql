-- zum testen @Execute = 0 lassen.
-- Wenn es ausgeführt werden soll, @Execute = 1
--	27.10.2015	O.Hahn			V1.0		Initiale Version

DECLARE @Execute            TINYINT = 0
DECLARE @TargetFileSize_MB  BIGINT = 1000
DECLARE @TargetMaxSize_MB   BIGINT = 100000
DECLARE @LogicalName        VARCHAR(255)
DECLARE @SQLCmd             NVARCHAR(MAX)
DECLARE @sFileSize          VARCHAR(20)
DECLARE @sMaxSize           VARCHAR(20)

SET @sFileSize = CONVERT(varchar(20), @TargetFileSize_MB)
SET @sMaxSize = CONVERT(varchar(20), @TargetMaxSize_MB)

DECLARE file_crs CURSOR FAST_FORWARD FOR SELECT name FROM sys.master_files WHERE database_id = 2 and type_desc = 'ROWS' ORDER BY file_id
OPEN file_crs
FETCH NEXT FROM file_crs INTO @LogicalName

WHILE @@FETCH_STATUS = 0
BEGIN
     SET @SQLCmd = 'USE [master];ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N''' + @LogicalName + ''', SIZE = ' + @sFileSize + 'MB , FILEGROWTH = 100MB, MAXSIZE = ' + @sMaxSize + 'MB );'

     PRINT @SQLCmd
     IF @Execute = 1
          EXEC (@SQLCmd)
     FETCH NEXT FROM file_crs INTO @LogicalName
END
CLOSE file_crs
DEALLOCATE file_crs
