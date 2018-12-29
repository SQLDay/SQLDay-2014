-- Show the work queue and runnable queues from schedulers
-- runnable_tasks_count is the runnable _queue
-- current_workers_count is the worker pool for the scheduler
-- work_queue_count is the number of tasks queued to be executed by a worker.
select parent_node_id, scheduler_id, runnable_tasks_count, current_workers_count, work_queue_count from sys.dm_os_schedulers
go
-- Show me a breakdown of all workers including ones that are bound to tasks
-- For tasks show we which ones have a request bound to them
-- For each worker show me the OS thread id so i can line this up in the debugger
select s.scheduler_id,  s.status, w.worker_address, w.is_preemptive, r.command, r.status, th.os_thread_id
from sys.dm_os_workers w
join sys.dm_os_schedulers s
on w.scheduler_address = s.scheduler_address
left outer join sys.dm_os_tasks t
on t.task_address = w.task_address
left outer join sys.dm_exec_requests r
on r.session_id = t.session_id
left outer join sys.dm_os_threads th
on th.thread_address = w.thread_address
group by s.scheduler_id, s.status, w.worker_address, w.is_preemptive, r.command, r.status, th.os_thread_id, th.started_by_sqlservr
order by s.scheduler_id
go

