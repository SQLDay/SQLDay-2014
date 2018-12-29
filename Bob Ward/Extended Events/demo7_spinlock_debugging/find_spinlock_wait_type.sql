select * from sys.dm_xe_map_values where name = 'spinlock_types'
and map_value = 'LOCK_HASH'
order by map_key
go