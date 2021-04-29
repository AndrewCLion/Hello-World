USE [master]
/* Query to find when the database last accessed on SQL Server 2005 / 2008 ---*/
SELECT        d.name AS DBname,
                             (SELECT        MAX(xx) AS X1
                               FROM            (SELECT        MAX(last_user_seek) AS xx
                                                         WHERE        (MAX(last_user_seek) IS NOT NULL)
                                                         UNION ALL
                                                         SELECT        MAX(last_user_scan) AS xx
                                                         WHERE        (MAX(last_user_scan) IS NOT NULL)
                                                         UNION ALL
                                                         SELECT        MAX(last_user_lookup) AS xx
                                                         WHERE        (MAX(last_user_lookup) IS NOT NULL)
                                                         UNION ALL
                                                         SELECT        MAX(last_user_update) AS xx
                                                         WHERE        (MAX(last_user_update) IS NOT NULL)) AS bb) AS LastDBActivity
FROM            sysdatabases AS d LEFT OUTER JOIN
                         sys.dm_db_index_usage_stats AS s ON d.dbid = s.database_id
GROUP BY d.name
-----------------------------------------------------------------------------------
SELECT        @@SERVERNAME AS server, name AS NotUsedSinceRestart
FROM            sys.databases
WHERE        (database_id > 4) AND (name NOT IN
                             (SELECT        DB_NAME(database_id) AS Expr1
                               FROM            sys.dm_db_index_usage_stats
                               WHERE        (COALESCE (last_user_seek, last_user_scan, last_user_lookup, '1/1/1970') >
                                                             (SELECT        login_time
                                                               FROM            sys.sysprocesses
                                                               WHERE        (spid = 1)))))
-----------------------------------------------------------------------------------
SELECT        @@SERVERNAME AS server, sd.name AS dbname, COUNT(sp.status) AS number_of_connections, GETDATE() AS timestamp
FROM            sys.databases AS sd LEFT OUTER JOIN
                         sys.sysprocesses AS sp ON sd.database_id = sp.dbid
WHERE        (sd.database_id NOT BETWEEN 1 AND 4)
GROUP BY sd.name
-----------------------------------------------------------------------------------
--based on the ideas from 
--http://sqlblog.com/blogs/aaron_bertrand/archive/2008/05/06/when-was-my-database-table-last-accessed.aspx
;;WITH myCTE AS (SELECT        DB_NAME(database_id) AS TheDatabase, last_user_seek, last_user_scan, last_user_lookup, last_user_update
                                      FROM            sys.dm_db_index_usage_stats)
    SELECT        (SELECT        create_date
                                FROM            sys.databases
                                WHERE        (name = 'tempdb')) AS ServerRestartedDate, TheDatabase, MAX(last_read) AS last_read, MAX(last_write) AS last_write
     FROM            (SELECT        TheDatabase, last_user_seek AS last_read, NULL AS last_write
                               FROM            myCTE
                               UNION ALL
                               SELECT        TheDatabase, last_user_scan, NULL AS Expr1
                               FROM            myCTE
                               UNION ALL
                               SELECT        TheDatabase, last_user_lookup, NULL AS Expr1
                               FROM            myCTE
                               UNION ALL
                               SELECT        TheDatabase, NULL AS Expr1, last_user_update
                               FROM            myCTE) AS x
     GROUP BY TheDatabase
     ORDER BY TheDatabase
-----------------------------------------------------------------------------------
