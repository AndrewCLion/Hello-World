SELECT CAST(XEventData.XEvent.value('(data/value)[1]', 'nvarchar(max)') AS xml) AS DeadlockGraph
	   --, replace(XEventData.XEvent.value('(data/value)[1]', 'nvarchar(max)'),' </deadlock>',' </victim-list>') as DeadlockGraph
	   --, cast(replace(XEventData.XEvent.value('(data/value)[1]', 'nvarchar(max)'),' </deadlock>',' </victim-list>') as XML) as DeadlockGraph
	   , XEventData.XEvent.value('(@timestamp)', 'datetime') AS timestamp
  FROM
	   (
		SELECT CAST(target_data AS xml) AS TargetData
		  FROM
			   sys.dm_xe_session_targets st JOIN sys.dm_xe_sessions s
			   ON s.address = st.event_session_address
		  WHERE s.name = 'system_health') AS Data 
		  CROSS APPLY TargetData.nodes('//RingBufferTarget/event') AS XEventData(XEvent)

  WHERE XEventData.XEvent.value('@name', 'nvarchar(4000)'
							   ) = 'xml_deadlock_report'     
