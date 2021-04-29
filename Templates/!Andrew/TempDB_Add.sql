/*
-- 24.03.2016 Andrew Craven proper ordering of File numbers, prepared for inserting into configure script
-- 01.05.2015 Andrew Craven some small improvements
-- 19.11.2014 Andrew Craven Corrected some elements
-- 19.11.2014 Orignal from Cornel Sukalla, Microsoft Field Engineer

THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR 
FITNESS FOR A PARTICULAR PURPOSE.

This sample is not supported under any Microsoft standard support program or service. 
The script is provided AS IS without warranty of any kind. Microsoft further disclaims all
implied warranties including, without limitation, any implied warranties of merchantability
or of fitness for a particular purpose. The entire risk arising out of the use or performance
of the sample and documentation remains with you. In no event shall Microsoft, its authors,
or anyone else involved in the creation, production, or delivery of the script be liable for 
any damages whatsoever (including, without limitation, damages for loss of business profits, 
business interruption, loss of business information, or other pecuniary loss) arising out of 
the use of or inability to use the sample or documentation, even if Microsoft has been advised 
of the possibility of such damages.
*/

--example to set initial size, not shrinking:
--ALTER DATABASE tempdb
--MODIFY FILE (NAME = [tempdev], SIZE = 1000MB);
--GO

USE master
GO

CREATE TABLE #numprocs
(
[Index] INT,
[Name] VARCHAR(200),
Internal_Value VARCHAR(50),
Character_Value VARCHAR(200)
)

DECLARE @BASEPATH VARCHAR(200)
DECLARE @PATH VARCHAR(200)
DECLARE @SQL_SCRIPT VARCHAR(500)
DECLARE @CORES INT
DECLARE @FILECOUNT INT
DECLARE @SIZE INT
DECLARE @GROWTH INT
DECLARE @ISPERCENT INT

SET NOCOUNT ON -- 01.05.2015 
INSERT INTO #numprocs
EXEC xp_msver

SELECT @CORES = Internal_Value FROM #numprocs WHERE [Index] = 16
PRINT '-- Actual Num Cores = ' + CAST(@CORES AS nvarchar(12))

IF @CORES > 8
   SET @CORES = 8;
       
PRINT '-- Using Num Cores = ' + CAST(@CORES AS nvarchar(12))

SET @BASEPATH = (select SUBSTRING(physical_name, 1, CHARINDEX(N'tempdb.mdf', LOWER(physical_name)) - 1) DataFileLocation
FROM master.sys.master_files
WHERE database_id = 2 and FILE_ID = 1)
PRINT '-- TempDB Dir = ' + @BASEPATH

SET @FILECOUNT = (SELECT COUNT(*)
FROM master.sys.master_files
WHERE database_id = 2 AND TYPE_DESC = 'ROWS')

SELECT @SIZE = size FROM master.sys.master_files WHERE database_id = 2 AND FILE_ID = 1
SET @SIZE = @SIZE / 128

SELECT @GROWTH = growth FROM master.sys.master_files WHERE database_id = 2 AND FILE_ID = 1
SELECT @ISPERCENT = is_percent_growth FROM master.sys.master_files WHERE database_id = 2 AND FILE_ID = 1
IF @ISPERCENT = 0
	SET @GROWTH = @GROWTH / 128

WHILE @CORES > @FILECOUNT
BEGIN
SET @FILECOUNT = @FILECOUNT + 1
SET @SQL_SCRIPT = '--
ALTER DATABASE tempdb ADD FILE (
FILENAME = ''' + @BASEPATH + 'tempdb' + RTRIM(CAST(@FILECOUNT as CHAR)) + '.ndf'',
NAME = tempdev' + RTRIM(CAST(@FILECOUNT as CHAR)) + ',
SIZE = ' + RTRIM(CAST(@SIZE as CHAR)) + 'MB,
FILEGROWTH = ' + RTRIM(CAST(@GROWTH as CHAR))
IF @ISPERCENT > 0
	SET @SQL_SCRIPT = @SQL_SCRIPT + '%' + ')'
ELSE
	SET @SQL_SCRIPT = @SQL_SCRIPT + 'MB' + ')'
--SET @SQL_SCRIPT = @SQL_SCRIPT + ')'

PRINT (@SQL_SCRIPT)
--EXEC (@SQL_SCRIPT)
--SET @CORES = @CORES - 1
END
GO
DROP TABLE #numprocs

/*
USE [master]
GO
ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'tempdev', FILEGROWTH = 102400KB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdb1', FILENAME = N'XXXX\DATA\tempdb1.ndf' , SIZE = 102400KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdb2', FILENAME = N'XXXX\DATA\tempdb2.ndf' , SIZE = 102400KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdb3', FILENAME = N'XXXX\DATA\tempdb3.ndf' , SIZE = 102400KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdb4', FILENAME = N'XXXX\DATA\tempdb4.ndf' , SIZE = 102400KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdb5', FILENAME = N'XXXX\DATA\tempdb5.ndf' , SIZE = 102400KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdb6', FILENAME = N'XXXX\DATA\tempdb6.ndf' , SIZE = 102400KB , FILEGROWTH = 102400KB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdb7', FILENAME = N'XXXX\DATA\tempdb7.ndf' , SIZE = 102400KB , FILEGROWTH = 102400KB )
GO
*/
/*
USE master
GO
ALTER DATABASE TempDB MODIFY FILE
(NAME = tempdev, FILENAME = 'W:\MSSQL10_50.R20M\MSSQL\DATA\tempdb0.mdf')
GO
ALTER DATABASE TempDB MODIFY FILE
(NAME = templog, FILENAME = 'e:datatemplog.ldf')
GO
*/
/*
USE master 
GO 
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev, FILENAME = 'E:\TempDB_00\Data\tempdb.mdf') 
GO 
ALTER DATABASE tempdb MODIFY FILE (NAME = templog, FILENAME = 'E:\TempDB_00\TLog\templog.ldf') 
GO 
-- See more at: http://www.sqlteam.com/article/moving-the-tempdb-database#sthash.fQNWNbCj.dpuf
*/