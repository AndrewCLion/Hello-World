IF (SELECt convert(int,value_in_use) FROM sys.configurations WHERE name = 'default trace enabled')  = 1
BEGIN

	DECLARE @path NVARCHAR(260); 

	SELECT 
	@path = REVERSE(SUBSTRING(REVERSE([path]), 
	CHARINDEX('\', REVERSE([path])), 260)) + N'log.trc' 
	FROM sys.traces 
	WHERE is_default = 1; 

	SELECT        DatabaseName, FileName, ROUND(IntegerData / 128.0, 2) AS MB, SPID, Duration/1000 AS [Duuration(ms)], StartTime, EndTime, 
							 CASE EventClass WHEN 92 THEN 'Data' WHEN 93 THEN 'Log'  WHEN 94 THEN 'Shrink Data' WHEN 93 THEN 'Shrink Log' END AS FileType, 
							 HostName, LoginName, ApplicationName
	FROM            ::fn_trace_gettable(@path, DEFAULT) AS trctbl
	--WHERE        (EventClass IN (92, 93))
	WHERE        (EventClass >= 92 and EventClass <= 95)
	ORDER BY StartTime DESC

   -- DECLARE @curr_tracefilename varchar(500) ; 
   -- DECLARE @base_tracefilename varchar(500) ; 
   -- DECLARE @indx int ;
 
   -- SELECT @curr_tracefilename = path from sys.traces where is_default = 1 ; 
   -- SET @curr_tracefilename = reverse(@curr_tracefilename);
 
   -- SELECT @indx  = patindex('%\%', @curr_tracefilename) ;
   --SET @curr_tracefilename = reverse(@curr_tracefilename) ;
 
   --SET @base_tracefilename = left( @curr_tracefilename,len(@curr_tracefilename) - @indx) + '\log.trc' ; 
         
 
   -- SELECT 
   -- (dense_rank() over (order by StartTime desc)) as l1,
   -- convert(int, EventClass) as EventClass,
   --DatabaseName,
   -- Filename,
   -- (Duration/1000) as Duration,
   -- StartTime,
   -- EndTime,
   -- (IntegerData*8.0/1024) as ChangeInSize 
   -- FROM ::fn_trace_gettable( @base_tracefilename, default ) 
   -- WHERE EventClass IN ( 92, 94, 95) -- 93 is Log
   -- AND
   -- ServerName = @@servername
   -- --AND
   -- --DatabaseName = db_name()  
   -- order by StartTime desc
 
END

 