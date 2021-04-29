SET NOCOUNT ON

DECLARE @dbName sysname, @rc int
DECLARE @SQL nvarchar(4000)

SELECT name
INTO #db
FROM sys.databases
WHERE 
    name NOT IN ('master', 'model', 'msdb', 'tempdb', 'Admin', 'OnePoint', 'distribution') AND
    --name NOT LIKE '%ReportServer%' AND
    DATABASEPROPERTYEX([name], 'IsInStandBy') = 0 AND
    DATABASEPROPERTYEX([name], 'Status') = 'ONLINE'

SELECT @rc = 1, @dbName = MIN(name)
FROM #db

WHILE @rc <> 0
BEGIN
    
	/* Insert Code here */
	SET @SQL = N'USE [' + @dbName + N'] ; ' + N';with objects_cte as (    select
        o.name,
        o.type_desc,
        case
            when o.principal_id is null then s.principal_id
            else o.principal_id
        end as principal_id
    from sys.objects o
    inner join sys.schemas s
    on o.schema_id = s.schema_id
    where o.is_ms_shipped = 0
    --and o.type in (''U'', ''FN'', ''FS'', ''FT'', ''IF'', ''P'', ''PC'', ''TA'', ''TF'', ''TR'', ''V'')
)
select
    cte.name,
    cte.type_desc,
    dp.name
from objects_cte cte
inner join sys.database_principals dp
on cte.principal_id = dp.principal_id
where dp.name = ''BYACCOUNT\EVPWR''
or dp.name = ''BYACCOUNT\EQQIV''
or dp.name = ''EMEA\ERXFJ''
;'

	EXEC sp_executesql @SQL

    SELECT TOP 1 @dbName = name
    FROM #db
    WHERE name > @dbName
    ORDER BY name

    SET @rc = @@ROWCOUNT
END

DROP TABLE #db

--;with objects_cte as
--(
--    select
--        o.name,
--        o.type_desc,
--        case
--            when o.principal_id is null then s.principal_id
--            else o.principal_id
--        end as principal_id
--    from sys.objects o
--    inner join sys.schemas s
--    on o.schema_id = s.schema_id
--    where o.is_ms_shipped = 0
--    and o.type in ('U', 'FN', 'FS', 'FT', 'IF', 'P', 'PC', 'TA', 'TF', 'TR', 'V')
--)
--select
--    cte.name,
--    cte.type_desc,
--    dp.name
--from objects_cte cte
--inner join sys.database_principals dp
--on cte.principal_id = dp.principal_id
--where dp.name = 'BYACCOUNT\EVPWR'
--or dp.name = 'BYACCOUNT\EQQIV'
--or dp.name = 'EMEA\ERXFJ'
--;