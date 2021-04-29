SELECT DISTINCT local_net_address, local_tcp_port, net_transport, protocol_type, encrypt_option
FROM	sys.dm_exec_connections AS c
------------------------------------
SELECT
     s.host_name
    ,c.local_net_address
    ,c.local_tcp_port
    ,s.login_name
    ,s.program_name
    ,c.session_id
    ,c.connect_time
    ,c.net_transport
    ,c.protocol_type
    ,c.encrypt_option
    ,c.client_net_address
    ,c.client_tcp_port
    ,s.client_interface_name
    ,s.host_process_id
    ,c.num_reads as num_reads_connection
    ,c.num_writes as num_writes_connection
    ,s.cpu_time
    ,s.reads as num_reads_sessions
    ,s.logical_reads as num_logical_reads_sessions
    ,s.writes as num_writes_sessions
    ,c.most_recent_sql_handle
FROM sys.dm_exec_connections AS c
INNER JOIN sys.dm_exec_sessions AS s
    ON c.session_id = s.session_id

