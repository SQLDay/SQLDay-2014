declare @ts_now bigint
select @ts_now=cpu_ticks/(cpu_ticks/ms_ticks) from sys.dm_os_sys_info
select dateadd(ms, -1 * (@ts_now - [timestamp]), GetDate()) as EventTime,
pool,
Broker,
Notification
from
(
select 
xml_record.value('(./Record/@id)[1]', 'int') as record_id,
xml_record.value('(./Record/MemoryBroker/Pool)[1]', 'int') as pool,
xml_record.value('(./Record/MemoryBroker/Broker)[1]', 'char(200)') as broker,
xml_record.value('(./Record/MemoryBroker/Notification)[1]', 'char(10)') as Notification,
timestamp
from 
	(
	select timestamp, convert(xml, record) as xml_record
	from sys.dm_os_ring_buffers
	where ring_buffer_type = N'RING_BUFFER_MEMORY_BROKER'
	) as the_record
) as ring_buffer_record
order by EventTime Desc
go