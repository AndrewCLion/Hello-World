USE []

---- disable all constraints
--EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"

---- delete data in all tables
--EXEC sp_MSForEachTable "TRUNCATE TABLE ?"

---- enable all constraints
--exec sp_msforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all"

---- reseed identities
--EXEC sp_MSforeachtable "DBCC CHECKIDENT ( '?', RESEED, 0)"

exec sp_MSforeachtable 'SET QUOTED_IDENTIFIER ON; ALTER TABLE ? NOCHECK CONSTRAINT ALL'  
exec sp_MSforeachtable 'SET QUOTED_IDENTIFIER ON; ALTER TABLE ? DISABLE TRIGGER ALL'  
exec sp_MSforeachtable 'SET QUOTED_IDENTIFIER ON; TRUNCATE TABLE ?'  
exec sp_MSforeachtable 'SET QUOTED_IDENTIFIER ON; ALTER TABLE ? CHECK CONSTRAINT ALL'  
exec sp_MSforeachtable 'SET QUOTED_IDENTIFIER ON; ALTER TABLE ? ENABLE TRIGGER ALL' 
exec sp_MSforeachtable 'SET QUOTED_IDENTIFIER ON;
	IF NOT EXISTS (SELECT *
    FROM SYS.IDENTITY_COLUMNS
    JOIN SYS.TABLES ON SYS.IDENTITY_COLUMNS.Object_ID = SYS.TABLES.Object_ID
    WHERE SYS.TABLES.Object_ID = OBJECT_ID(''?'') AND SYS.IDENTITY_COLUMNS.Last_Value IS NULL)
    AND OBJECTPROPERTY(OBJECT_ID(''?''), ''TableHasIdentity'') = 1
    DBCC CHECKIDENT (''?'', RESEED, 0) WITH NO_INFOMSGS'