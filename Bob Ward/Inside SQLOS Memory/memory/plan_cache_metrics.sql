select count(*) as syscacheobject_count from syscacheobjects
go
select count(*) as execcachedplans_count from sys.dm_exec_cached_plans
go
select count(*) as memcacheentries_count 
from sys.dm_os_memory_cache_entries  where type in ('CACHESTORE_OBJCP', 'CACHESTORE_SQLCP', 'CACHESTORE_PHDR', 'CACHESTORE_XPROC')
go
dbcc memorystatus
go
select * from sys.dm_os_memory_clerks
where type in ('CACHESTORE_OBJCP', 'CACHESTORE_SQLCP', 'CACHESTORE_PHDR', 'CACHESTORE_XPROC')
go
select * from sys.dm_os_memory_cache_counters
where type in ('CACHESTORE_OBJCP', 'CACHESTORE_SQLCP', 'CACHESTORE_PHDR', 'CACHESTORE_XPROC')
go