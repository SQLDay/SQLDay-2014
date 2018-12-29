CREATE EVENT SESSION [track_tempdb_usage] ON SERVER 
ADD EVENT sqlserver.allocation_ring_buffer_recorded(
    ACTION(sqlserver.sql_text)
    WHERE ([package0].[equal_uint64]([event],(10)))) 
ADD TARGET package0.event_counter,
ADD TARGET package0.event_file(SET filename=N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Log\track_tempdb_usage.xel'),
ADD TARGET package0.histogram(SET filtering_event_name=N'sqlserver.allocation_ring_buffer_recorded',source=N'sqlserver.sql_text')
WITH (MAX_MEMORY=20480 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=1 SECONDS,MAX_EVENT_SIZE=20480 KB,MEMORY_PARTITION_MODE=PER_NODE,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO


