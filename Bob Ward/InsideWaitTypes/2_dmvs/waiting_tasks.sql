-- Let's just look at anyone waiting
--
select session_id, exec_context_id, wait_type, wait_duration_ms 
from sys.dm_os_waiting_tasks
go



