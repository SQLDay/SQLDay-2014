-----------------------
--ColumnStore in action
-----------------------

USE AdventureWorksDW2012;
GO

SELECT 
  CONCAT(D.CalendarYear, '-', RIGHT(CONCAT('0', D.MonthNumberOfYear), 2)) AS Month,
  SUM(F.SalesAmount) AS SalesAmount
FROM dbo.FactInternetSalesBig AS F
INNER JOIN dbo.DimDate AS D
ON F.OrderDateKey = D.DateKey
GROUP BY D.CalendarYear, D.MonthNumberOfYear
ORDER BY D.CalendarYear, D.MonthNumberOfYear;
GO

SELECT COUNT(*) FROM dbo.FactInternetSalesBig;
GO

---------------------
--Limitations
---------------------

--Setup
USE master;
GO

IF DB_ID('DemoDB') IS NOT NULL
BEGIN
  ALTER DATABASE DemoDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE DemoDB;
END;
GO

CREATE DATABASE DemoDB
CONTAINMENT = NONE
ON  PRIMARY ( 
	NAME = N'DemoDB', 
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQL2014\MSSQL\DATA\DemoDB.mdf', 
	SIZE = 100MB, 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 100MB 
)
LOG ON ( 
	NAME = N'DemoDB_log', 
  FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQL2014\MSSQL\DATA\DemoDB_log.ldf', 
  SIZE = 100MB, 
  MAXSIZE = 2048GB, 
  FILEGROWTH = 100MB)
GO

ALTER DATABASE DemoDB SET RECOVERY SIMPLE; 
GO

USE DemoDB;
GO

CREATE TYPE dbo.aaa_user_type FROM int NULL;
GO

SET NOCOUNT ON;
DECLARE @t TABLE (name sysname, allowed bit);
DECLARE @sql nvarchar(4000);
DECLARE c CURSOR
READ_ONLY
FOR 
  SELECT name 
  FROM sys.types 
  ORDER BY name;

DECLARE @name sysname;
OPEN c;

FETCH NEXT FROM c INTO @name;
WHILE @@fetch_status = 0
BEGIN
  SET @sql = 'IF OBJECT_ID(''dbo.t'', ''U'') IS NOT NULL
  DROP TABLE dbo.t;
CREATE TABLE dbo.t (
  c1 ' + @name + '
);
CREATE CLUSTERED COLUMNSTORE INDEX IX_CS_t ON dbo.t;'
  BEGIN TRY
    EXEC(@sql);
    INSERT INTO @t (name, allowed)
    VALUES (@name, 1);
  END TRY
  BEGIN CATCH
    INSERT INTO @t (name, allowed)
    VALUES (@name, 0);
    GOTO FINISH;
  END CATCH;
  FINISH:
	  FETCH NEXT FROM c INTO @name;
END

CLOSE c;
DEALLOCATE c;

SELECT name FROM @t WHERE allowed = 0;
GO

--Test nvarchar(max)
IF OBJECT_ID('dbo.t', 'U') IS NOT NULL
  DROP TABLE dbo.t;
CREATE TABLE dbo.t (
  c1 nvarchar(max)
);
CREATE CLUSTERED COLUMNSTORE INDEX IX_CS_t ON dbo.t;
GO

--Cleanup
SET NOCOUNT OFF;
DROP TABLE dbo.t;
GO

/*

-Is the only allowable index on the table.
-Cannot have unique constraints, primary key constraints, or foreign key constraints.
-Are only available in the Enterprise, Developer, and Evaluation editions.
-Cannot have more than 1024 columns.
-Cannot be created on a view or indexed view.
-Cannot include a sparse column.
-Cannot be changed by using the ALTER INDEX statement. You can use ALTER INDEX to disable and rebuild a columnstore index.
-Cannot be created by using the INCLUDE keyword.
-Cannot include the ASC or DESC keywords for sorting the index. 
-Cannot create a trigger on the table.
-Cannot have computed columns.
-Cannot use with SNAPSHOT isolation level.

*/

-------------------
--Errors
-------------------

SELECT * 
FROM sys.sysmessages
WHERE error IN (
  SELECT error
  FROM sys.sysmessages 
  WHERE description LIKE '%clustered columnstore%' 
  AND msglangid = 1033
) 
AND msglangid IN (1033, 1045)
ORDER BY error;
GO

