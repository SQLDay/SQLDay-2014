-- Region_state
-- 0x00001000 = MEM_COMMIT
-- 0x00002000 = MEM_RESERVE
-- 0x0000000000010000 = MEM_FREE
-- The top region is free in our virtual address space
-- The third region is our big reservation
-- 
select * From sys.dm_os_virtual_address_dump
order by region_size_in_bytes desc
go