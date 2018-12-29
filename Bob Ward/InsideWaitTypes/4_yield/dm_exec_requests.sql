select session_id, status, wait_type, wait_time, wait_resource, last_wait_type
 from sys.dm_exec_requests where session_id > 50
go