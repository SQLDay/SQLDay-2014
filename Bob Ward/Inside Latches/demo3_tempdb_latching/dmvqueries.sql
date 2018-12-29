select session_id, blocking_session_id, wait_type, wait_resource, wait_time
from sys.dm_exec_requests
where wait_time > 0
and session_id > 50
go

select * From sys.dm_os_waiting_tasks
where session_id > 50

select * from sys.dm_os_latch_stats
where wait_time_ms > 0

dbcc sqlperf('waitstats', clear)

select * from sys.dm_os_wait_stats
where wait_time_ms > 0

select wait_type, waiting_tasks_count
from sys.dm_os_wait_stats
where wait_time_ms > 0
and wait_type like '%LATCH%'


select db_name(vfs.database_id), df.name, df.physical_name, iopend.* from sys.dm_io_pending_io_requests iopend
join sys.dm_io_virtual_file_stats( NULL, NULL) vfs
on vfs.file_handle = iopend.io_handle
join sys.database_files df
on df.file_id = vfs.file_id


select * from sys.database_files

select db_id('broncosareok')

select * from sys.dm_io_virtual_file_stats (NULL, NULL)