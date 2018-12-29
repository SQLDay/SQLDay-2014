/*============================================================================
  Summary:  Demonstrates Restrictions in the Version Store
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
CREATE DATABASE VersionStoreRestrictions
GO

-- Enable RCSI
ALTER DATABASE VersionStoreRestrictions SET READ_COMMITTED_SNAPSHOT ON
GO

-- Use it
USE VersionStoreRestrictions
GO

-- Create a new table with 8.000 bytes
CREATE TABLE TableA
(
	Column1 CHAR(8000)
)
GO

-- Insert a record
INSERT INTO TableA VALUES (REPLICATE('A', 8000))
GO

DBCC TRACEON (3604)
GO

-- Retrieve all pages for the table
DBCC IND(VersionStoreRestrictions, TableA, -1)
GO

-- Dump out the data page of the table.
-- The Row Version Pointer is currently NULL.
DBCC PAGE(VersionStoreRestrictions, 1, 79, 3)
GO

-- Execute an UPDATE statement.
-- This generates now a new version in the Version Store.
UPDATE TableA
SET Column1 = REPLICATE('B', 8000)
GO

-- There is now one row in the Version Store.
-- The row is splitted between 2 rows in the Version Store.
SELECT * FROM sys.dm_tran_version_store
GO

-- Now the Row Version Pointer points to a Row Version in TempDb
DBCC PAGE(VersionStoreRestrictions, 1, 79, 3)
GO

-- Dump out the Row Version in TempDb
DBCC PAGE(TempDb, 1, 369, 1)
GO

-- Create another table with a maximum row length of 8.060 bytes.
CREATE TABLE TableB
(
	Column1 CHAR(53),
	Column2 CHAR(8000)
)
GO

-- Insert a record
INSERT INTO TableB VALUES (REPLICATE('A', 53), REPLICATE('A', 8000))
GO

-- Generates an error, and the connection is afterwards broken
UPDATE TableB
SET Column1 = REPLICATE('B', 53)
GO

-- When we fully qualify the table, we get the exact error message:
-- "Internal error. Buffer provided to read column value is too small. Run DBCC CHECKDB to check for any corruption."
UPDATE VersionStoreRestrictions.dbo.TableB
SET Column1 = REPLICATE('B', 53)
GO