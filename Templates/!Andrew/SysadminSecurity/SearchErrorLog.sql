-- list Error logs
exec sp_enumerrorlogs 

--This procedure takes four parameters:
--1.Value of error log file you want to read: 0 = current, 1 = Archive #1, 2 = Archive #2, etc... 
--2.Log file type: 1 or NULL = error log, 2 = SQL Agent log 
--3.Search string 1: String one you want to search for 
--4.Search string 2: String two you want to search for to further refine the results

--If you do not pass any parameters this will return the contents of the current error log.

EXEC sp_readerrorlog 6, 1, 'errors'--, 'exec' 

--xp_readerrrorlog

--Even though sp_readerrolog accepts only 4 parameters, the extended stored procedure accepts at least 7 parameters.

--If this extended stored procedure is called directly the parameters are as follows:
--1.Value of error log file you want to read: 0 = current, 1 = Archive #1, 2 = Archive #2, etc... 
--2.Log file type: 1 or NULL = error log, 2 = SQL Agent log 
--3.Search string 1: String one you want to search for 
--4.Search string 2: String two you want to search for to further refine the results 
--5.Search from start time   
--6.Search to end time  
--7.Sort order for results: N'asc' = ascending, N'desc' = descending

EXEC master.dbo.xp_readerrorlog 6, 1, N'errors', N'DBCC', NULL, NULL, N'desc' 
EXEC master.dbo.xp_readerrorlog 0, 1, N'port', N'exec', NULL, NULL, N'asc' 

-- https://www.mssqltips.com/sqlservertip/1476/reading-the-sql-server-log-files-using-tsql/