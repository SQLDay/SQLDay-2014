select * from sys.dm_os_memory_cache_counters where name = 'SQL Plans'
go
dbcc freesystemcache('SQL Plans')
go
select * from sys.dm_os_memory_cache_counters where name = 'SQL Plans'
go
select sum(pages_kb) from sys.dm_os_memory_cache_counters
go
dbcc freesystemcache('all')
go
select sum(pages_kb) from sys.dm_os_memory_cache_counters
go