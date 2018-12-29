declare @ts_now bigint
select @ts_now=cpu_ticks/(cpu_ticks/ms_ticks) from sys.dm_os_sys_info
select record_id,
dateadd(ms, -1 * (@ts_now - [timestamp]), GetDate()) as EventTime,
CASE 
	WHEN event = 0 THEN 'Allocation Cache Init'
	WHEN event = 1 THEN 'Allocation Cache Add Entry'
	WHEN event = 2 THEN 'Allocation Cache RMV Entry'
	WHEN event = 3 THEN 'Allocation Cache Reinit'
	WHEN event = 4 THEN 'Allocation Cache Free'
	WHEN event = 5 THEN 'Truncate Allocation Unit'
	WHEN event = 10 THEN 'PFS Alloc Page'
	WHEN event = 11 THEN 'PFS Dealloc Page'
	WHEN event = 20 THEN 'IAM Set Bit'
	WHEN event = 21 THEN 'IAM Clear Bit'
	WHEN event = 22 THEN 'GAM Set Bit'
	WHEN event = 23 THEN 'GAM Clear Bit'
	WHEN event = 24 THEN 'SGAM Set Bit'
	WHEN event = 25 THEN 'SGAM Clear Bit'
	WHEN event = 26 THEN 'SGAM Set Bit NX'
	WHEN event = 27 THEN 'SGAM Clear Bit NX'
	WHEN event = 28 THEN 'GAM_ZAP_EXTENT'
	WHEN event = 40 THEN 'FORMAT IAM PAGE'
	WHEN event = 41 THEN 'FORMAT PAGE'
	WHEN event = 42 THEN 'REASSIGN IAM PAGE'
	WHEN event = 50 THEN 'Worktable Cache Add IAM'
	WHEN event = 51 THEN 'Worktable Cache Add Page'
	WHEN event = 52 THEN 'Worktable Cache RMV IAM'
	WHEN event = 53 THEN 'Worktable Cache RMV Page'
	WHEN event = 61 THEN 'IAM Cache Destroy'
	WHEN event = 62 THEN 'IAM Cache Add Page'
	WHEN event = 63 THEN 'IAM Cache Refresh Requested'
	ELSE 'Unknown Event'
END,
session_id,
page_id,
allocation_unit_id
from
(
select 
xml_record.value('(./Record/@id)[1]', 'int') as record_id,
xml_record.value('(./Record/SpaceMgr/Event)[1]', 'int') as event,
xml_record.value('(./Record/SpaceMgr/SpId)[1]', 'int') as session_id,
xml_record.value('(./Record/SpaceMgr/PageId)[1]', 'varchar(100)') as page_id,
xml_record.value('(./Record/SpaceMgr/AuId)[1]', 'varchar(100)') as allocation_unit_id,
timestamp
from 
	(
	select timestamp, convert(xml, record) as xml_record
	from sys.dm_os_ring_buffers
	where ring_buffer_type = N'RING_BUFFER_SPACEMGR_TRACE'
	) as the_record
) as ring_buffer_record
where ring_buffer_record.event = 10
--order by EventTime
order by record_id
go

