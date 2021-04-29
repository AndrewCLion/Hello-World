USE [ThisPotentiallyContainedDatabase]
GO
SELECT SO.name, UE.* FROM sys.dm_db_uncontained_entities AS UE
LEFT JOIN sys.objects AS SO
    ON UE.major_id = SO.object_id;
GO