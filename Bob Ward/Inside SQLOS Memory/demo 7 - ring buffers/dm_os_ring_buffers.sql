declare @ts_now bigint
select @ts_now=cpu_ticks/(cpu_ticks/ms_ticks) from sys.dm_os_sys_info
select  dateadd(ms, -1 * (@ts_now - [timestamp]), GetDate()) as EventTime, ring_buffer_type, CAST(record as xml)
from sys.dm_os_ring_buffers
order by EventTime desc
go