-------------------
--Metadata
-------------------

--Setup
IF OBJECT_ID('dbo.FactInternetSalesBig') IS NOT NULL
  DROP TABLE dbo.FactInternetSalesBig;
GO

SELECT
  SalesOrderNumber,
  SalesOrderLineNumber,
  ProductKey, 
  OrderDateKey, 
  CustomerKey, 
  PromotionKey, 
  CurrencyKey, 
  SalesTerritoryKey, 
  OrderQuantity, 
  UnitPrice, 
  SalesAmount, 
  TaxAmt, 
  Freight
INTO dbo.FactInternetSalesBig
FROM AdventureWorksDW2012.dbo.FactInternetSales;
GO

CREATE CLUSTERED COLUMNSTORE INDEX CCI_FactInternetSalesBig ON dbo.FactInternetSalesBig;
GO

SELECT COUNT(*) FROM dbo.FactInternetSalesBig;
GO

--Metadata
EXEC sp_helpindex 'dbo.FactInternetSalesBig';
GO

SELECT * 
FROM sys.indexes
WHERE type_desc = 'CLUSTERED COLUMNSTORE';
GO

SELECT * 
FROM sys.index_columns 
WHERE object_id = OBJECT_ID('dbo.FactInternetSalesBig') AND index_id = 1;
GO

--Row groups
SELECT * FROM sys.column_store_row_groups;
GO

--Segments
SELECT c.name, s.*
FROM sys.indexes AS i
INNER JOIN sys.partitions AS p
ON i.object_id = p.object_id 
AND i.index_id = p.index_id
INNER JOIN sys.column_store_segments AS s
ON s.partition_id = p.partition_id
AND s.hobt_id = p.hobt_id
INNER JOIN sys.columns AS c
ON p.object_id = c.object_id
AND s.column_id = c.column_id
WHERE i.name = 'CCI_FactInternetSalesBig'
--AND c.name = 'OrderDateKey'
ORDER BY s.column_id, s.segment_id, s.min_data_id, s.max_data_id;
GO

--Dictionaries
SELECT * 
FROM sys.column_store_dictionaries;
GO

--Size
SELECT SUM(on_disk_size_MB) AS TotalSizeInMB
FROM
(
  (
    SELECT SUM(css.on_disk_size)/(1024.0*1024.0) on_disk_size_MB
    FROM sys.indexes AS i
    JOIN sys.partitions AS p
    ON i.object_id = p.object_id 
    JOIN sys.column_store_segments AS css
    ON css.hobt_id = p.hobt_id
    WHERE i.object_id = object_id('dbo.FactInternetSalesBig') 
    AND i.type_desc = 'CLUSTERED COLUMNSTORE'
  ) 
  UNION ALL
  (
    SELECT SUM(csd.on_disk_size)/(1024.0*1024.0) on_disk_size_MB
    FROM sys.indexes AS i
    JOIN sys.partitions AS p
    ON i.object_id = p.object_id 
    JOIN sys.column_store_dictionaries AS csd
    ON csd.hobt_id = p.hobt_id
    WHERE i.object_id = object_id('dbo.FactInternetSalesBig') 
    AND i.type_desc = 'CLUSTERED COLUMNSTORE'
  ) 
) AS SegmentsPlusDictionary;
GO

EXEC sp_spaceused 'dbo.FactInternetSalesBig';
GO

------------------------
--Monitoring: XE objects
------------------------

SELECT * 
FROM sys.dm_xe_objects 
WHERE name LIKE '%column%store%' 
GO  

-------------------------------
--Usage stats and fragmentation
-------------------------------

SELECT * 
FROM sys.dm_db_index_usage_stats 
WHERE object_id = OBJECT_ID('dbo.FactInternetSalesBig');
GO

SELECT * 
FROM sys.dm_db_index_physical_stats(
  DB_ID(), OBJECT_ID('dbo.FactInternetSalesBig'), 1, NULL, 'DETAILED'
) AS Q;
GO

------------------
--DBCC
------------------

DBCC TRACEON(2588);
DBCC HELP('?');
GO

