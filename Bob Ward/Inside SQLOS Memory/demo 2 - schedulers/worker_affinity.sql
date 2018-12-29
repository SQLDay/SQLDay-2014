select s.scheduler_id, w.worker_address, cast(w.affinity as varbinary)
from 
sys.dm_os_workers w
join sys.dm_os_schedulers s
on w.scheduler_address = s.scheduler_address
group by s.scheduler_id, w.worker_address, w.affinity
go
select cast(affinity as varbinary) from sys.dm_os_threads
go