/*============================================================================
  Summary:  Demonstrates Latch Contention in TempDb
------------------------------------------------------------------------------
  Written by Klaus Aschenbrenner, SQLpassion.at

  (c) 2011, SQLpassion.at. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLpassion.at

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE master
GO

-- Create a new database
CREATE DATABASE LatchContentionDemo
GO

-- Use the created database
USE LatchContentionDemo
GO

-- Create a new stored procedure
CREATE PROCEDURE PopulateTempTable
AS
BEGIN
	-- Create a new temp table
	CREATE TABLE #TempTable
	(
		Col1 INT IDENTITY(1, 1),
		Col2 CHAR(4000),
		Col3 CHAR(4000)
	)
	
	-- Create a unique clustered index on the previous created temp table
	CREATE UNIQUE CLUSTERED INDEX idx_c1 ON #TempTable(Col1)
	
	-- Insert 10 dummy records
	DECLARE @i INT = 0
	WHILE (@i < 10)
	BEGIN
		INSERT INTO #TempTable VALUES ('Klaus', 'Aschenbrenner')
		SET @i += 1
	END
END
GO

-- Create another stored procedure that calls the previous created stored procedure
CREATE PROCEDURE LoopPopulateTempTable
AS
BEGIN
	-- Call 100 times the previous created stored procedure
	DECLARE @i INT = 0
	WHILE (@i < 100)
	BEGIN
		EXEC PopulateTempTable
		SET @i += 1
	END
END
GO

-- Execute the stored procedure
EXEC LoopPopulateTempTable
GO

-- Let's do now some stress testing with ostress.exe
-- ostress.exe -Q"EXEC LatchContentionDemo.dbo.LoopPopulateTempTable" -n100

-- As you can see there are currently a lot of tasks that are waiting because of the PAGELATCH_UP wait
SELECT * FROM sys.dm_os_waiting_tasks
WHERE resource_description = '2:1:1' 
OR resource_description = '2:1:2'
OR resource_description = '2:1:3'
GO

-- The PAGELATCH_UP wait type is on the very top
SELECT * FROM sys.dm_os_wait_stats
WHERE wait_type LIKE 'PAGELATCH%'
ORDER BY wait_time_ms DESC
GO

-- The baseline for the current execution (1 data file) is as follows:
-- Duration: 29 sec
-- Total tasks waiting on PAGELATCH: 3.372.488
-- Total time waiting on PAGELATCH: 57.323.896ms

-- Clear the wait stats
DBCC sqlperf('sys.dm_os_wait_stats', 'clear')
GO

-- Let's try to add a data file to TempDb, so that we have in sum 2 data files.
-- They must all have the same size.
ALTER DATABASE tempdb
MODIFY FILE
(
	name = 'tempdev',
	size = 512MB
)
GO

-- Add an additional file to tempdb
ALTER DATABASE tempdb
ADD FILE
(
	name = 'tempdev2',
	size = 512MB,
	filename = 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\tempdb2.ndf'
)
GO

-- Let's do the stress testing with ostress.exe again
-- ostress.exe -Q"EXEC LatchContentionDemo.dbo.LoopPopulateTempTable" -n100

-- As you can see there are currently a lot of tasks that are waiting because of the PAGELATCH_UP wait
SELECT * FROM sys.dm_os_waiting_tasks
WHERE resource_description = '2:1:1' 
OR resource_description = '2:1:2'
OR resource_description = '2:1:3'
GO

-- The PAGELATCH_UP wait type is on the very top
SELECT * FROM sys.dm_os_wait_stats
WHERE wait_type LIKE 'PAGELATCH%'
ORDER BY wait_time_ms DESC
GO

-- The baseline for the current execution (2 data files) is as follows:
-- Duration: 12 (old value: 03:17min)
-- Total tasks waiting on PAGELATCH: 1.538.585 (old value: 3.372.488)
-- Total time waiting on PAGELATCH: 27.509.109 (old value: 57.323.896)

-- Let's try to add 2 additional data files, so that we have 1/2 of the CPU cores (including HT cores)
ALTER DATABASE tempdb
ADD FILE
(
	name = 'tempdev3',
	size = 512MB,
	filename = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\tempdb3.ndf'
)
GO

ALTER DATABASE tempdb
ADD FILE
(
	name = 'tempdev4',
	size = 512MB,
	filename = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\tempdb4.ndf'
)
GO

-- Clear the wait stats
DBCC sqlperf('sys.dm_os_wait_stats', 'clear')
GO

-- Let's do the stress testing with ostress.exe again
-- ostress.exe -Q"EXEC LatchContentionDemo.dbo.LoopPopulateTempTable" -n300

-- The PAGELATCH_UP wait type is on the very top
SELECT * FROM sys.dm_os_wait_stats
WHERE wait_type LIKE 'PAGELATCH%'
ORDER BY wait_time_ms DESC
GO

-- The baseline for the current execution (4 data files) is as follows:
-- Duration: 01:34min (old value: 01:37min)
-- Total tasks waiting on PAGELATCH: 839.161 (old value: 1.538.585):
-- Total time waiting on PAGELATCH: 26.727.366 (old value: 27.509.109)

-- Let's check now through the perfmon counter 'Temp Tables Creation Rate' if the created temp table can be reused
-- Result: "Temp tables created during the test: 1000" - means that the temp table is not reused and is always recreated
-- The reason is because we have defined separately a Unique Clustered Index on the temp table
DECLARE @table_counter_before_test BIGINT;
SELECT @table_counter_before_test = cntr_value FROM sys.dm_os_performance_counters
WHERE counter_name = 'Temp Tables Creation Rate'

DECLARE @i INT = 0
WHILE (@i < 10)
BEGIN
	EXEC LoopPopulateTempTable
	SET @i += 1
END

DECLARE @table_counter_after_test BIGINT;
SELECT @table_counter_after_test = cntr_value FROM sys.dm_os_performance_counters
WHERE counter_name = 'Temp Tables Creation Rate'

PRINT 'Temp tables created during the test: ' + CONVERT(VARCHAR(100), @table_counter_after_test - @table_counter_before_test)
GO

-- Let's change the stored procedure, so that temporary object reuse can be used
ALTER PROCEDURE PopulateTempTable
AS
BEGIN
	-- Create a new temp table
	CREATE TABLE #TempTable
	(
		Col1 INT IDENTITY(1, 1) PRIMARY KEY, -- This creates also a Unique Clustered Index
		Col2 CHAR(4000),
		Col3 CHAR(4000)
	)
	
	-- Insert 10 dummy records
	DECLARE @i INT = 0
	WHILE (@i < 10)
	BEGIN
		INSERT INTO #TempTable VALUES ('Klaus', 'Aschenbrenner')
		SET @i += 1
	END
END
GO

-- Let's run the script again
-- Result: "Temp tables created during the test: 1" - now is our temp table reused!
DECLARE @table_counter_before_test BIGINT;
SELECT @table_counter_before_test = cntr_value FROM sys.dm_os_performance_counters
WHERE counter_name = 'Temp Tables Creation Rate'

DECLARE @i INT = 0
WHILE (@i < 10)
BEGIN
	EXEC LoopPopulateTempTable
	SET @i += 1
END

DECLARE @table_counter_after_test BIGINT;
SELECT @table_counter_after_test = cntr_value FROM sys.dm_os_performance_counters
WHERE counter_name = 'Temp Tables Creation Rate'

PRINT 'Temp tables created during the test: ' + CONVERT(VARCHAR(100), @table_counter_after_test - @table_counter_before_test)
GO

-- Clear the wait stats
DBCC sqlperf('sys.dm_os_wait_stats', 'clear')
GO

-- Let's do the stress testing with ostress.exe again
-- ostress.exe -Q"EXEC LatchContentionDemo.dbo.LoopPopulateTempTable" -n100

-- Review the current waiting tasks
SELECT * FROM sys.dm_os_waiting_tasks
WHERE resource_description = '2:1:1' 
OR resource_description = '2:1:2'
OR resource_description = '2:1:3'
GO

-- The PAGELATCH_UP wait type is on the very top
SELECT * FROM sys.dm_os_wait_stats
WHERE wait_type LIKE 'PAGELATCH%'
ORDER BY wait_time_ms DESC
GO

-- The baseline for the current execution (4 data files) is as follows:
-- Duration: 00:46min (old value: 01:34min)
-- Total tasks waiting on PAGELATCH: 579.674 (old value: 839.161):
-- Total time waiting on PAGELATCH: 102.051.195 (old value: 26.727.366)