DBCC HELP('csindex');
GO

--dbcc csindex ( {'dbname' | dbid}, rowsetid, columnid, rowgroupid, object type, print option, start, end)

SELECT DB_ID() AS db_id, s.hobt_id, s.column_id, s.* 
FROM sys.column_store_segments AS s
INNER JOIN sys.partitions AS p 
ON s.partition_id = p.partition_id
WHERE p.object_id = OBJECT_ID('dbo.FactInternetSalesBig');
GO

DBCC TRACEON (3604);
DBCC CSINDEX (7, 72057594046382080, 5, 0, 1, 1);
GO

------------------
--DML - INSERT
------------------

--Table of numbers
IF OBJECT_ID('dbo.Numbers') IS NOT NULL
  DROP TABLE dbo.Numbers;
GO

CREATE TABLE dbo.Numbers (
  Number int NOT NULL PRIMARY KEY
);
GO

INSERT INTO dbo.Numbers (Number)
SELECT ROW_NUMBER() OVER (ORDER BY t1.number)
FROM master.dbo.spt_values AS t1, master.dbo.spt_values AS t2
WHERE t1.type = 'P' AND t2.type = 'P'
AND t1.number BETWEEN 1 AND 1024
AND t2.number BETWEEN 1 AND 1024;
GO

IF OBJECT_ID('dbo.T') IS NOT NULL
  DROP TABLE dbo.T;
GO

CREATE TABLE dbo.T (
  C int NOT NULL
);
GO

CREATE CLUSTERED COLUMNSTORE INDEX CCI_T ON dbo.T;
GO

INSERT INTO dbo.T (C)
SELECT Number
FROM dbo.Numbers
WHERE Number BETWEEN 1 AND 100000;
GO

INSERT INTO dbo.T (C)
SELECT Number
FROM dbo.Numbers
WHERE Number BETWEEN 100001 AND 202400;
GO

INSERT INTO dbo.T (C)
SELECT Number
FROM dbo.Numbers
WHERE Number BETWEEN 202401 AND 204800;
GO

INSERT INTO dbo.T (C)
SELECT Number
FROM dbo.Numbers
WHERE Number = 202401;
GO

INSERT INTO dbo.T (C)
SELECT Number
FROM dbo.Numbers
WHERE Number BETWEEN 204802 AND 307201;
GO

SELECT * 
FROM sys.partitions 
WHERE object_id = OBJECT_ID('dbo.T');
GO

--************** Change container_id ***************
SELECT * 
FROM sys.allocation_units 
WHERE container_id = 72057594046971904;
GO

DBCC IND ('DemoDB', 'dbo.T', 1);
GO

SELECT * 
FROM sys.dm_db_database_page_allocations(
  DB_ID(), OBJECT_ID('dbo.T'), 1, NULL, 'DETAILED'
);
GO

DBCC TRACEON(3604);
DBCC PAGE(DemoDB, 1, 10809, 3) WITH TABLERESULTS;
GO

--Cleanup
DROP TABLE dbo.T;
GO

----------------------------
--INSERT and performance
----------------------------

IF OBJECT_ID('dbo.FactInternetSalesBig') IS NOT NULL
  DROP TABLE dbo.FactInternetSalesBig;
GO

SELECT TOP 0 
  SalesOrderNumber,
  SalesOrderLineNumber,
  ProductKey, 
  OrderDateKey, 
  CustomerKey, 
  PromotionKey, 
  CurrencyKey, 
  SalesTerritoryKey, 
  OrderQuantity, 
  UnitPrice, 
  SalesAmount, 
  TaxAmt, 
  Freight
INTO dbo.FactInternetSalesBig
FROM AdventureWorksDW2012.dbo.FactInternetSales;
GO

CREATE CLUSTERED COLUMNSTORE INDEX CCI_FactInternetSalesBig ON dbo.FactInternetSalesBig;
GO

