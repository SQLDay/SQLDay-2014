/*============================================================================
  Summary:  Demonstrates the Version Store
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
CREATE DATABASE VersionStoreDemo
GO

-- Enable RCSI
ALTER DATABASE VersionStoreDemo SET READ_COMMITTED_SNAPSHOT ON
GO

-- Use it
USE VersionStoreDemo
GO

-- Create a new table
CREATE TABLE TestTable
(
	Column1 INT,
	Column2 INT,
	Column3 CHAR(100)
)
GO

-- Insert a record
INSERT INTO TestTable VALUES (1, 1, REPLICATE('A', 100))
GO

-- Look into the version store - currently the Version Store is empty.
-- INSERT statements are not generating versions, only UPDATEs and DELETEs.
SELECT * FROM sys.dm_tran_version_store
WHERE database_id = DB_ID('VersionStoreDemo')
GO

-- Execute an UPDATE statement.
-- This generates now a new version in the Version Store.
UPDATE TestTable
SET Column3 = REPLICATE('B', 100)
WHERE Column1 = 1
GO

-- Query the Version Store again - now it returns one row for our database.
SELECT * FROM sys.dm_tran_version_store
WHERE database_id = DB_ID('VersionStoreDemo')
GO

-- The "first_useful_sequence_num" is one larger than "last_transaction_sequence_num".
-- All rows smaller than "first_useful_sequence_num" are deleted from the version store in a one-minute interval.
SELECT * FROM sys.dm_tran_current_transaction
GO

-- Begin a new transaction in a different session that reads the current row.
-- This now means that this row (and all subsequent rows) can't be deleted from the Version Store, because they are
-- needed because of the openend transaction.
-- ...

-- Now "first_useful_sequence_num" remains the same, and only "last_transaction_sequence_num" was increased by 1.
SELECT * FROM sys.dm_tran_current_transaction
GO

-- Execute an UPDATE statement.
-- This generates now a new version in the Version Store.
UPDATE TestTable
SET Column3 = REPLICATE('C', 100)
WHERE Column1 = 1
GO

-- Query the Version Store again - now it returns several rows for our database.
SELECT * FROM sys.dm_tran_version_store
WHERE database_id = DB_ID('VersionStoreDemo')
GO

-- Now "first_useful_sequence_num" remains the same, and only "last_transaction_sequence_num" was increased by 1.
SELECT * FROM sys.dm_tran_current_transaction
GO

-- Execute an UPDATE statement.
-- This generates now a new version in the Version Store.
UPDATE TestTable
SET Column3 = REPLICATE('D', 100)
WHERE Column1 = 1
GO

-- Query the Version Store again - now it returns several rows for our database.
SELECT * FROM sys.dm_tran_version_store
WHERE database_id = DB_ID('VersionStoreDemo')
GO

-- Now "first_useful_sequence_num" remains the same, and only "last_transaction_sequence_num" was increased by 1.
SELECT * FROM sys.dm_tran_current_transaction
GO

DBCC TRACEON (3604)
GO

-- Retrieve all pages for the table
DBCC IND(VersionStoreDemo, TestTable, -1)
GO

-- Dump out the data page of the table
-- This are the last 14 bytes of the record:
-- 88090000 0100 0200 120100000000
-- 88090000: Page-Id: 2440
-- 0100: File-Id: 1
-- 0200: Slot-Id: 2
-- 120100000000: XSN: 274
DBCC PAGE(VersionStoreDemo, 1, 79, 3)
GO

-- Dump out the data page in TempDb to which the current record in the database points
-- This are the lats 14 bytes of the record:
-- 88090000 0100 0100 110100000000
-- 88090000: Page-Id: 2440
-- 0100: File-Id: 1
-- 0100: Slot-Id: 1
-- 110100000000: XSN: 273
DBCC PAGE(tempdb, 1, 2440, 1)
GO

-- Check which database generates the most versions on the SQL Server instance
SELECT * FROM sys.dm_tran_top_version_generators
GO

-- Clean up
USE master
GO

DROP DATABASE VersionStoreDemo
GO