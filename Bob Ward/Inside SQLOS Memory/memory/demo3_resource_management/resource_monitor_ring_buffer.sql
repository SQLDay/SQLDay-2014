-- The Notification values are
-- RESOURCE_MEMPHYSICAL_HIGH = 1
-- RESOURCE_MEMPHYSICAL_LOW = 2
-- A value of 3 means BOTH MEMPHYSICAL_LOW and MEMVIRUTAL_LOW (you are really, really low on memory)
declare @ts_now bigint
select @ts_now=cpu_ticks/(cpu_ticks/ms_ticks) from sys.dm_os_sys_info
select dateadd(ms, -1 * (@ts_now - [timestamp]), GetDate()) as EventTime,
Notification,
IndicatorsProcess,
IndicatorsSystem,
TargetMemory,
CommittedMemory,
AvailablePhysicalMemory
from
(
select 
xml_record.value('(./Record/@id)[1]', 'int') as record_id,
xml_record.value('(./Record/ResourceMonitor/Notification)[1]', 'char(50)') as Notification,
xml_record.value('(./Record/ResourceMonitor/IndicatorsProcess)[1]', 'int') as IndicatorsProcess,
xml_record.value('(./Record/ResourceMonitor/IndicatorsSystem)[1]', 'int') as IndicatorsSystem,
xml_record.value('(./Record/MemoryNode/TargetMemory)[1]', 'int') as TargetMemory,
xml_record.value('(./Record/MemoryNode/CommittedMemory)[1]', 'int') as CommittedMemory,
xml_record.value('(./Record/MemoryRecord/AvailablePhysicalMemory)[1]', 'int') as AvailablePhysicalMemory,
timestamp
from 
	(
	select timestamp, convert(xml, record) as xml_record
	from sys.dm_os_ring_buffers
	where ring_buffer_type = N'RING_BUFFER_RESOURCE_MONITOR'
	) as the_record
) as ring_buffer_record
order by EventTime Desc
go