INSERT INTO dbo.FactInternetSalesBig (
  SalesOrderNumber,
  SalesOrderLineNumber,
  ProductKey, 
  OrderDateKey, 
  CustomerKey, 
  PromotionKey, 
  CurrencyKey, 
  SalesTerritoryKey, 
  OrderQuantity, 
  UnitPrice, 
  SalesAmount, 
  TaxAmt, 
  Freight
)
SELECT 
  'SO' + RIGHT('000000000000' + CONVERT(varchar(12), DENSE_RANK() OVER (ORDER BY SalesOrderNumber)+43430), 12) AS SalesOrderNumber,
  SalesOrderLineNumber, ProductKey, OrderDateKey, CustomerKey, PromotionKey, CurrencyKey, SalesTerritoryKey, OrderQuantity, UnitPrice, SalesAmount, TaxAmt, Freight
FROM AdventureWorksDW2012.dbo.FactInternetSales;
GO

INSERT INTO dbo.FactInternetSalesBig (
  SalesOrderNumber,
  SalesOrderLineNumber,
  ProductKey, 
  OrderDateKey, 
  CustomerKey, 
  PromotionKey, 
  CurrencyKey, 
  SalesTerritoryKey, 
  OrderQuantity, 
  UnitPrice, 
  SalesAmount, 
  TaxAmt, 
  Freight
)
SELECT TOP 50000
  'SO' + RIGHT('00000000' + CONVERT(varchar(12), DENSE_RANK() OVER (ORDER BY SalesOrderNumber)+(SELECT MAX(CONVERT(int, RIGHT(SalesOrderNumber, 12))) FROM dbo.FactInternetSalesBig)), 12),
  ROW_NUMBER() OVER (PARTITION BY SalesOrderNumber ORDER BY SalesOrderLineNumber), 
  ProductKey, OrderDateKey, CustomerKey, PromotionKey, CurrencyKey, SalesTerritoryKey, OrderQuantity, UnitPrice, SalesAmount, TaxAmt, Freight
FROM AdventureWorksDW2012.dbo.FactInternetSales
ORDER BY NEWID();
CHECKPOINT;
GO 20

SELECT COUNT(*) FROM dbo.FactInternetSalesBig;
GO

DBCC DROPCLEANBUFFERS;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT ProductKey, SUM(SalesAmount)
FROM dbo.FactInternetSalesBig
GROUP BY ProductKey
ORDER BY ProductKey;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

ALTER INDEX CCI_FactInternetSalesBig ON dbo.FactInternetSalesBig REBUILD;
GO

------------------
--DDL
------------------

SELECT COUNT(*) FROM dbo.FactInternetSalesBig;
GO

ALTER TABLE dbo.FactInternetSalesBig
ADD NewColumn int NOT NULL CONSTRAINT DF_FactInternetSalesBig_NewColumn DEFAULT(0);
GO

SELECT TOP 10 * FROM dbo.FactInternetSalesBig;
GO

SELECT c.name, ic.*
FROM sys.index_columns AS ic 
INNER JOIN sys.columns AS c
ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE ic.object_id = OBJECT_ID('dbo.FactInternetSalesBig') AND index_id = 1;
GO

--ALTER TABLE dbo.FactInternetSalesBig
--DROP CONSTRAINT DF_FactInternetSalesBig_NewColumn;
--GO

--ALTER TABLE dbo.FactInternetSalesBig
--DROP COLUMN NewColumn;
--GO

--------------------
--DML - UPDATE
--------------------

EXEC sp_spaceused 'dbo.FactInternetSalesBig';
GO

UPDATE dbo.FactInternetSalesBig
SET NewColumn = 1;
GO

--************* RUN EXCEL :-) *******************************

SELECT COUNT(*) FROM dbo.FactInternetSalesBig;
GO

SELECT * FROM sys.partitions WHERE object_id = OBJECT_ID('dbo.FactInternetSalesBig');
GO

ALTER INDEX CCI_FactInternetSalesBig 
ON dbo.FactInternetSalesBig 
REORGANIZE WITH (COMPRESS_ALL_ROW_GROUPS = ON);
GO

--ALTER INDEX CCI_FactInternetSalesBig 
--ON dbo.FactInternetSalesBig 
--REBUILD;
--GO

--------------------
--DML - DELETE
--------------------

