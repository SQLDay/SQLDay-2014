USE Indices
GO

--Basic indexing strategy

EXEC sp_helpindex '[dbo].[SalesOrderDetail]';
GO

SET STATISTICS IO ON
--Turn on actual execution plan (Ctrl+M)
GO

SELECT [ProductID], SUM([UnitPrice]) AS TotalPrice
FROM dbo.[SalesOrderDetail]    
GROUP BY [ProductID]
ORDER BY [ProductID]
OPTION (MAXDOP 1);
GO
--Cost: 20.9515
--Memory grant: 1632
--Reads: 19 099

--Covering index
CREATE INDEX Covering
ON dbo.[SalesOrderDetail] ([UnitPrice],[ProductID]);
GO

SELECT [ProductID], SUM([UnitPrice]) AS TotalPrice
FROM dbo.[SalesOrderDetail]    
GROUP BY [ProductID]
ORDER BY [ProductID]
OPTION (MAXDOP 1);
GO
--Cost: 9.740
--Memory grant: 1632
--Reads: 3924

--POC index
CREATE INDEX POC
ON dbo.[SalesOrderDetail] ([ProductID],[UnitPrice]);
GO

SELECT [ProductID], SUM([UnitPrice]) AS TotalPrice
FROM dbo.[SalesOrderDetail]    
GROUP BY [ProductID]
ORDER BY [ProductID]
OPTION (MAXDOP 1);
GO
--Cost: 4.956
--Memory grant: NONE
--Reads: 3923

--Indexed views
CREATE VIEW dbo.[_SumUnitPriceByProducts]
WITH SCHEMABINDING
AS
SELECT [ProductID], SUM([UnitPrice]) AS TotalPrice, COUNT_BIG(*) AS NumberOfProducts
FROM dbo.[SalesOrderDetail]    
GROUP BY [ProductID];
GO

CREATE UNIQUE CLUSTERED INDEX IndexedView
ON dbo.[_SumUnitPriceByProducts] ([ProductID]);
GO

SELECT *
FROM dbo.[_SumUnitPriceByProducts]
ORDER BY [ProductID];
GO
--Cost: 0.003
--Memory grant: NONE
--Reads: 2

CREATE VIEW dbo.[SumUnitPriceByProducts]
AS 
SELECT *
FROM dbo.[_SumUnitPriceByProducts] WITH (NOEXPAND);
GO

SELECT *
FROM dbo.[SumUnitPriceByProducts]
ORDER BY [ProductID];
GO


--EE only
SELECT [ProductID], SUM([UnitPrice]) AS TotalPrice
FROM dbo.[SalesOrderDetail]    
GROUP BY [ProductID];

SELECT [ProductID], AVG([UnitPrice]) AS TotalPrice
FROM dbo.[SalesOrderDetail]    
GROUP BY [ProductID];