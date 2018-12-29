select session_id, command, os_thread_id
from sys.dm_exec_requests as r
join sys.dm_os_workers as w on r.task_address = w.task_address
join sys.dm_os_threads as t on t.thread_address = w.thread_address
where session_id <= 50
order by session_id
GO