INSERT INTO dbo.FactInternetSalesBig (
  SalesOrderNumber,
  SalesOrderLineNumber,
  ProductKey, 
  OrderDateKey, 
  CustomerKey, 
  PromotionKey, 
  CurrencyKey, 
  SalesTerritoryKey, 
  OrderQuantity, 
  UnitPrice, 
  SalesAmount, 
  TaxAmt, 
  Freight
)
SELECT TOP 50000
  'SO' + RIGHT('00000000' + CONVERT(varchar(12), DENSE_RANK() OVER (ORDER BY SalesOrderNumber)+(SELECT MAX(CONVERT(int, RIGHT(SalesOrderNumber, 12))) FROM dbo.FactInternetSalesBig)), 12),
  ROW_NUMBER() OVER (PARTITION BY SalesOrderNumber ORDER BY SalesOrderLineNumber), 
  ProductKey, OrderDateKey, CustomerKey, PromotionKey, CurrencyKey, SalesTerritoryKey, OrderQuantity, UnitPrice, SalesAmount, TaxAmt, Freight
FROM AdventureWorksDW2012.dbo.FactInternetSales
ORDER BY NEWID();

DELETE FROM dbo.FactInternetSalesBig
WHERE OrderDateKey % 2 = 1;
GO

------------------------------
--Compression
------------------------------

IF OBJECT_ID('dbo.FactInternetSalesCompressed', 'U') IS NOT NULL
  DROP TABLE dbo.FactInternetSalesCompressed;
GO
SELECT
  SalesOrderNumber,
  SalesOrderLineNumber,
  ProductKey, 
  OrderDateKey, 
  CustomerKey, 
  PromotionKey, 
  CurrencyKey, 
  SalesTerritoryKey, 
  OrderQuantity, 
  UnitPrice, 
  SalesAmount, 
  TaxAmt, 
  Freight
INTO dbo.FactInternetSalesCompressed
FROM AdventureWorksDW2012.dbo.FactInternetSales;
GO

ALTER TABLE dbo.FactInternetSalesCompressed
ADD CONSTRAINT PK_FactInternetSalesCompressed_SalesOrderNumber_SalesOrderLineNumber
PRIMARY KEY CLUSTERED (SalesOrderNumber, SalesOrderLineNumber);
GO

SELECT * FROM sys.partitions WHERE object_id = OBJECT_ID('dbo.FactInternetSalesCompressed');
GO

EXEC sp_spaceused 'dbo.FactInternetSalesCompressed';
GO

ALTER TABLE dbo.FactInternetSalesCompressed 
REBUILD WITH (DATA_COMPRESSION = PAGE);
GO

SELECT * FROM sys.partitions WHERE object_id = OBJECT_ID('dbo.FactInternetSalesCompressed');
GO

EXEC sp_spaceused 'dbo.FactInternetSalesCompressed';
GO

ALTER TABLE dbo.FactInternetSalesCompressed 
REBUILD WITH (DATA_COMPRESSION = NONE);
GO

ALTER TABLE dbo.FactInternetSalesCompressed
DROP CONSTRAINT PK_FactInternetSalesCompressed_SalesOrderNumber_SalesOrderLineNumber;
GO

CREATE CLUSTERED COLUMNSTORE INDEX 
  IX_CCI_FactInternetSalesCompressed
ON dbo.FactInternetSalesCompressed;
GO

EXEC sp_spaceused 'dbo.FactInternetSalesCompressed';
GO

--CCI size
SELECT SUM(s.used_page_count) / 128.0 on_disk_size_MB 
FROM sys.indexes AS i 
JOIN sys.dm_db_partition_stats AS s
ON i.object_id = s.object_id 
AND i.index_id = s.index_id 
WHERE i.object_id = object_id('dbo.FactInternetSalesCompressed') 
AND i.type_desc = 'CLUSTERED COLUMNSTORE';
GO

SELECT * FROM sys.partitions WHERE object_id = OBJECT_ID('dbo.FactInternetSalesCompressed');
GO

ALTER TABLE dbo.FactInternetSalesCompressed 
REBUILD WITH (DATA_COMPRESSION = COLUMNSTORE_ARCHIVE);
GO

----------------
--Queries
----------------

USE AdventureWorksDW2012;
GO

--IF OBJECT_ID('dbo.FactInternetSalesBig', 'U') IS NOT NULL
--  DROP TABLE dbo.FactInternetSalesBig;
--GO

