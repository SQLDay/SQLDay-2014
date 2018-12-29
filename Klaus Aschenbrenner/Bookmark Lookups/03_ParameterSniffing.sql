/*============================================================================
  Summary:  Demonstrates Parameter Sniffing
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

CREATE DATABASE ParameterSniffing
GO

USE ParameterSniffing
GO

SET STATISTICS IO ON
SET STATISTICS TIME ON
GO

-- Create a test table
CREATE TABLE Table1
(
	Column1 INT IDENTITY,
	Column2 INT
)
GO

-- Insert 1500 records into Table1
INSERT INTO Table1 (Column2) VALUES (1)

SELECT TOP 1499 IDENTITY(INT, 1, 1) AS n INTO #Nums
FROM
master.dbo.syscolumns sc1

INSERT INTO Table1 (Column2)
SELECT 2 FROM #nums
DROP TABLE #nums
GO

-- Retrieve the inserted records
SELECT * FROM Table1
GO

-- Create a Non-Clustered Index on column Column2
CREATE NONCLUSTERED INDEX idxTable1_Column2 ON Table1(Column2)
GO

-- Create a new stored procedure for data retrieval
CREATE PROCEDURE RetrieveData
(
	@Col2Value INT
)
AS
	SELECT * FROM Table1
	WHERE Column2 = @Col2Value
GO

-- Logical Page Read 3
EXEC RetrieveData 1
GO

-- Logical Page Reads 1505
EXEC RetrieveData 2
GO

-- Drop the Stored Procedure
DROP PROCEDURE RetrieveData
GO

-- Create a new stored procedure for data retrieval.
-- Now we use local variables instead of parameter values
CREATE PROCEDURE RetrieveData
(
	@Col2Value INT
)
AS
	DECLARE @Col2Var INT = @Col2Value
	
	SELECT * FROM Table1
	WHERE Column2 = @Col2Var -- SQL Server can't "sniff" that value anymore, SQL Server uses the Density Vectore
							 -- If we use an inequality predicate (<, >) SQL Server estimates 30% of the rows (1500 * 0,3 = 450)
GO

-- Clearing the Execution Plan cache, so that we can provide that the Execution Plan isn't cached anymore.
DBCC FreeProcCache
GO

-- Generates a Table Scan operator.
-- SQL Server uses the Desity Vector of the underlying statistics object to estimate the number of records (1500 * 0,5 = 750) 
-- Logical Page Read 4
EXEC RetrieveData 1
GO

-- Generates a Table Scan operator.
-- SQL Server uses the Desity Vector of the underlying statistics object to estimate the number of records (1500 * 0,5 = 750) 
-- Logical Page Reads 4
EXEC RetrieveData 2
GO

-- Drop the Stored Procedure
DROP PROCEDURE RetrieveData
GO

-- Create a new stored procedure for data retrieval.
-- Now we use the RECOMPILE option on the Stored Procedure level
CREATE PROCEDURE RetrieveData
(
	@Col2Value INT
)
WITH RECOMPILE -- Stored Procedure will be now recompiled every time when executed
AS
	SELECT * FROM Table1
	WHERE Column2 = @Col2Value
GO

-- Clearing the Execution Plan cache, so that we can provide that the Execution Plan isn't cached anymore.
DBCC FreeProcCache
GO

-- Generates a Bookmark Lookup operator.
-- Logical Page Read 3
EXEC RetrieveData 1
GO

-- Generates a Table Scan operator.
-- Logical Page Reads 4
EXEC RetrieveData 2
GO

-- Drop the Stored Procedure
DROP PROCEDURE RetrieveData
GO

-- Create a new stored procedure for data retrieval.
-- Now we use the RECOMPILE option on the statement level
CREATE PROCEDURE RetrieveData
(
	@Col2Value INT
)
AS
	SELECT * FROM Table1
	WHERE Column2 = @Col2Value
	
	SELECT * FROM Table1
	WHERE Column2 = @Col2Value
	OPTION (RECOMPILE) -- Now we use the query hint on a statement level
GO

-- Clearing the Execution Plan cache, so that we can provide that the Execution Plan isn't cached anymore.
DBCC FreeProcCache
GO

-- Generates a Bookmark Lookup operator.
-- Logical Page Reads 3 and 3
EXEC RetrieveData 1
GO

-- Generates a Table Scan operator.
-- Logical Page Reads 1505 and 4
EXEC RetrieveData 2
GO

-- Drop the Stored Procedure
DROP PROCEDURE RetrieveData
GO

-- Create a new stored procedure for data retrieval.
CREATE PROCEDURE RetrieveData
(
	@Col2Value INT
)
AS
	SELECT * FROM Table1
	WHERE Column2 = @Col2Value
	OPTION (OPTIMIZE FOR (@Col2Value = 1)) -- Now we optimize it for the value 2 (=> Bookmark Lookup operator)
GO

-- Clearing the Execution Plan cache, so that we can provide that the Execution Plan isn't cached anymore.
DBCC FreeProcCache
GO

-- Generates a Bookmark Lookup.
-- Logical Page Read 1505.
EXEC RetrieveData 2
GO

-- Generates a Bookmark Lookup.
-- Logical Page Reads 3.
EXEC RetrieveData 1
GO

-- Drop the Stored Procedure
DROP PROCEDURE RetrieveData
GO

-- Create a new stored procedure for data retrieval.
CREATE PROCEDURE RetrieveData
(
	@Col2Value INT
)
AS
	SELECT * FROM Table1
	WHERE Column2 = @Col2Value
	
	-- Now we optimize it for UNKNOWN.
	-- SQL Server uses the Density Vector to perform the Cardinality Estimation
	OPTION (OPTIMIZE FOR UNKNOWN) 
GO

-- Clearing the Execution Plan cache, so that we can provide that the Execution Plan isn't cached anymore.
DBCC FreeProcCache
GO

-- Generates a Table Scan operator.
-- Logical Page Read 4.
EXEC RetrieveData 1
GO

-- Generates a Table Scan operator.
-- Logical Page Read 4.
EXEC RetrieveData 2
GO

-- Drop the Stored Procedure
DROP PROCEDURE RetrieveData
GO

-- Create a new stored procedure for data retrieval.
-- Don't use any query hints, because we can't change the implementation...
CREATE PROCEDURE RetrieveData
(
	@Col2Value INT
)
AS
	SELECT * FROM Table1 WHERE Column2 = @Col2Value
GO

-- Let's now attach a Plan Guide to the Stored Procedure
sp_create_plan_guide
	@name = N'PlanGuide_For_RetrieveData_StoredProcedure',
	@stmt =
	N'
		SELECT * FROM Table1 WHERE Column2 = @Col2Value
	',
	@type = N'OBJECT',
	@module_or_batch = N'dbo.RetrieveData',
	@params = NULL,
	@hints = N'OPTION (OPTIMIZE FOR (@Col2Value = 1))' -- Optimize the execution for the value 1
GO

-- Generates a Bookmark Lookup operator.
-- Logical Page Read 1505.
EXEC RetrieveData 2
GO

-- Generates a Bookmark Lookup operator.
-- Logical Page Read 3.
EXEC RetrieveData 1
GO

-- Drop the previous created plan guide
sp_control_plan_guide N'DROP', N'PlanGuide_For_RetrieveData_StoredProcedure'
GO

-- Clean up
USE master
GO

DROP DATABASE ParameterSniffing
GO