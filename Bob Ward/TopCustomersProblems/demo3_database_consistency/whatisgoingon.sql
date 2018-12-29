--
-- You will see the TRUNCATE TABLE is blocked by spid -3
-- Who the heck is this? no session_id = -3 is in sys.dm_exec_sessions
select dr.* from sys.dm_exec_requests dr
join sys.dm_exec_sessions ds
on ds.session_id = dr.session_id
and ds.is_user_process = 1
go
-- Go look at the locks
-- Yep, -3 is holding on to locks tha affect page XXX. Why?
select * from sys.dm_tran_locks
go
select * from msdb.dbo.suspect_pages
go