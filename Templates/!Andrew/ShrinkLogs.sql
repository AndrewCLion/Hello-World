--USE [MaintenanceDB]
--GO

--IF EXISTS (SELECT * FROM sys.objects WHERE name = 'SP_SYD_SHRINK_ALL_LOG_FILES')
--	DROP PROC dbo.SP_SYD_SHRINK_ALL_LOG_FILES

--USE [MaintenanceDB]
--GO

--/****** Object:  StoredProcedure [dbo].[SP_SYD_SHRINK_ALL_LOG_FILES]    Script Date: 29.07.2014 15:17:39 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

--CREATE PROC [dbo].[SP_SYD_SHRINK_ALL_LOG_FILES]
--AS
--/****************************************************************************************/
--/* Die Prozedur shrinkt alle LDF Dateien aller User-DBs, die beschreibbar sind  		*/
--/*																						*/
--/* Änderungen:																			*/
--/*																						*/
--/* 29.07.2014	O.Hahn			V1.0		Initiale Version							*/
--/*																						*/		
--/****************************************************************************************/

--BEGIN
SET NOCOUNT ON
DECLARE @Execute BIT
SET @Execute = 0
DECLARE @GetSQLCmd NVARCHAR(max)
DECLARE @SetSQLCmd NVARCHAR(max)
--SET @GetSQLCmd = N'USE [##database_name##];select [value] from sys.extended_properties where class_desc = ''DATABASE'' and name = ''Owner'''
SET @SetSQLCmd = N'SET LOCK_TIMEOUT 1000;USE [##database_name##];DBCC SHRINKFILE (N''##logfile_name##'' , ##target_size##) WITH NO_INFOMSGS'
DECLARE @SQL NVARCHAR(max)
DECLARE @DB_Name VARCHAR(255)
DECLARE @File_ID INT
DECLARE @File_Name VARCHAR(255)
DECLARE @LogFileSize BIGINT
DECLARE @FreeLogFileSize BIGINT
DECLARE @TargetLogMB INT
DECLARE @LogCount INT

IF OBJECT_ID('tempdb..#LogInfo') IS NOT NULL
	DROP TABLE #LogInfo
CREATE TABLE #LogInfo (FileID SMALLINT, FileSize BIGINT, StartOffset BIGINT, FSeqNo BIGINT, Status SMALLINT, Parity SMALLINT, CreateLSN VARBINARY(20))

IF CONVERT(INT,SUBSTRING(CONVERT(VARCHAR(128),SERVERPROPERTY('ProductVersion')),1, CHARINDEX('.',CONVERT(VARCHAR(128),SERVERPROPERTY('ProductVersion')),1)-1)) >= 11
	ALTER TABLE #LogInfo ADD RecoveryUnitId INT

--DECLARE DB_Crs CURSOR STATIC FOR SELECT name FROM sys.databases WHERE source_database_id IS NULL AND name NOT IN ('master', 'model', 'msdb', 'distribution', 'tempdb', 'SSISDB') AND state_desc = 'ONLINE' AND is_read_only = 0

DECLARE DB_Crs CURSOR STATIC FOR SELECT d.name, mf.file_id, mf.name FROM sys.master_files mf INNER JOIN sys.databases d ON mf.database_id = d.database_id 
WHERE source_database_id IS NULL AND d.name NOT IN ('master', 'model', 'msdb', 'distribution', 'tempdb', 'SSISDB') 
AND d.state_desc = 'ONLINE' AND d.is_read_only = 0
AND DATABASEPROPERTYEX(d.name,'Updateability') = 'READ_WRITE'
AND mf.type_desc = 'LOG'
ORDER BY d.name, mf.file_id

OPEN DB_Crs
FETCH NEXT FROM DB_Crs INTO @DB_Name, @File_ID, @File_Name
WHILE @@FETCH_STATUS = 0
BEGIN
	DELETE #LogInfo

	IF CONVERT(INT,SUBSTRING(CONVERT(VARCHAR(128),SERVERPROPERTY('ProductVersion')),1, CHARINDEX('.',CONVERT(VARCHAR(128),SERVERPROPERTY('ProductVersion')),1)-1)) >= 11
		INSERT INTO #LogInfo (RecoveryUnitId, FileID, FileSize, StartOffset, FSeqNo, Status, Parity, CreateLSN)
		EXEC ('DBCC LOGINFO([' + @DB_Name +']) WITH NO_INFOMSGS')
	ELSE
		INSERT INTO #LogInfo (FileID, FileSize, StartOffset, FSeqNo, Status, Parity, CreateLSN)
		EXEC ('DBCC LOGINFO([' + @DB_Name +']) WITH NO_INFOMSGS')

	SET @LogFileSize = (SELECT SUM(FileSize) FROM #LogInfo WHERE FileID = @File_ID)
	SET @FreeLogFileSize = (SELECT SUM(FileSize) FROM #LogInfo WHERE FileID = @File_ID AND [Status] = 0)
	SET @LogCount = (SELECT COUNT(*) FROM #LogInfo WHERE FileID = @File_ID)
	--SELECT SUM(FileSize) FROM #LogInfo WHERE FileID = 2
	--SELECT SUM(FileSize) FROM #LogInfo WHERE FileID = 2 AND Status = 0
	IF FLOOR(@LogFileSize / 1024 / 1024) > 5000
		SET @TargetLogMB = 1000
	ELSE IF FLOOR(@LogFileSize / 1024 / 1024) > 2000
		SET @TargetLogMB = 500
	ELSE IF FLOOR(@LogFileSize / 1024 / 1024) > 500
		SET @TargetLogMB = 100
	ELSE
		SET @TargetLogMB = 50
	--PRINT @DB_Name + ' : ' + CONVERT(VARCHAR(20),@TargetLogMB)

	SET @SQL = @SetSQLCmd
	SET @SQL = REPLACE(@SQL, '##database_name##', @DB_Name)
	SET @SQL = REPLACE(@SQL, '##logfile_name##' , @File_Name)
	SET @SQL = REPLACE(@SQL, '##target_size##', CONVERT(VARCHAR(5), @TargetLogMB))

	IF @LogCount > 2 AND FLOOR((@LogFileSize - @FreeLogFileSize) / 1024 / 1024) < @TargetLogMB AND @TargetLogMB + 10 < FLOOR(@LogFileSize / 1024 / 1024)
	BEGIN
		BEGIN TRY
			PRINT @SQL
			EXEC(@SQL)
		END TRY
		BEGIN CATCH
			PRINT '***** - ' + ERROR_MESSAGE() + ' - *****'
		END CATCH
	END
	 
	FETCH NEXT FROM DB_Crs INTO @DB_Name, @File_ID, @File_Name
END
CLOSE DB_Crs
DEALLOCATE DB_Crs
IF OBJECT_ID('tempdb..#LogInfo') IS NOT NULL
	DROP TABLE #LogInfo
--END

--GO

