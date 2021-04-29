--SELECT @@SERVERNAME
DECLARE @Spid INT, @Status VARCHAR(MAX), @LOGIN VARCHAR(MAX), @HostName VARCHAR(MAX), @BlkBy VARCHAR(MAX), @DBName VARCHAR(MAX), @Command VARCHAR(MAX), @CPUTime INT, @DiskIO INT, @LastBatch VARCHAR(MAX), @ProgramName VARCHAR(MAX), @SPID_1 INT, @REQUESTID INT

    --SET @SPID = 10
    --SET @Status = 'BACKGROUND'
    --SET @LOGIN = 'sa'
    --SET @HostName = 'MSSQL-1'
    --SET @BlkBy = 0
    --SET @DBName = 'NME40%'
    --SET @Command = 'SELECT INTO'
    --SET @CPUTime = 1000
    --SET @DiskIO = 1000
    --SET @LastBatch = '10/24 10:00:00'
    --SET @ProgramName = 'Microsoft SQL Server Management Studio - Query'
    --SET @SPID_1 = 10
    --SET @REQUESTID = 0

    SET NOCOUNT ON 
    DECLARE @Table TABLE(
            SPID INT,
            Status VARCHAR(MAX),
            LOGIN VARCHAR(MAX),
            HostName VARCHAR(MAX),
            BlkBy VARCHAR(MAX),
            DBName VARCHAR(MAX),
            Command VARCHAR(MAX),
            CPUTime INT,
            DiskIO INT,
            LastBatch VARCHAR(MAX),
            ProgramName VARCHAR(MAX),
            SPID_1 INT,
            REQUESTID INT
    )
    INSERT INTO @Table EXEC sp_who2
    SET NOCOUNT OFF
    SELECT  t.SPID, t.Status, t.LOGIN,
            c.client_net_address, t.HostName,
            t.BlkBy, t.DBName, t.Command,
            t.CPUTime, t.DiskIO, t.LastBatch,
            t.ProgramName--, t.SPID_1, t.REQUESTID
    --SELECT  COUNT(SPID) AS Verbindungen, Status,LOGIN,Hostname,DBName,ProgramName
    FROM    @Table AS t LEFT JOIN sys.dm_exec_connections AS c ON t.SPID = c.session_id
    WHERE
    (@Spid IS NULL OR SPID = @Spid)
    AND (@Status IS NULL OR Status = @Status)
    AND (@LOGIN IS NULL OR LOGIN = @LOGIN)
    AND (@HostName IS NULL OR HostName = @HostName)
    AND (@BlkBy IS NULL OR BlkBy = @BlkBy)
    AND (@DBName IS NULL OR DBName LIKE @DBName)
    AND (@Command IS NULL OR Command = @Command)
    AND (@CPUTime IS NULL OR CPUTime >= @CPUTime)
    AND (@DiskIO IS NULL OR DiskIO >= @DiskIO)
    AND (@LastBatch IS NULL OR LastBatch >= @LastBatch)
    AND (@ProgramName IS NULL OR ProgramName = @ProgramName)
    AND (@SPID_1 IS NULL OR SPID_1 = @SPID_1)
    AND (@REQUESTID IS NULL OR REQUESTID = @REQUESTID)
	--GROUP BY Status,LOGIN,Hostname,DBName,ProgramName
ORDER BY DBName

--SET @Spid = NULL
--SELECT @Spid = MIN(SPID) 
--FROM    @Table AS t LEFT JOIN sys.dm_exec_connections AS c ON t.SPID = c.session_id
--WHERE
--(@Spid IS NULL OR SPID = @Spid)
--AND (@Status IS NULL OR Status = @Status)
--AND (@LOGIN IS NULL OR LOGIN = @LOGIN)
--AND (@HostName IS NULL OR HostName = @HostName)
--AND (@BlkBy IS NULL OR BlkBy = @BlkBy)
--AND (@DBName IS NULL OR DBName LIKE @DBName)
--AND (@Command IS NULL OR Command = @Command)
--AND (@CPUTime IS NULL OR CPUTime >= @CPUTime)
--AND (@DiskIO IS NULL OR DiskIO >= @DiskIO)
--AND (@LastBatch IS NULL OR LastBatch >= @LastBatch)
--AND (@ProgramName IS NULL OR ProgramName = @ProgramName)
--AND (@SPID_1 IS NULL OR SPID_1 = @SPID_1)
--AND (@REQUESTID IS NULL OR REQUESTID = @REQUESTID)

--WHILE @Spid IS NOT NULL
--BEGIN
--	SET @Command =  'KILL ' + CAST(@Spid as varchar(13));
--	--Print @Command
--	EXEC (@Command)
--	DELETE FROM @Table WHERE SPID = @Spid
--	SET @Spid = NULL
--  SELECT @Spid = MIN(SPID) 
--  FROM    @Table AS t LEFT JOIN sys.dm_exec_connections AS c ON t.SPID = c.session_id
--  WHERE
--  (@Spid IS NULL OR SPID = @Spid)
--  AND (@Status IS NULL OR Status = @Status)
--  AND (@LOGIN IS NULL OR LOGIN = @LOGIN)
--  AND (@HostName IS NULL OR HostName = @HostName)
--  AND (@BlkBy IS NULL OR BlkBy = @BlkBy)
--  AND (@DBName IS NULL OR DBName LIKE @DBName)
--  AND (@Command IS NULL OR Command = @Command)
--  AND (@CPUTime IS NULL OR CPUTime >= @CPUTime)
--  AND (@DiskIO IS NULL OR DiskIO >= @DiskIO)
--  AND (@LastBatch IS NULL OR LastBatch >= @LastBatch)
--  AND (@ProgramName IS NULL OR ProgramName = @ProgramName)
--  AND (@SPID_1 IS NULL OR SPID_1 = @SPID_1)
--  AND (@REQUESTID IS NULL OR REQUESTID = @REQUESTID)
--END

--KILL 137
--SELECT * FROM sys.databases WHERE [name] NOT IN (SELECT DBName FROM @Table) ORDER BY [name]

--ALTER DATABASE [] SET OFFLINE --WITH ROLLBACK IMMEDIATE
