-- How many unique type of memory objects are there?
--
select distinct type from sys.dm_os_memory_objects
go
-- Which memory object consumes the most memory?
-- 
select type, pages_in_bytes 
from sys.dm_os_memory_objects
order by pages_in_bytes desc
go
-- Let's group them now by same type
--
select type, sum(pages_in_bytes ) as total_pages_in_bytes
from sys.dm_os_memory_objects
group by type
order by total_pages_in_bytes desc
go
-- which memory objects are created as thread-safe?
--
select type
from sys.dm_os_memory_objects
where (creation_options & 0x2) > 0
group by type
go
-- Which ones are partitioned by CPU
--
select type
from sys.dm_os_memory_objects
where (creation_options & 0x40) > 0
group by type
go
-- How much memory is taken up by memory objects vs overall node allocations?
--
select pages_kb from sys.dm_os_memory_nodes
go
select sum(pages_in_bytes)/1024 as memory_objects_in_kb from sys.dm_os_memory_objects
go
