SET NOCOUNT ON
DECLARE @HeadBlocker INT
DECLARE @HeadBlocker_StartTime DATETIME
DECLARE @HeadBlocker_Statement NVARCHAR(MAX)
DECLARE @HeadBlocker_Statement_toKill NVARCHAR(100) = '%proc_ECM_GetChangesForListSync%'
DECLARE @KillCmd NVARCHAR(MAX)
DECLARE @Processes TABLE (spid INT, BlockingSPID INT, DatabaseName VARCHAR(255), [program_name] VARCHAR(255), loginame VARCHAR(255), ObjectName VARCHAR(255), [Definition] VARCHAR(MAX), start_time DATETIME)

INSERT INTO @Processes
SELECT
            s.spid, BlockingSPID = s.blocked, DatabaseName = DB_NAME(s.dbid),
            s.program_name, s.loginame, ObjectName = OBJECT_NAME(objectid,                      s.dbid), Definition = CAST(text AS VARCHAR(MAX)),
                    r.start_time
FROM      sys.sysprocesses s inner join sys.dm_exec_requests r on s.spid = r.session_id
CROSS APPLY sys.dm_exec_sql_text (r.sql_handle)
WHERE
           s.spid > 50

;WITH Blocking(SPID, BlockingSPID, BlockingStatement, RowNo, LevelRow, start_time)
AS
(
     SELECT
      s.SPID, s.BlockingSPID, s.Definition,
      ROW_NUMBER() OVER(ORDER BY s.SPID),
      0 AS LevelRow,
         s.start_time
    FROM
      @Processes s
      JOIN @Processes s1 ON s.SPID = s1.BlockingSPID
    WHERE
      s.BlockingSPID = 0
    UNION ALL
    SELECT
      r.SPID,  r.BlockingSPID, r.Definition,
      d.RowNo,
      d.LevelRow + 1,
         d.start_time
    FROM
      @Processes r
     JOIN Blocking d ON r.BlockingSPID = d.SPID
    WHERE
      r.BlockingSPID > 0
)


SELECT TOP 1 @HeadBlocker = SPID, @HeadBlocker_StartTime = start_time, @HeadBlocker_Statement = BlockingStatement FROM Blocking
ORDER BY RowNo, LevelRow

--PRINT SUBSTRING(@HeadBlocker_Statement,1,CHARINDEX(CHAR(13),@HeadBlocker_Statement)-1)
PRINT '------------------------------------------------------------------------------------------------'
PRINT @HeadBlocker_StartTime
PRINT CASE WHEN CHARINDEX(CHAR(13),@HeadBlocker_Statement) > 0 THEN SUBSTRING(@HeadBlocker_Statement,1,CHARINDEX(CHAR(13),@HeadBlocker_Statement)-1) ELSE @HeadBlocker_Statement END

IF ISNULL(@HeadBlocker_StartTime, GETDATE()) < DATEADD(MINUTE,-5, GETDATE()) 
       AND @HeadBlocker_Statement LIKE @HeadBlocker_Statement_toKill
BEGIN
       SET @KillCmd = N'KILL ' + CONVERT(NVARCHAR(10), @HeadBlocker)
       PRINT @KillCmd
       --EXEC(@KillCmd)
END
PRINT '------------------------------------------------------------------------------------------------'


