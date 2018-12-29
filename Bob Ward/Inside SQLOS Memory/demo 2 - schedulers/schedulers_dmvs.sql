-- affinity_type_desc == AUTO means threads are available to run on any CPU within each NUMA node; MANUAL = we changed from AUTO
-- scheduler_total_count can be greater than scheduler_count because  of HIDDEN schedulers + 1 for DAC
select cpu_count, hyperthread_ratio, max_workers_count, scheduler_count, scheduler_total_count, affinity_type_desc 
from sys.dm_os_sys_info
go
-- Let's break down the masks
-- There are 24 logical CPUs so we need a 24bit number
-- In binary this is 00000000000000000000000
--
-- cpu_affnity_mask == The CPU mask at OS and hardware level
--										Node 0 = 4095 for node0. This translates to 000FFF or .....111111111111 or all CPUs for Node 0 which has 12 logical CPUs
--										Node 1 = 16773120 or FFF000 or 11111111111... or all upper CPUs for Node 1 which has 12 logical CPUs
--										Notice that ALTER SERVER CONFIGURATION has no affect on this. Only BIOS or Windows config can change this.
-- online_scheduler_mask == the same. It would be different if we took some schedulers OFFLINE
--				Notice that affinity to NUMA0 caused this to be 0 for node_id = 1
-- permanent_task_affinity_mask == 110011110111000000000000 which means we only run "permanent" tasks on specific CPUs in the upper range
--	ALTER SERVER CONFIGURATION does not affect these becasue they are permanent. Need a restart for this.
select node_id, cpu_affinity_mask, online_scheduler_count, permanent_task_affinity_mask, online_scheduler_mask
from sys.dm_os_nodes
go
-- parent_node_id == sys.dm_os_nodes.node_id
-- scheduler_id == unique id for scheduler
-- cpu_id == preferred CPU for this scheduler. Doesn't imply affinity but we use SetThreadIdealProcessor()
-- status == VISIBLE or HIDDEN; ONLINE or OFFLINE
-- Notice that affinity to NUMA0 caused 12 of the schedulers to go OFFLINE
select parent_node_id, scheduler_id, cast(cpu_id as varbinary), status from sys.dm_os_schedulers
go