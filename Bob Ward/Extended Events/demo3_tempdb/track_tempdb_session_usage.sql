use tempdb
go
select session_id, user_objects_alloc_page_count, internal_objects_alloc_page_count
from sys.dm_db_session_space_usage
where session_id > 50
go