----Bigger fact table
--SELECT TOP 0 
--  SalesOrderNumber,
--  SalesOrderLineNumber,
--  ProductKey, 
--  OrderDateKey, 
--  CustomerKey, 
--  PromotionKey, 
--  CurrencyKey, 
--  SalesTerritoryKey, 
--  OrderQuantity, 
--  UnitPrice, 
--  SalesAmount, 
--  TaxAmt, 
--  Freight
--INTO dbo.FactInternetSalesBig
--FROM dbo.FactInternetSales;
--GO

----First portion
--INSERT INTO dbo.FactInternetSalesBig (
--  SalesOrderNumber,
--  SalesOrderLineNumber,
--  ProductKey, 
--  OrderDateKey, 
--  CustomerKey, 
--  PromotionKey, 
--  CurrencyKey, 
--  SalesTerritoryKey, 
--  OrderQuantity, 
--  UnitPrice, 
--  SalesAmount, 
--  TaxAmt, 
--  Freight
--)
--SELECT 
--  'SO' + RIGHT('000000000000' + CONVERT(varchar(12), DENSE_RANK() OVER (ORDER BY SalesOrderNumber)+43430), 12) AS SalesOrderNumber,
--  SalesOrderLineNumber, ProductKey, OrderDateKey, CustomerKey, PromotionKey, CurrencyKey, SalesTerritoryKey, OrderQuantity, UnitPrice, SalesAmount, TaxAmt, Freight
--FROM dbo.FactInternetSales;
--GO

----More data
--INSERT INTO dbo.FactInternetSalesBig (
--  SalesOrderNumber,
--  SalesOrderLineNumber,
--  ProductKey, 
--  OrderDateKey, 
--  CustomerKey, 
--  PromotionKey, 
--  CurrencyKey, 
--  SalesTerritoryKey, 
--  OrderQuantity, 
--  UnitPrice, 
--  SalesAmount, 
--  TaxAmt, 
--  Freight
--)
--SELECT TOP 50000
--  'SO' + RIGHT('00000000' + CONVERT(varchar(12), DENSE_RANK() OVER (ORDER BY SalesOrderNumber)+(SELECT MAX(CONVERT(int, RIGHT(SalesOrderNumber, 12))) FROM dbo.FactInternetSalesBig)), 12),
--  ROW_NUMBER() OVER (PARTITION BY SalesOrderNumber ORDER BY SalesOrderLineNumber), 
--  ProductKey, OrderDateKey, CustomerKey, PromotionKey, CurrencyKey, SalesTerritoryKey, OrderQuantity, UnitPrice, SalesAmount, TaxAmt, Freight
--FROM dbo.FactInternetSales
--ORDER BY NEWID();
--CHECKPOINT;
--GO 10

--SELECT COUNT(*) FROM dbo.FactInternetSalesBig;
--GO

--CREATE CLUSTERED COLUMNSTORE INDEX IX_CCI_FactInternetSalesBig ON dbo.FactInternetSalesBig;
--GO

--Actuals
IF OBJECT_ID('dbo.FactInternetSalesActuals', 'U') IS NOT NULL
  DROP TABLE dbo.FactInternetSalesActuals;
GO 

SELECT TOP 0 
  SalesOrderNumber,
  SalesOrderLineNumber,
  ProductKey, 
  OrderDateKey, 
  CustomerKey, 
  PromotionKey, 
  CurrencyKey, 
  SalesTerritoryKey, 
  OrderQuantity, 
  UnitPrice, 
  SalesAmount, 
  TaxAmt, 
  Freight
INTO dbo.FactInternetSalesActuals
FROM dbo.FactInternetSales;
GO

ALTER TABLE dbo.FactInternetSalesActuals
ADD CONSTRAINT PK_FactInternetSalesActuals_SalesOrderNumber_SalesOrderLineNumber
PRIMARY KEY CLUSTERED (OrderDateKey, SalesOrderNumber, SalesOrderLineNumber);
GO

