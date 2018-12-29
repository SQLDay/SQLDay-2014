/*============================================================================
  Summary:  Demonstrates how to design and maintain a VLDB on SQL Server 2008
------------------------------------------------------------------------------
  Written by Klaus Aschenbrenner, SQLpassion.at

  For more scripts and sample code, check out 
    http://www.SQLpassion.at
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE master
GO

-- Create a new database with *better* default settings
CREATE DATABASE VLDB ON PRIMARY 
(
	NAME = N'VLDB', 
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQL2014\MSSQL\DATA\VLDB.mdf',
	SIZE = 5072KB, 
	FILEGROWTH = 1024KB
)
LOG ON 
(
	NAME = N'VLDB_log',
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQL2014\MSSQL\DATA\VLDB_log.ldf',
	SIZE = 2048000KB, -- Initialize the log with 2GB, this gives us 16 VLFs
	FILEGROWTH = 10%
)
GO

-- Create a new file group for the 2007 sales data
ALTER DATABASE VLDB
ADD FILEGROUP Sales2007FG
GO

-- Add a new file to the previous created file group
ALTER DATABASE VLDB
ADD FILE
(
	NAME = 'Sales2007_Data',
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL12.SQL2014\MSSQL\DATA\Sales2007_Data.ndf',
	SIZE = 300,
	FILEGROWTH = 10%
)
TO FILEGROUP Sales2007FG
GO

-- Create a new file group for the 2008 sales data
ALTER DATABASE VLDB
ADD FILEGROUP Sales2008FG
GO

-- Add a new file to the previous created file group
ALTER DATABASE VLDB
ADD FILE
(
	NAME = 'Sales2008_Data',
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL12.SQL2014\MSSQL\DATA\Sales2008_Data.ndf',
	SIZE = 300,
	FILEGROWTH = 10%
)
TO FILEGROUP Sales2008FG
GO

-- Create a new file group for the 2009 sales data
ALTER DATABASE VLDB
ADD FILEGROUP Sales2009FG
GO

-- Add a new file to the previous created file group
ALTER DATABASE VLDB
ADD FILE
(
	NAME = 'Sales2009_Data',
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL12.SQL2014\MSSQL\DATA\Sales2009_Data.ndf',
	SIZE = 500,
	FILEGROWTH = 10%
)
TO FILEGROUP Sales2009FG
GO

-- Use our VLDB
USE VLDB
GO

-- ========================================
-- Set up the "Sales2007" partitioned table
-- ========================================

-- Create a new partition function for used by the "Sales2007" partitioned table.
-- We are creating a partition for each quarter.
CREATE PARTITION FUNCTION Sales2007PartitionFunction(DATETIME)
AS
RANGE RIGHT FOR VALUES
(
	'20070401', -- Q2/2007: 2007/04/01 - 2007/06/30
	'20070701', -- Q2/2007: 2007/07/01 - 2007/09/30
	'20071001'  -- Q3/2007: 2007/10/01 - 2007/12/31
)
GO

-- Map each partition to the Sales2007 file group
CREATE PARTITION SCHEME Sales2007PartitionScheme
AS PARTITION Sales2007PartitionFunction ALL TO
(
	Sales2007FG
)
GO

-- Create the partitioned table for the year 2007
CREATE TABLE Sales2007
(
	DateKey DATETIME NOT NULL
		CONSTRAINT Sales2007CK -- The CHECK constraint is still needed to do Partition Elimination for the Partitioned View
			CHECK (DateKey >= '20070101' AND DateKey < '20080101'),
	OnlineSalesKey INT NOT NULL,
	SalesOrderNumber NVARCHAR(20) NOT NULL,
	SalesAmount MONEY NOT NULL
) ON Sales2007PartitionScheme (DateKey)
GO

-- Add a primary key clustered
ALTER TABLE Sales2007
ADD CONSTRAINT PK_Sales2007 PRIMARY KEY CLUSTERED 
(
	DateKey,
	OnlineSalesKey
) ON Sales2007PartitionScheme (DateKey)
GO

-- Load data into the partitioned table for the year 2007
INSERT INTO Sales2007 (DateKey, OnlineSalesKey, SalesOrderNumber, SalesAmount)
SELECT DateKey, OnlineSalesKey, SalesOrderNumber, SalesAmount FROM ContosoRetailDW.dbo.FactOnlineSales
WHERE DateKey >= '20070101' AND DateKey < '20080101'
GO

-- Check the data distribution for the year 2007.
-- Each partition has around 1mio records in it.
SELECT
	$PARTITION.Sales2007PartitionFunction(DateKey) AS 'Partition Number',
	MIN(DateKey) AS 'Minimum value',
	MAX(DateKey) AS 'Maximum value',
	COUNT(*) 'Rows in Partition'
FROM Sales2007
GROUP BY $PARTITION.Sales2007PartitionFunction(DateKey)
GO

-- ========================================
-- Set up the "Sales2008" partitioned table
-- ========================================

-- Create a new partition function for used by the "Sales2008" partitioned table.
-- We are creating a partition for each quarter.
CREATE PARTITION FUNCTION Sales2008PartitionFunction(DATETIME)
AS
RANGE RIGHT FOR VALUES
(
	'20080401', -- Q2/2008: 2008/04/01 - 2008/06/30
	'20080701', -- Q2/2008: 2008/07/01 - 2008/09/30
	'20081001'  -- Q3/2008: 2008/10/01 - 2008/12/31
)
GO

-- Map each partition to the Sales2008 file group
CREATE PARTITION SCHEME Sales2008PartitionScheme
AS PARTITION Sales2008PartitionFunction ALL TO
(
	Sales2008FG
)
GO

-- Create the partitioned table for the year 2008
CREATE TABLE Sales2008
(
	DateKey DATETIME NOT NULL
		CONSTRAINT Sales2008CK -- The CHECK constraint is still needed to do Partition Elimination for the Partitioned View
			CHECK (DateKey >= '20080101' AND DateKey < '20090101'),
	OnlineSalesKey INT NOT NULL,
	SalesOrderNumber NVARCHAR(20) NOT NULL,
	SalesAmount MONEY NOT NULL
) ON Sales2008PartitionScheme (DateKey)
GO

-- Add a primary key clustered
ALTER TABLE Sales2008
ADD CONSTRAINT PK_Sales2008 PRIMARY KEY CLUSTERED 
(
	DateKey,
	OnlineSalesKey
) ON Sales2008PartitionScheme (DateKey)
GO

-- Load data into the partitioned table for the year 2008
INSERT INTO Sales2008 (DateKey, OnlineSalesKey, SalesOrderNumber, SalesAmount)
SELECT DateKey, OnlineSalesKey, SalesOrderNumber, SalesAmount FROM ContosoRetailDW.dbo.FactOnlineSales
WHERE DateKey >= '20080101' AND DateKey < '20090101'
GO

-- Check the data distribution for the year 2008.
-- Each partition has around 1mio records in it.
SELECT
	$PARTITION.Sales2008PartitionFunction(DateKey) AS 'Partition Number',
	MIN(DateKey) AS 'Minimum value',
	MAX(DateKey) AS 'Maximum value',
	COUNT(*) 'Rows in Partition'
FROM Sales2008
GROUP BY $PARTITION.Sales2008PartitionFunction(DateKey)
GO

-- ========================================
-- Set up the "Sales2009" partitioned table
-- ========================================

-- Create a new partition function for used by the "Sales2009" partitioned table.
-- We are creating a partition for each quarter.
CREATE PARTITION FUNCTION Sales2009PartitionFunction(DATETIME)
AS
RANGE RIGHT FOR VALUES
(
	'20090401', -- Q2/2009: 2009/04/01 - 2009/06/30
	'20090701', -- Q2/2009: 2009/07/01 - 2009/09/30
	'20091001'  -- Q3/2009: 2009/10/01 - 2009/12/31
)
GO

-- Map each partition to the Sales2009 file group
CREATE PARTITION SCHEME Sales2009PartitionScheme
AS PARTITION Sales2009PartitionFunction ALL TO
(
	Sales2009FG
)
GO

-- Create the partitioned table for the year 2009
CREATE TABLE Sales2009
(
	DateKey DATETIME NOT NULL
		CONSTRAINT Sales2009CK -- The CHECK constraint is still needed to do Partition Elimination for the Partitioned View
			CHECK (DateKey >= '20090101' AND DateKey < '20100101'),
	OnlineSalesKey INT NOT NULL,
	SalesOrderNumber NVARCHAR(20) NOT NULL,
	SalesAmount MONEY NOT NULL
) ON Sales2009PartitionScheme (DateKey)
GO

-- Add a primary key clustered
ALTER TABLE Sales2009
ADD CONSTRAINT PK_Sales2009 PRIMARY KEY CLUSTERED 
(
	DateKey,
	OnlineSalesKey
) ON Sales2009PartitionScheme (DateKey)
GO

-- Load data into the partitioned table for the year 2009
INSERT INTO Sales2009 (DateKey, OnlineSalesKey, SalesOrderNumber, SalesAmount)
SELECT DateKey, OnlineSalesKey, SalesOrderNumber, SalesAmount FROM ContosoRetailDW.dbo.FactOnlineSales
WHERE DateKey >= '20090101' AND DateKey < '20100101'
GO

-- Check the data distribution for the year 2009.
-- Each partition has around 1mio records in it.
SELECT
	$PARTITION.Sales2009PartitionFunction(DateKey) AS 'Partition Number',
	MIN(DateKey) AS 'Minimum value',
	MAX(DateKey) AS 'Maximum value',
	COUNT(*) 'Rows in Partition'
FROM Sales2009
GROUP BY $PARTITION.Sales2009PartitionFunction(DateKey)
GO

-- Show Partition Elimination
-- This SELECT accesses the 3rd partition - Q3/2007
SELECT * FROM Sales2007
WHERE DateKey >= '20070721' AND DateKey <= '20070725'
GO

-- Show Partition Elimination across different partitions
-- This SELECT accesses the 3rd and 4th partition - Q3/2007 & Q4/2007
SELECT * FROM Sales2007
WHERE DateKey >= '20070721' AND DateKey <= '20071025'
GO

-- ========================================
-- Demonstrate Partion Level Index Rebuilds
-- ========================================

-- Partitions can be rebuild ONLINE only in SQL Server 2014!
ALTER INDEX PK_Sales2009 ON Sales2009 REBUILD PARTITION = 1 WITH
(
	ONLINE = ON
)
GO

-- ===================================================
-- Demonstrate Data Compression on the Partition Level
-- ===================================================

-- Estimate the compression savings for a specific partition
EXEC sp_estimate_data_compression_savings
	'dbo',
	'Sales2007', 
	1, -- IndexID: 1 - Clustered Index
	1, -- Partition Number
	'PAGE'
GO

-- We can now compress the table "Sales2007" that contain historical data, because it isn't changed anymore
ALTER INDEX PK_Sales2007 ON Sales2007 REBUILD 
WITH
(
	DATA_COMPRESSION = PAGE
)
GO

-- We can now compress the table "Sales2008" that contain historical data, because it isn't changed anymore
ALTER INDEX PK_Sales2008 ON Sales2008 REBUILD 
WITH
(
	DATA_COMPRESSION = PAGE
)
GO

-- We can now compress the first 3 partitions of the table "Sales2009", because we are currently inserting in Q4/2009.
-- Afterwards only Q4/2009 has uncompressed data stored - for performance optimization.
ALTER INDEX PK_Sales2009 ON Sales2009 REBUILD PARTITION = ALL
WITH
(
	DATA_COMPRESSION = PAGE ON PARTITIONS(1 TO 3)
)
GO

-- Set the filegroups for the year 2007 & 2008 readonly, because they only contain historical data.
-- Our operational data is currently in year 2009.
ALTER DATABASE VLDB MODIFY FILEGROUP Sales2007FG READONLY
ALTER DATABASE VLDB MODIFY FILEGROUP Sales2008FG READONLY
GO

-- ===========================
-- Set up the Partitioned View
-- ===========================

-- Create a Partitioned View on top of the 3 partitioned tables
CREATE VIEW Sales
AS
	SELECT * FROM Sales2007
	UNION ALL
	SELECT * FROM Sales2008
	UNION ALL
	SELECT * FROM Sales2009
GO

-- Show Partition Elimination across the Partitioned View.
-- This SELECT accesses the 3rd partition in the Sales2007 Partitioned Table.
SELECT * FROM Sales
WHERE DateKey >= '20070721' AND DateKey <= '20070725'
GO

-- Show Partition Elimination across the Partitioned View.
-- This SELECT accesses the 4th partition in the Sales2007 Partitioned Table, and the 1st and 2nd partition in the Sales2008 Partitioned Table.
SELECT * FROM Sales
WHERE DateKey >= '20071221' AND DateKey <= '20080405'
GO

-- The usage of the Partitioned View gives us table level statistics for each year.
-- We - still - have 200 steps in each statistics object.
DBCC SHOW_STATISTICS('Sales2007', 'PK_Sales2007')
DBCC SHOW_STATISTICS('Sales2008', 'PK_Sales2008')
DBCC SHOW_STATISTICS('Sales2009', 'PK_Sales2009')
GO

-- This stored procedure creates a write workload in the current partitioned table "Sales2009"
CREATE PROCEDURE WriteWorkload
AS
BEGIN
	DECLARE @max INT
	
	WHILE (1 = 1)
	BEGIN
		SELECT @max = MAX(OnlineSalesKey) FROM Sales2009

		INSERT INTO Sales2009 (DateKey, OnlineSalesKey, SalesOrderNumber, SalesAmount) VALUES('20091223', @max + 1, '', 12)
	END
END
GO

-- Let's do a full backup of the database
BACKUP DATABASE VLDB TO DISK = N'g:\temp\VLDB.bak' 
GO

-- Execute the workload in a different query window...
--EXEC WriteWorkload
--GO

-- Simulate some storage error...
-- ...

-- Now we have to set the file to the OFFLINE state.
-- Partial Database Availability is only supported on Enterprise Edition of SQL Server.
-- When we set the file OFFLINE, our session with the write workload is disconnected, so we must reconnect.
-- This can be transparently handled by the underlying application.
ALTER DATABASE VLDB MODIFY FILE
(
	NAME = 'Sales2007_Data',
	OFFLINE
)
GO

-- The file is now in the OFFLINE state
SELECT * FROM sys.database_files
GO

-- The data in the Partitioned Table that is OFFLINE, can't be accessed any more
SELECT * FROM Sales
WHERE DateKey >= '20070721' AND DateKey <= '20070725'
GO

-- But we can still access other Partitioned Tables
SELECT * FROM Sales
WHERE DateKey >= '20080721' AND DateKey <= '20080725'
GO

-- Backup the tail log - if the damaged file was a read/write file
BACKUP LOG VLDB TO DISK = 'g:\temp\TailLog.trn'
GO

-- We don't have to be in the database, when we want to restore it
USE master
GO

-- Restore the last full backup of the database for the specific file
RESTORE DATABASE VLDB
FILE = 'Sales2007_Data'
FROM DISK = 'g:\temp\VLDB.bak'
WITH
	FILE = 1,
	MOVE 'Sales2007_Data' TO 'g:\temp\Sales2007_Data.ndf',
	NORECOVERY
GO

-- Use the database
USE VLDB
GO

-- The file is now in the RESTORING state
SELECT * FROM sys.database_files
GO

USE master
GO

-- Restore the tail log backup
RESTORE LOG VLDB
FROM DISK = 'g:\temp\TailLog.trn'
WITH
	FILE = 1,
	RECOVERY -- Our database is now fully online
GO

-- Use the database
USE VLDB
GO

-- The file is now in the ONLINE state, and our database is fully operational
SELECT * FROM sys.database_files
GO

-- The data in the Partitioned Table that was previously OFFLINE, can be accessed now again
SELECT * FROM Sales
WHERE DateKey >= '20070721' AND DateKey <= '20070725'
GO

-- ==================================
-- Demonstrate DBCC CHECKDB for VLDBs
-- ==================================

-- Check the Sales2007 file group
DBCC CHECKFILEGROUP('Sales2007FG')
GO

-- Check the Sales2008 file group
DBCC CHECKFILEGROUP('Sales2008FG')
GO

-- Check the Sales2009 file group
DBCC CHECKFILEGROUP('Sales2009FG')
GO

-- Cleanup
USE master
GO

DROP DATABASE VLDB
GO