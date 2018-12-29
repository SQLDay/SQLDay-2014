USE Indices
GO

CREATE INDEX CustomersLastName
ON [dbo].[Customers]([LastName]);
GO

--Show execution plan
SELECT [CustomerID]
FROM [dbo].[Customers]
WHERE [LastName] = 'Szeliga' 
	OR [LastName] = 'SZELIGA'
AND [MiddleName] IS NOT NULL;

SELECT [CustomerID]
FROM [dbo].[Customers]
WHERE UPPER([LastName]) = 'SZELIGA'
AND [MiddleName] IS NOT NULL;
GO

ALTER TABLE [dbo].[Customers]
ADD LastNameUpper AS UPPER(LastName);
GO

CREATE INDEX CustomersLastNameUpper
ON dbo.[Customers](LastNameUpper)
WHERE [MiddleName] IS NOT NULL;
GO

SELECT OBJECT_NAME(object_id), name, INDEX_ID
FROM sys.indexes
WHERE OBJECT_NAME(object_id) = 'Customers';

SELECT OBJECT_NAME (object_id), index_id, page_count
FROM sys.dm_db_index_physical_stats (
	db_id(), OBJECT_ID('Customers'), null, null, 'limited');
GO

SELECT [CustomerID]
FROM [dbo].[Customers]
WHERE UPPER([LastName]) = 'SZELIGA'
AND [MiddleName] IS NOT NULL;

SELECT [CustomerID]
FROM [dbo].[Customers] WITH (INDEX(3))
WHERE UPPER([LastName]) = 'SZELIGA'
AND [MiddleName] IS NOT NULL;
GO

DROP INDEX CustomersLastNameUpper
ON dbo.[Customers];
GO