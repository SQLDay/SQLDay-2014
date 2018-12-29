DROP EVENT SESSION [wait_stacks] ON SERVER 
go

CREATE EVENT SESSION [wait_stacks] ON SERVER 
ADD EVENT sqlos.spinlock_backoff(
    ACTION(package0.callstack)
   --  WHERE ([type]=(107))
   ) 
ADD TARGET package0.histogram(SET source=N'package0.callstack',source_type=(1))
-- ,ADD TARGET package0.ring_buffer(SET max_memory=(4096))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=1 
SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

dbcc traceon(-1, 2592, 3656)  -- Symbolize stacks
go

ALTER EVENT SESSION wait_stacks on SERVER state = START
go