CREATE EVENT SESSION [memory_leak_detection] ON SERVER 
ADD EVENT sqlos.page_allocated(
    ACTION(sqlserver.sql_text)
    WHERE ([memory_clerk_name]=N'MEMORYCLERK_SQLOPTIMIZER')),
ADD EVENT sqlos.page_freed(
    ACTION(sqlserver.sql_text)
    WHERE ([memory_clerk_name]=N'MEMORYCLERK_SQLOPTIMIZER')) 
ADD TARGET package0.pair_matching(SET begin_event=N'sqlos.page_allocated',begin_matching_columns=N'memory_clerk_name,page_location',end_event=N'sqlos.page_freed',end_matching_columns=N'memory_clerk_name,page_location')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=1 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO


