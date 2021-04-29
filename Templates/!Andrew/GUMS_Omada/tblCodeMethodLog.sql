USE [OmadaEnt]
SELECT TOP 100 * FROM tblCodeMethodLog 
WHERE ErrorMessage LIKE '%No unique CWID can be found%'
ORDER BY ID DESC

SELECT   TOP 100      CONVERT(varchar(12),CreateTime,102) AS Dated, DATEPART(hour,CreateTime) AS DayHour, [Assembly], ClassPath, MethodName 
FROM            OmadaEnt.dbo.tblCodeMethodLog
WHERE        (ErrorMessage LIKE '%timeout%')
ORDER BY ID DESC

SELECT    COUNT(*)
FROM            OmadaEnt.dbo.tblCodeMethodLog
WHERE ErrorMessage LIKE '%timeout%'