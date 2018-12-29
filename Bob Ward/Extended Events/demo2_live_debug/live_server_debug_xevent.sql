CREATE EVENT SESSION [live_server_debugging] ON SERVER 
ADD EVENT sqlserver.inaccurate_cardinality_estimate,
ADD EVENT sqlserver.rpc_completed(
    ACTION(sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id)
    WHERE ([package0].[greater_than_uint64]([sqlserver].[database_id],(4)) AND [package0].[equal_boolean]([sqlserver].[is_system],(0)))),
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(sqlserver.query_hash,sqlserver.query_plan_hash)),
ADD EVENT sqlserver.sql_statement_completed(SET collect_statement=(1)
    ACTION(sqlserver.database_id,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id)) 
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=20480 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=1 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=PER_NODE,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO
