--http://www.sqlservercentral.com/scripts/attach+database/96623/
USE [master];
GO
DECLARE @database NVARCHAR(200) ,
    @cmd NVARCHAR(1000) ,
    @detach_cmd NVARCHAR(4000) ,
    @attach_cmd NVARCHAR(4000) ,
    @file NVARCHAR(1000) ,
    @i INT ,
    @DetachOrAttach BIT;

SET @DetachOrAttach = 0;

-- 1 Detach 0 - Attach
-- 1 Generates Detach Script
-- 0 Generates Attach Script
DECLARE dbname_cur CURSOR STATIC LOCAL FORWARD_ONLY
FOR
    SELECT  RTRIM(LTRIM([name]))
    FROM    sys.databases
    WHERE   database_id > 4;
 -- No system databases
OPEN dbname_cur

FETCH NEXT FROM dbname_cur INTO @database

WHILE @@FETCH_STATUS = 0 
    BEGIN
        SELECT  @i = 1;

        SET @attach_cmd = '-- ' + QUOTENAME(@database) + CHAR(13) + CHAR(10)
            + 'EXEC sp_attach_db @dbname = ''' + @database + '''' + CHAR(13) + CHAR(10);
      -- Change skip checks to false if you want to update statistics before you detach.
        SET @detach_cmd = '-- ' + QUOTENAME(@database) + CHAR(13) + CHAR(10)
            + 'EXEC sp_detach_db @dbname = ''' + @database
            + ''' , @skipchecks = ''true'';' + CHAR(13) + CHAR(10);

      -- Get a list of files for the database
        DECLARE dbfiles_cur CURSOR STATIC LOCAL FORWARD_ONLY
        FOR
            SELECT  physical_name
            FROM    sys.master_files
            WHERE   database_id = DB_ID(@database)
            ORDER BY [file_id];

        OPEN dbfiles_cur

        FETCH NEXT FROM dbfiles_cur INTO @file

        WHILE @@FETCH_STATUS = 0 
            BEGIN
                SET @attach_cmd = @attach_cmd + '    ,@filename'
                    + CAST(@i AS NVARCHAR(10)) + ' = ''' + @file + ''''
                    + CHAR(13) + CHAR(10);
                SET @i = @i + 1;

                FETCH NEXT FROM dbfiles_cur INTO @file
            END

        CLOSE dbfiles_cur;

        DEALLOCATE dbfiles_cur;

        IF ( @DetachOrAttach = 0 ) 
            BEGIN
            -- Output attach script
                PRINT @attach_cmd + CHAR(13) + CHAR(10);
            END
        ELSE -- Output detach script
            PRINT @detach_cmd;

        FETCH NEXT FROM dbname_cur INTO @database
    END

CLOSE dbname_cur;

DEALLOCATE dbname_cur; 
GO
--Alternative, simpler attach generator#
--SET NOCOUNT ON 
--DECLARE     @cmd        VARCHAR(MAX),
--            @dbname     VARCHAR(200),
--            @prevdbname VARCHAR(200)

--SELECT @cmd = '', @dbname = ';', @prevdbname = ''

--CREATE TABLE #Attach
--    (Seq        INT IDENTITY(1,1) PRIMARY KEY,
--     dbname     SYSNAME NULL,
--     fileid     INT NULL,
--     filename   VARCHAR(1000) NULL,
--     TxtAttach  VARCHAR(MAX) NULL
--)

--INSERT INTO #Attach
--SELECT DISTINCT DB_NAME(dbid) AS dbname, fileid, filename, CONVERT(VARCHAR(MAX),'') AS TxtAttach
--FROM master.dbo.sysaltfiles
--WHERE dbid IN (SELECT dbid FROM master.dbo.sysaltfiles 
--            WHERE DATABASEPROPERTYEX( DB_NAME(dbid) , 'Status' ) = 'ONLINE'
--            AND dbid>4)
--ORDER BY DB_NAME(dbid), fileid, filename
--;
--UPDATE #Attach
--SET @cmd = TxtAttach =  
--            CASE WHEN dbname <> @prevdbname 
--            THEN CONVERT(VARCHAR(200),'exec sp_attach_db @dbname = N''' + dbname + '''')
--            ELSE @cmd
--            END +',@filename' + CONVERT(VARCHAR(10),fileid) + '=N''' + filename +'''',
--    @prevdbname = CASE WHEN dbname <> @prevdbname THEN dbname ELSE @prevdbname END,
--    @dbname = dbname
--FROM #Attach  WITH (INDEX(0),TABLOCKX)
-- OPTION (MAXDOP 1)

--SELECT TxtAttach
--FROM
--(SELECT dbname, MAX(TxtAttach) AS TxtAttach FROM #Attach 
-- GROUP BY dbname) AS x

--DROP TABLE #Attach
--GO 