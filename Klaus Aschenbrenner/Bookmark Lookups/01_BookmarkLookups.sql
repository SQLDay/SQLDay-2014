/*============================================================================
  Summary:  Demonstrates Bookmark Lookups
------------------------------------------------------------------------------
  Written by Klaus Aschenbrenner, SQLpassion.at

  For more scripts and sample code, check out 
    http://www.SQLpassion.at

  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE AdventureWorks2012
GO

SET STATISTICS IO ON
SET STATISTICS TIME ON
GO

-- Demonstrates a bookmark lookup query on a heap table
-- The column "DatabaseLogID" is stored in the non clustered index.
-- The column "DatabaseUser" is stored directly in the heap table
-- Therefore SQL Server uses here the following operators:
-- 1. Non-Clustered Index Seek operator: retrieves the column "DatabaseLogID" from the non clustered index
-- 2. RID Lookup operator: retrieves the column "DatabaseUser" from the heap table
-- 3. Nested Loop operator: joins both result sets together
-- 4. SELECT operator: returns the final result set
SELECT
	DatabaseLogID,
	DatabaseUser
FROM DatabaseLog
WHERE DatabaseLogID = 15
GO

-- Demonstrate a bookmark lookup query on an indexed table
-- The columns "EmailAddress" and "EmailAddressID" are stored in the non clustered index.
-- The column "MofifiedDate" must be retrieved from the clustered index, therefore SQL Server
-- uses here the following operators:
-- 1. Non-Clustered Index Seek operator: retrieves the columns "EmailAddress" and "EmailAddressID" from the non clustered index
-- 2. Clustered Key Lookup operator: retrieves for each found record from the previous step the column "ModifiedDate"
-- 3. Nested Loop operator: joins both result sets together
-- 4. SELECT operator: returns the final result set
SELECT
	EmailAddressID,
	EmailAddress,
	ModifiedDate
FROM Person.EmailAddress
WHERE EmailAddress LIKE 'sab%'
GO

-- The PostalCode and the StateProvince column are used by this query
-- By default no non-clustered index contains these columns, therefore a bookmark lookup is done:
-- 1. Non-Clustered Index Seek
-- 2. Clustered Key Lookup
-- Result: 240 logical reads
SELECT
	AddressID,
	ModifiedDate
FROM Person.Address
WHERE StateProvinceID = 42
GO

-- Create a new non-clustered index that includes the PostalCode column
CREATE NONCLUSTERED INDEX idxAddress_StateProvinceID ON
Person.Address (StateProvinceID)
INCLUDE (ModifiedDate)
GO

-- Rerun the original query
-- Result: 2 logical reads, because SQL Server doesn't need to touch the base table
-- Everything is read from the non-clustered index
SELECT
	AddressID,
	ModifiedDate
FROM Person.Address
WHERE StateProvinceID = 42
GO

-- Drop the previous created index
DROP INDEX idxAddress_StateProvinceID ON Person.Address
GO