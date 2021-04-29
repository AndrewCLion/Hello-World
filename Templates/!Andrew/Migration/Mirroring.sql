SELECT     sys.databases.name, sys.database_mirroring.mirroring_partner_instance, sys.database_mirroring.mirroring_state_desc, 
                      sys.database_mirroring.mirroring_role_desc, sys.databases.collation_name, sys.databases.state_desc, sys.databases.compatibility_level, 
                      sys.databases.recovery_model_desc
FROM         sys.database_mirroring INNER JOIN
                      sys.databases ON sys.database_mirroring.database_id = sys.databases.database_id
WHERE     (sys.database_mirroring.database_id > 4)

-- set DB Name and partner name, do this on the slave first
--ALTER DATABASE [] SET PARTNER = 'TCP://by-spcoll01\coll01:5022'
-- set DB Name and partner name, do this on the principle second
--ALTER DATABASE [] SET PARTNER = 'TCP://by-spcoll01\coll01:5022'

--ALTER DATABASE [] SET PARTNER OFF
--ALTER DATABASE [] SET SAFETY OFF --to go to performance mode

--ALTER DATABASE  SET PARTNER FAILOVER -- to manually failover (schwenken)

USE [master]
GO

CREATE ENDPOINT [Mirroring] 
	AUTHORIZATION [BYACCOUNT\Server-GDC.DB-Server]
	--AUTHORIZATION [AD\BBS.A.Entity01.Windows.Standard.eCommerce_local-Admin]
	STATE=STARTED
	AS TCP (LISTENER_PORT = 5022, LISTENER_IP = ALL)
	FOR DATA_MIRRORING (ROLE = PARTNER, AUTHENTICATION = WINDOWS NEGOTIATE
, ENCRYPTION = REQUIRED ALGORITHM RC4)
GO

--ALTER AUTHORIZATION ON ENDPOINT::Mirroring TO sa
--ALTER AUTHORIZATION ON ENDPOINT::Spiegelung TO sa

--ALTER DATABASE [MOSS_Content_CUR1_D_01] SET PARTNER = 'TCP://10.205.92.134:5022'; ALTER DATABASE [MOSS_Content_CUR1_D_01] SET SAFETY OFF

--USE [master]
--GO
CREATE LOGIN [BYACCOUNT\MYTZE] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
CREATE LOGIN [BYACCOUNT\MYRSN] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
CREATE LOGIN [BYACCOUNT\MYHRW] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
CREATE LOGIN [BYACCOUNT\MYUOS] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
CREATE LOGIN [BYACCOUNT\MYUOT] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
CREATE LOGIN [BYACCOUNT\MYGWS] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
CREATE LOGIN [BYACCOUNT\MXCLSQL] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
--GO

--GRANT CONNECT ON ENDPOINT::Spiegelung TO [BYACCOUNT\MYTZE] --COLL04
--GRANT CONNECT ON ENDPOINT::Spiegelung TO [BYACCOUNT\MYRSN] --COLL03
--GRANT CONNECT ON ENDPOINT::Spiegelung TO [BYACCOUNT\MYHRW] --COLL01/COLL02
--GRANT CONNECT ON ENDPOINT::Spiegelung TO [BYACCOUNT\MYUOS] --MD01
--GRANT CONNECT ON ENDPOINT::Spiegelung TO [BYACCOUNT\MYUOT] --CQ01
--GRANT CONNECT ON ENDPOINT::Spiegelung TO [BYACCOUNT\MYGWS] --BHC05
--GRANT CONNECT ON ENDPOINT::Spiegelung TO [BYACCOUNT\MXCLSQL] --BBS02
----GRANT CONNECT ON ENDPOINT::Spiegelung TO [BYACCOUNT\EQZWL] --BBS02
--GRANT CONNECT ON ENDPOINT::Spiegelung TO [BYACCOUNT\MYDWG]
--GRANT CONNECT ON ENDPOINT::Spiegelung TO [byaccount\MXCLSQL]
--GRANT CONNECT ON ENDPOINT::Spiegelung TO [byaccount\mycll]