--Load data
INSERT INTO dbo.FactInternetSalesActuals (
  SalesOrderNumber,
  SalesOrderLineNumber,
  ProductKey, 
  OrderDateKey, 
  CustomerKey, 
  PromotionKey, 
  CurrencyKey, 
  SalesTerritoryKey, 
  OrderQuantity, 
  UnitPrice, 
  SalesAmount, 
  TaxAmt, 
  Freight
)
SELECT TOP 1000 
  'SO' + RIGHT('00000000' + CONVERT(varchar(6), DENSE_RANK() OVER (ORDER BY SalesOrderNumber) + (SELECT MAX(CONVERT(int, RIGHT(SalesOrderNumber, 5))) FROM dbo.FactInternetSales)), 5) AS SalesOrderNumber,
  ROW_NUMBER() OVER (PARTITION BY SalesOrderNumber ORDER BY SalesOrderLineNumber) AS SalesOrderLineNumber, 
  ProductKey, 
  20081001 AS OrderDateKey, 
  CustomerKey, 
  PromotionKey, 
  CurrencyKey, 
  SalesTerritoryKey, 
  OrderQuantity, 
  UnitPrice, 
  SalesAmount, 
  TaxAmt, 
  Freight
FROM dbo.FactInternetSales;
GO

--Queries

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

--2012: OK
SELECT 
  D.CalendarYear,
  D.MonthNumberOfYear,
  P.ProductKey, 
  P.EnglishProductName, 
  COUNT(*) AS OrderCount,
  SUM(F.OrderQuantity) AS Quantity,
  SUM(F.SalesAmount) AS SalesAmount
FROM dbo.DimProduct AS P
INNER JOIN dbo.FactInternetSalesBig AS F
ON P.ProductKey = F.ProductKey
INNER JOIN dbo.DimDate AS D
ON F.OrderDateKey = D.DateKey
GROUP BY GROUPING SETS (
  (P.ProductKey, P.EnglishProductName, D.CalendarYear, D.MonthNumberOfYear), 
  (P.ProductKey, P.EnglishProductName, D.CalendarYear)
)
ORDER BY D.CalendarYear, D.MonthNumberOfYear, P.EnglishProductName;
GO

--2012: Row Mode
SELECT 
  D.CalendarYear,
  D.MonthNumberOfYear,
  P.ProductKey, 
  P.EnglishProductName, 
  COUNT(*) AS OrderCount,
  SUM(F.OrderQuantity) AS Quantity,
  SUM(F.SalesAmount) AS SalesAmount
FROM dbo.DimProduct AS P
LEFT JOIN dbo.FactInternetSalesBig AS F
ON P.ProductKey = F.ProductKey
LEFT JOIN dbo.DimDate AS D
ON F.OrderDateKey = D.DateKey
GROUP BY P.ProductKey, P.EnglishProductName, D.CalendarYear, D.MonthNumberOfYear
ORDER BY D.CalendarYear, D.MonthNumberOfYear, P.EnglishProductName;
GO

--2012: OK
WITH CTE AS (
  SELECT 
    D.CalendarYear,
    D.MonthNumberOfYear,
    P.ProductKey, 
    P.EnglishProductName, 
    COUNT(*) AS OrderCount,
    SUM(F.OrderQuantity) AS Quantity,
    SUM(F.SalesAmount) AS SalesAmount
  FROM dbo.DimProduct AS P
  INNER JOIN dbo.FactInternetSalesBig AS F
  ON P.ProductKey = F.ProductKey
  INNER JOIN dbo.DimDate AS D
  ON F.OrderDateKey = D.DateKey
  GROUP BY P.ProductKey, P.EnglishProductName, D.CalendarYear, D.MonthNumberOfYear
)
SELECT
  C.CalendarYear,
  C.MonthNumberOfYear,
  P1.ProductKey, 
  P1.EnglishProductName, 
  ISNULL(C.OrderCount, 0) AS OrderCount,
  ISNULL(C.Quantity, 0) AS Quantity,
  ISNULL(C.SalesAmount, 0) AS SalesAmount
FROM dbo.DimProduct AS P1
LEFT JOIN CTE AS C
ON P1.ProductKey = C.ProductKey
ORDER BY C.CalendarYear, C.MonthNumberOfYear, P1.EnglishProductName;
GO

--2012: OK
SELECT 
  P.ProductKey, 
  P.EnglishProductName, 
  COUNT(*) AS OrderCount,
  SUM(F.OrderQuantity) AS Quantity
