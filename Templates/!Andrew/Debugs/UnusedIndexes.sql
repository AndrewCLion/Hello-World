SELECT	OBJECT_NAME(s.object_id) AS [Table Name], i.name AS [Index Name], i.index_id, s.user_updates AS [Total Writes], 
		s.user_seeks + s.user_scans + s.user_lookups AS [Total Reads], s.user_updates - (s.user_seeks + s.user_scans + s.user_lookups) AS Difference
FROM	sys.dm_db_index_usage_stats AS s WITH (NOLOCK) INNER JOIN
		sys.indexes AS i WITH (NOLOCK) ON s.object_id = i.object_id AND i.index_id = s.index_id
WHERE	(OBJECTPROPERTY(s.object_id, 'IsUserTable') = 1) AND (s.user_updates > s.user_seeks + s.user_scans + s.user_lookups) AND (i.index_id > 1)
ORDER BY Difference DESC, [Total Writes] DESC, [Total Reads] OPTION (RECOMPILE)