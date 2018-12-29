/*============================================================================
  Summary:  Demonstrates the Tipping Point
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

SET STATISTICS IO ON
SET STATISTICS TIME ON
GO

CREATE DATABASE TippingPoint
GO

USE TippingPoint
GO

-- Create a table with 393 length + 7 bytes overhead = 400 bytes
-- Therefore 20 records can be stored on one page (8.096 / 400) = 20,24
CREATE TABLE Customers
(
	CustomerID INT NOT NULL,
	CustomerName CHAR(100) NOT NULL,
	CustomerAddress CHAR(100) NOT NULL,
	Comments CHAR(185) NOT NULL,
	Value INT NOT NULL
)
GO

-- Create a unique clustered index on the previous created table
CREATE UNIQUE CLUSTERED INDEX idx_Customers ON Customers(CustomerID)
GO

-- Insert 80.000 records
DECLARE @i INT = 1
WHILE (@i <= 80000)
BEGIN
	INSERT INTO Customers VALUES
	(
		@i,
		'CustomerName' + CAST(@i AS CHAR),
		'CustomerAddress' + CAST(@i AS CHAR),
		'Comments' + CAST(@i AS CHAR),
		@i
	)
	
	SET @i += 1
END
GO

-- Create a new Non-Clustered Index, which we will use to demonstrate the tipping point
CREATE UNIQUE NONCLUSTERED INDEX idx_Test ON Customers(Value)
GO

-- Retrieve the inserted data
SELECT * FROM Customers
GO

-- Our table has 4.000 pages, so the tipping point is somewhere between reading 1.000 (1/4) and 1.333 (1/3) pages.
-- 1.000 / 80.000 = 1,25%
-- 1.333 / 80.000 = 1,67%

-- The following query does a bookmark lookup.
-- We are reading 1.062 records, which are about 1,3% of the overal table (1.062 / 80.000)
-- The query produces 3.265 I/Os, where about 1/3 are data page reads (~ 1.000)
SELECT * FROM Customers
WHERE Value < 1063
GO

-- The following query does a clustered index scan.
-- The query produces 4.016 I/Os.
SELECT * FROM Customers
WHERE Value < 1064
GO

-- Create a table with 40 bytes length.
-- Therefore 200 records can be stored on one page.
CREATE TABLE Customers2
(
	CustomerID INT NOT NULL,
	CustomerName CHAR(10) NOT NULL,
	CustomerAddress CHAR(10) NOT NULL,
	Comments CHAR(5) NOT NULL,
	Value INT NOT NULL
)
GO

-- Create a unique clustered index on the previous created table
CREATE UNIQUE CLUSTERED INDEX idx_Customers ON Customers2(CustomerID)
GO

-- Insert 80.000 records
DECLARE @i INT = 1
WHILE (@i <= 80000)
BEGIN
	INSERT INTO Customers2 VALUES
	(
		@i,
		CAST(@i AS CHAR(10)),
		CAST(@i AS CHAR(10)),
		CAST(@i AS CHAR(5)),
		@i
	)
	
	SET @i += 1
END
GO

-- Create a new Non-Clustered Index, which we will use to demonstrate the tipping point
CREATE UNIQUE NONCLUSTERED INDEX idx_Test ON Customers2(Value)
GO

-- Retrieve the inserted data
SELECT * FROM Customers2
GO

-- Our table has 400 pages, so the tipping point is somewhere between reading 100 (1/4) and 133 (1/3) pages.
-- 100 / 80.000 = 0,125%
-- 133 / 80.000 = 0,167%

-- The following query does a bookmark lookup.
-- We are reading 157 records, which are about 0,195% of the overal table (157 / 80.000)
-- The query produces 334 I/Os, where about 1/3 are data page reads (~ 110)
SELECT * FROM Customers2
WHERE Value < 158
GO

-- The following query does a clustered index scan.
-- The query produces 419 I/Os.
SELECT * FROM Customers2
WHERE Value < 159
GO

-- Clean up
USE master
GO

DROP DATABASE TippingPoint
GO