FROM dbo.DimProduct AS P
LEFT JOIN dbo.FactInternetSalesBig AS F
ON P.ProductKey = F.ProductKey
GROUP BY P.ProductKey, P.EnglishProductName
ORDER BY COUNT(*) DESC, Quantity DESC;
GO

--2012: Row Mode
SELECT 
  D.CalendarYear,
  D.MonthNumberOfYear,
  P.ProductKey, 
  P.EnglishProductName, 
  COUNT(*) AS OrderCount,
  SUM(F.OrderQuantity) AS Quantity,
  SUM(F.SalesAmount) AS SalesAmount
FROM (
  SELECT *
  FROM dbo.FactInternetSalesBig
  UNION ALL
  SELECT *
  FROM dbo.FactInternetSalesActuals
) AS F
INNER JOIN dbo.DimProduct AS P
ON P.ProductKey = F.ProductKey
INNER JOIN dbo.DimDate AS D
ON F.OrderDateKey = D.DateKey
GROUP BY 
  P.ProductKey, P.EnglishProductName, 
  D.CalendarYear, D.MonthNumberOfYear
ORDER BY D.CalendarYear, D.MonthNumberOfYear, P.EnglishProductName;
GO

--2012: OK
WITH CTE AS (
  SELECT
    D.CalendarYear,
    D.MonthNumberOfYear,
    P.ProductKey, 
    P.EnglishProductName, 
    COUNT(*) AS OrderCount,
    SUM(F.OrderQuantity) AS Quantity,
    SUM(F.SalesAmount) AS SalesAmount
  FROM dbo.FactInternetSalesBig AS F
  INNER JOIN dbo.DimProduct AS P
  ON P.ProductKey = F.ProductKey
  INNER JOIN dbo.DimDate AS D
  ON F.OrderDateKey = D.DateKey
  GROUP BY 
    P.ProductKey, P.EnglishProductName, 
    D.CalendarYear, D.MonthNumberOfYear 
), CTE1 AS (
    SELECT
    D.CalendarYear,
    D.MonthNumberOfYear,
    P.ProductKey, 
    P.EnglishProductName, 
    COUNT(*) AS OrderCount,
    SUM(F.OrderQuantity) AS Quantity,
    SUM(F.SalesAmount) AS SalesAmount
  FROM dbo.FactInternetSalesActuals AS F
  INNER JOIN dbo.DimProduct AS P
  ON P.ProductKey = F.ProductKey
  INNER JOIN dbo.DimDate AS D
  ON F.OrderDateKey = D.DateKey
  GROUP BY 
    P.ProductKey, P.EnglishProductName, 
    D.CalendarYear, D.MonthNumberOfYear 
), CTE2 AS (
  SELECT *
  FROM CTE
  UNION ALL
  SELECT *
  FROM CTE1
)
SELECT 
  CalendarYear,
  MonthNumberOfYear,
  ProductKey, 
  EnglishProductName, 
  SUM(OrderCount) AS OrderCount,
  SUM(Quantity) AS Quantity,
  SUM(SalesAmount) AS SalesAmount
FROM CTE2
GROUP BY 
  ProductKey, EnglishProductName, 
  CalendarYear, MonthNumberOfYear
ORDER BY CalendarYear, MonthNumberOfYear, EnglishProductName;
GO

--2012: OK
SELECT 
  D.CalendarYear,
  D.MonthNumberOfYear,
  COUNT(*) AS OrderCount,
  SUM(F.OrderQuantity) AS Quantity,
  SUM(F.SalesAmount) AS SalesAmount
FROM (
  SELECT *
  FROM dbo.FactInternetSalesBig
  UNION ALL
  SELECT *
  FROM dbo.FactInternetSalesActuals
) AS F
INNER JOIN dbo.DimDate AS D
ON F.OrderDateKey = D.DateKey
GROUP BY D.CalendarYear, D.MonthNumberOfYear
ORDER BY D.CalendarYear, D.MonthNumberOfYear;
GO

--No grouping?
SELECT
  OrderDateKey, 
  ProductKey, 
  OrderQuantity, 
  SalesAmount
FROM dbo.FactInternetSalesBig
WHERE SalesOrderNumber = 'SO000005255345';
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO