USE Indices
GO

DROP VIEW [dbo].[_SumUnitPriceByProducts];
DROP VIEW [dbo].[SumUnitPriceByProducts];
--Show execution plan

BEGIN TRAN
UPDATE [SalesOrderDetailV2] 
SET [UnitPrice] = [UnitPrice]+1
WHERE [ProductID] % 10 = 0;
GO

--Query Cost:14.9
ROLLBACK
GO

SELECT COUNT (DISTINCT [ProductID]) AS ProductIDs, 
	COUNT (DISTINCT [SpecialOfferID]) AS SpecialOfferIDs,
	COUNT (DISTINCT [SalesOrderID]) AS SalesOrderIDs, 
	COUNT(*) AS Rows
FROM  [SalesOrderDetailV2];
GO

CREATE VIEW [_SumUnitPricesByProducts]
WITH SCHEMABINDING
AS
SELECT [ProductID], SUM([UnitPrice]) AS TotalPrice, COUNT_BIG(*) AS NumberOfProducts
FROM [dbo].[SalesOrderDetailV2]  
GROUP BY [ProductID];
GO
CREATE UNIQUE CLUSTERED INDEX Idx1
ON [_SumUnitPricesByProducts] ([ProductID]);
GO

SELECT OBJECT_NAME (object_id), index_id, page_count
FROM sys.dm_db_index_physical_stats (
	db_id(), OBJECT_ID('_SumUnitPricesByProducts'), null, null, 'limited');
GO

BEGIN TRAN
UPDATE [SalesOrderDetailV2] 
SET [UnitPrice] = [UnitPrice]+1
WHERE [ProductID] % 10 = 0;
GO

--Query Cost:15.49
ROLLBACK
GO

DROP VIEW [_SumUnitPricesByProducts];
GO

CREATE VIEW [_SumUnitPricesBySpecialOffer]
WITH SCHEMABINDING
AS
SELECT [SpecialOfferID], SUM([UnitPrice]) AS TotalPrice, COUNT_BIG(*) AS NumberOfProducts
FROM [dbo].[SalesOrderDetailV2]
GROUP BY [SpecialOfferID];
GO
CREATE UNIQUE CLUSTERED INDEX Idx1
ON [_SumUnitPricesBySpecialOffer] ([SpecialOfferID]);
GO

BEGIN TRAN
UPDATE [SalesOrderDetailV2] 
SET [UnitPrice] = [UnitPrice]+1
WHERE [ProductID] % 10 = 0;
GO

--Query Cost: 15.5
ROLLBACK
GO

DROP VIEW [_SumUnitPricesBySpecialOffer];
GO

CREATE VIEW [_SumUnitPricesBySalesOrder]
WITH SCHEMABINDING
AS
SELECT [SalesOrderID], SUM([UnitPrice]) AS TotalPrice, COUNT_BIG(*) AS NumberOfProducts
FROM [dbo].[SalesOrderDetailV2] 
GROUP BY [SalesOrderID];
GO
CREATE UNIQUE CLUSTERED INDEX Idx1
ON [_SumUnitPricesBySalesOrder] ([SalesOrderID]);
GO

BEGIN TRAN
UPDATE [SalesOrderDetailV2] 
SET [UnitPrice] = [UnitPrice]+1
WHERE [ProductID] % 10 = 0;
GO

--Query Cost:15.6
ROLLBACK
GO

DROP VIEW [_SumUnitPricesBySalesOrder];
GO