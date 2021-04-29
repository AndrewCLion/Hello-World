SELECT dmes.login_name, dmes.host_name, program_name,  dmec.net_transport, dmes.login_time, 
		e.name AS endpoint_name, e.protocol_desc, e.state_desc, e.is_admin_endpoint, 
		t.port, t.is_dynamic_port, dmec.local_net_address, dmec.local_tcp_port 
FROM sys.endpoints AS e
LEFT JOIN sys.tcp_endpoints AS t
	ON e.endpoint_id = t.endpoint_id
LEFT JOIN sys.dm_exec_sessions AS dmes
	ON e.endpoint_id = dmes.endpoint_id
LEFT JOIN sys.dm_exec_connections AS dmec
	ON dmes.session_id = dmec.session_id;