--SELECT top 10 * FROM master.SYS.master_files

--SELECT DISTINCT [name] FROM master.SYS.master_files WHERE physical_name LIKE 'H:\M%'
--SELECT [name], physical_name FROM master.SYS.master_files WHERE physical_name LIKE 'H:\M%'

--SELECT DISTINCT [name] FROM master.SYS.master_files WHERE physical_name LIKE 'I:\M%'
--SELECT [name], physical_name FROM master.SYS.master_files WHERE physical_name LIKE 'I:\M%'
--GO
--SELECT DISTINCT [name],LEFT([physical_name], 5) AS Gruppe FROM master.SYS.master_files
--GO
WITH DBs (database_id) AS (
SELECT DISTINCT database_id FROM master.SYS.master_files WHERE physical_name LIKE 'H:\M%'
)
SELECT sys.databases.name FROM DBs INNER JOIN sys.databases ON DBs.database_id = sys.databases.database_id 
ORDER BY sys.databases.name
GO
WITH DBs (database_id) AS (
SELECT DISTINCT database_id FROM master.SYS.master_files WHERE physical_name LIKE 'I:\M%'
)
SELECT sys.databases.name FROM DBs INNER JOIN sys.databases ON DBs.database_id = sys.databases.database_id 
ORDER BY sys.databases.name