GRANT CONNECT ON ENDPOINT::Mirroring TO [BYACCOUNT\MYTZE] --COLL04
GRANT CONNECT ON ENDPOINT::Mirroring TO [BYACCOUNT\MYRSN] --COLL03
GRANT CONNECT ON ENDPOINT::Mirroring TO [BYACCOUNT\MYHRW] --COLL01/COLL02
GRANT CONNECT ON ENDPOINT::Mirroring TO [BYACCOUNT\MYUOS] --MD01
GRANT CONNECT ON ENDPOINT::Mirroring TO [BYACCOUNT\MYUOT] --CQ01
GRANT CONNECT ON ENDPOINT::Mirroring TO [BYACCOUNT\MYGWS] --BHC05
GRANT CONNECT ON ENDPOINT::Mirroring TO [BYACCOUNT\MXCLSQL] --BBS02
--GRANT CONNECT ON ENDPOINT::Mirroring TO [BYACCOUNT\EQZWL] --BBS02
--GRANT CONNECT ON ENDPOINT::Mirroring TO [BYACCOUNT\MYDWG]
--GRANT CONNECT ON ENDPOINT::Mirroring TO [byaccount\mycll]
/*
SELECT        m.database_id, m.mirroring_guid, m.mirroring_state, m.mirroring_state_desc, m.mirroring_role, m.mirroring_role_desc, m.mirroring_role_sequence, 
                         m.mirroring_safety_level, m.mirroring_safety_level_desc, m.mirroring_safety_sequence, m.mirroring_partner_name, m.mirroring_partner_instance, 
                         m.mirroring_witness_name, m.mirroring_witness_state, m.mirroring_witness_state_desc, m.mirroring_failover_lsn, m.mirroring_connection_timeout, 
                         m.mirroring_redo_queue, m.mirroring_redo_queue_type, m.mirroring_end_of_log_lsn, m.mirroring_replication_lsn, d.name
--SELECT name
FROM            sys.database_mirroring AS m INNER JOIN
                         sys.databases AS d ON m.database_id = d.database_id
WHERE        (m.mirroring_partner_instance = N'BY0N9G\MD01')
*/
/*
-- stop mirroroing on all databases
SET NOCOUNT ON

DECLARE @dbName sysname, @rc int
DECLARE @SQL nvarchar(4000)

SELECT name
INTO #db
FROM            sys.database_mirroring AS m INNER JOIN
                         sys.databases AS d ON m.database_id = d.database_id
WHERE        (m.mirroring_partner_instance = N'BY0N9G\MD01')

SELECT @rc = 1, @dbName = MIN(name)
FROM #db

WHILE @rc <> 0
BEGIN
    
	/* Insert Code here */
	SET @SQL = N'ALTER DATABASE [' + @dbName + N'] SET PARTNER OFF'
	-- e.g. 	SET @SQL = N'USE [' + @dbName + N'] ; ' + N'CREATE USER [BYACCOUNT\IMXOK] FOR LOGIN [BYACCOUNT\IMXOK]; EXEC sp_addrolemember N''db_owner'', N''BYACCOUNT\IMXOK'''

	print @SQL
	--EXEC sp_executesql @SQL

    SELECT TOP 1 @dbName = name
    FROM #db
    WHERE name > @dbName
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

DROP TABLE #db
*/
/*
SELECT        sys.databases.name, sys.databases.source_database_id, sys.databases.compatibility_level, sys.databases.collation_name, sys.databases.user_access, 
                         sys.databases.user_access_desc, sys.databases.is_read_only, sys.databases.state_desc, sys.databases.is_in_standby, sys.databases.recovery_model_desc, 
                         sys.database_mirroring.mirroring_state_desc, sys.database_mirroring.mirroring_role_desc, sys.database_mirroring.mirroring_partner_name, 
                         sys.database_mirroring.mirroring_partner_instance
FROM            sys.databases INNER JOIN
                         sys.database_mirroring ON sys.databases.database_id = sys.database_mirroring.database_id
WHERE        (sys.databases.database_id > 4)
*/