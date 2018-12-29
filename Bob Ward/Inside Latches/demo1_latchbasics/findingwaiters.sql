-- Find all wait types that are latches
select * from sys.dm_os_wait_stats
where wait_type like '%LATCH%'
go
-- Show me all latch classes
select * from sys.dm_os_latch_stats
go
-- The wait_type for a BUF latch is
-- PAGELATCH_XX or PAGEIOLATCH_XX
-- The wait type for a non-BUF latch is LATCH_XX
-- The wait_resource is a pageno for a PAGELATCH
-- and "class" and "address" for a non-BUF latch
select session_id, command, wait_type, wait_resource, 
wait_time, blocking_session_id
from sys.dm_exec_requests
go
-- resource_address for a latch is the Latch class
--
select session_id, exec_context_id, wait_duration_ms, 
wait_type, resource_address, blocking_task_address,
blocking_session_id, blocking_exec_context_id,
resource_description
from sys.dm_os_waiting_tasks
go