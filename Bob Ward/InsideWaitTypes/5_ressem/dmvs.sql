select er.session_id, er.wait_type, er.wait_time, er.wait_resource, er.last_wait_type, 
er.blocking_session_id
from sys.dm_exec_requests er
join sys.dm_exec_sessions es
on es.session_id = er.session_id
and es.is_user_process = 1
go
select wt.waiting_task_address, wt.session_id, wt.wait_type, wt.wait_duration_ms, wt.resource_description 
from sys.dm_os_waiting_tasks wt
join sys.dm_exec_sessions es
on wt.session_id = es.session_id
and es.is_user_process = 1
go
select t.session_id, t.request_id, t.exec_context_id, t.scheduler_id, t.task_address, 
t.parent_task_address
from sys.dm_os_tasks t
join sys.dm_exec_sessions es
on t.session_id = es.session_id
and es.is_user_process = 1
go
