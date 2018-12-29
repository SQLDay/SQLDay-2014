-- What is the sum of all memory allocated through the clerks compared to nodes?
-- Run the first two queries together.
--
select virtual_address_space_committed_kb, locked_page_allocations_kb, (virtual_address_space_committed_kb+locked_page_allocations_kb) as total_committed_by_node
from sys.dm_os_memory_nodes
go
-- Some memory is allocated directly through node allocators and not through the clerks
-- But this does not happen often and is pretty much constant after startup
select sum(pages_kb)+sum(virtual_memory_committed_kb)+sum(awe_allocated_kb) as total_clerk_memory_kb
from sys.dm_os_memory_clerks
go
-- which clerk consumes the most pages?
--
select * from sys.dm_os_memory_clerks order by pages_kb desc
go
-- Which clerk uses the virtual allocator method the most?
--
select type, name, virtual_memory_committed_kb
from sys.dm_os_memory_clerks order by virtual_memory_committed_kb desc
go
-- Does anyone use the locked allocator method directly?
--
select type, name, awe_allocated_kb
from sys.dm_os_memory_clerks
where awe_allocated_kb > 0
order by awe_allocated_kb desc
go
--
-- Does any clerk use all allocator methods?
--
select type, name, pages_kb, virtual_memory_committed_kb, awe_allocated_kb
from sys.dm_os_memory_clerks
where pages_kb > 0 and virtual_memory_committed_kb > 0
and awe_allocated_kb > 0
go
-- What clerk is is equivalent in perfmon to Connection Memory?
--
select type, pages_kb from sys.dm_os_memory_clerks where type = 'MEMORYCLERK_SQLCONNECTIONPOOL'
go