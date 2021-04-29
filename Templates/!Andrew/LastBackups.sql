SELECT sdb.Name AS DatabaseName,
COALESCE(CONVERT(VARCHAR(23), MAX(bus.backup_finish_date), 120),'-') AS LastBackUpTime
FROM sys.sysdatabases sdb
LEFT OUTER JOIN msdb.dbo.backupset bus ON bus.database_name = sdb.name
GROUP BY sdb.Name

-- SELECT top 48 * FROM msdb.dbo.backupset WHERE database_name='MOSS_CONTENT_BHC1_D_02' ORDER BY backup_start_date DESC

--SELECT TOP 10 sdb.Name AS DatabaseName, bus.backup_finish_date
--FROM sys.sysdatabases sdb
--LEFT OUTER JOIN msdb.dbo.backupset bus ON bus.database_name = sdb.name
--WHERE sdb.Name LIKE 'VC4DB_EXT_PROD'
--ORDER BY bus.backup_finish_date DESC