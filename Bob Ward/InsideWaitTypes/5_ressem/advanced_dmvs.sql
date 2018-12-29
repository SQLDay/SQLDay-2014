-- See who had granted query memory
-- Even waiters how up here as they have a "reservation". granted_memory_kb will be NULL
-- and queue_id, wait_order, is_next_candidate, and wait_time_ms will be not NULL
-- You also get a plan_handle so you can go look at the query plan
select * from sys.dm_exec_query_memory_grants
go
-- waiter_count shows anyone waiting
-- resource_id = 1 is for "small queries"
--
select * from sys.dm_exec_query_resource_semaphores
go
-- Look for MEMORYCLERK_SQLQUERYEXEC or MEMORYCLERK_SQLQERESERVATIONS clerks
--
select * from sys.dm_os_memory_clerks
where type = 'MEMORYCLERK_SQLQUERYEXEC'
or type = 'MEMORYCLERK_SQLQERESERVATIONS'
order by pages_kb desc
go
-- Look here to see if any of the brokers are hogging memory or having to shrink
-- last_notification of SHRINK indicates major memory pressure, but this can change
-- quickly
select * from sys.dm_os_memory_brokers
go
dbcc memorystatus
go