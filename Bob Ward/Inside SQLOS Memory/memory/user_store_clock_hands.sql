declare @ts_now bigint
select @ts_now=cpu_ticks/(cpu_ticks/ms_ticks) from sys.dm_os_sys_info
select mcch.type, mcch.cache_address, mcch.clock_hand, mcch.clock_status, dateadd(ms, -1 * (@ts_now - mcch.last_tick_time), GetDate()) as LastClockMovementTime,
dateadd(ms, -1 * (@ts_now - mcch.round_start_time), GetDate()) as LastSweepTime,
mcch.last_round_start_time,
mcch.rounds_count,
mcch.removed_all_rounds_count,
mcch.updated_last_round_count,
mcch.removed_last_round_count
from sys.dm_os_memory_cache_clock_hands mcch
--join sys.dm_os_memory_cache_entries mcce
--on mcch.cache_address = mcce.cache_address
where mcch.type like 'USERSTORE%'
go
