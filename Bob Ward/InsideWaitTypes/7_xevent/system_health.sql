select CAST(st.target_data as XML) from sys.dm_xe_sessions s
join sys.dm_xe_session_targets st
on s.address = st.event_session_address
and s.name = 'system_health'
go