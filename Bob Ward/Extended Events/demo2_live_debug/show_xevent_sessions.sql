select xs.name, xt.target_name, cast(xt.target_data as xml)
from sys.dm_xe_sessions xs
join sys.dm_xe_session_targets xt
on xs.address = xt.event_session_address
where name = 'live_server_debugging'
go


