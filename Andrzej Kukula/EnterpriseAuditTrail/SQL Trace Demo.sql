-- SQL trace demo

USE master;
GO

DECLARE @rc INT, @trace_id INT;

EXEC @rc = sp_trace_create @trace_id OUTPUT, 0, N'c:\Audits\sql_trace';

EXEC sp_trace_setevent @trace_id, 10, 1, 1;  -- RPC:Completed, column TextData
EXEC sp_trace_setevent @trace_id, 13, 11, 1; -- SQL:BatchStarting, column LoginName
EXEC sp_trace_setevent @trace_id, 13, 14, 1; -- SQL:BatchStarting, column StartTime
EXEC sp_trace_setevent @trace_id, 13, 1, 1;  -- SQL:BatchStarting, column TextData
EXEC sp_trace_setevent @trace_id, 12, 15, 1; -- SQL:BatchCompleted, column EndTime
GO
-- http://technet.microsoft.com/en-us/library/ms186265.aspx
-- for all these "numbers"

-- filter
--exec sp_trace_setfilter 1, 10, 0, 6, '%Management Studio%';
DECLARE @trace_id INT, @rc INT;
SELECT @trace_id = traceid FROM ::fn_trace_getinfo(DEFAULT) WHERE [value] = N'c:\Audits\sql_trace.trc';
EXEC @rc = sp_trace_setstatus @trace_id, 1;
GO

-- generate some load
SELECT * FROM sys.databases;
GO

SELECT * FROM ::fn_trace_getinfo(DEFAULT);

-- stop the trace
DECLARE @trace_id INT;
SELECT @trace_id = traceid FROM ::fn_trace_getinfo(DEFAULT) WHERE [value] = N'c:\Audits\sql_trace.trc';
EXEC sp_trace_setstatus @trace_id, 0;
GO

-- delete the trace
DECLARE @trace_id INT;
SELECT @trace_id = traceid FROM ::fn_trace_getinfo(DEFAULT) WHERE [value] = N'c:\Audits\sql_trace.trc';
EXEC sp_trace_setstatus @trace_id, 2;
GO

-- open the file in SQL Server Profiler to see results

-- or use this function which allows further processing / filtering etc
SELECT * FROM fn_trace_gettable(N'c:\Audits\sql_trace.trc', DEFAULT);

-- "This feature will be removed in a future version of Microsoft SQL Server. Avoid using this feature
-- in new development work, and plan to modify applications that currently use this feature. Use Extended
-- Events instead" - http://technet.microsoft.com/en-us/library/ms173875.aspx

