SELECT user_seeks * avg_total_user_cost * (avg_user_impact * 0.01) AS
[index_advantage],
migs.last_user_seek, mid.[statement] AS [Database.Schema.Table],
mid.equality_columns, mid.inequality_columns, mid.included_columns,
migs.unique_compiles, migs.user_seeks, migs.avg_total_user_cost,
migs.avg_user_impact
FROM sys.dm_db_missing_index_group_stats AS migs WITH (NOLOCK)
INNER JOIN sys.dm_db_missing_index_groups AS mig WITH (NOLOCK)
ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details AS mid WITH (NOLOCK)
ON mig.index_handle = mid.index_handle
WHERE 1=1
AND mid.database_id = DB_ID() -- Remove this to see for entire instance
ORDER BY index_advantage DESC OPTION (RECOMPILE);

SELECT mid.index_handle,
    mid.database_id,
    mid.statement,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns,
    migs.user_seeks,
    migs.user_scans,
    migs.avg_total_user_cost,
    migs.avg_user_impact,
    migs.avg_total_user_cost * migs.avg_user_impact *
    (migs.user_seeks + migs.user_scans) AS potential_user_benefit
  FROM sys.dm_db_missing_index_details AS mid
    INNER JOIN sys.dm_db_missing_index_groups AS mig
      ON mid.index_handle = mig.index_handle
    INNER JOIN sys.dm_db_missing_index_group_stats AS migs
      ON mig.index_group_handle = migs.group_handle
  WHERE (mid.database_id = DB_ID())
ORDER BY potential_user_benefit DESC OPTION (RECOMPILE);