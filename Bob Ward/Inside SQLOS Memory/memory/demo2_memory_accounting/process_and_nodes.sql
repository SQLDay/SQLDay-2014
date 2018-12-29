-- Show all process memory
select physical_memory_in_use_kb, large_page_allocations_kb, locked_page_allocations_kb, (large_page_allocations_kb+locked_page_allocations_kb) as all_locked_kb
from sys.dm_os_process_memory
go
-- Does nodes add ujp to this?
-- Why is virt_committed+locked > all_locked_kb from process?
-- Because there is some calls to VirtualAlloc directly to node that are not locked. This is accounted for
-- in physical_memory_in_use_kb
select virtual_address_space_committed_kb, 
locked_page_allocations_kb, (virtual_address_space_committed_kb+locked_page_allocations_kb) as total_committed_by_node,
pages_kb
from sys.dm_os_memory_nodes
go