-- Dump out the memory allocations grouped
--
select ma.memory_allocation_address,ma.size_in_bytes, mo.type, ma.source_file, ma.line_num, ma.allocator_stack_address
from sys.dm_os_memory_allocations ma
join sys.dm_os_memory_objects mo
on mo.memory_object_address = ma.memory_object_address
where mo.type like '%SNI%'
order by size_in_bytes desc
go
select * from sys.dm_os_stacks
where stack_address = 0x000000046B8D50C0
order by frame_index
go