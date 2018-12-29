--Setup
USE [master]
GO
RESTORE DATABASE [AdventureWorks2012] 
FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQL2014\MSSQL\Backup\AW.bak' 
WITH  FILE = 1, NOUNLOAD, REPLACE, STATS = 5;
GO

-------------------------------
--Stats - basics
-------------------------------

USE AdventureWorks2012;
GO

SELECT 
  QUOTENAME(OBJECT_SCHEMA_NAME(o.object_id)) + ' ' + 
  QUOTENAME(o.name) AS object, 
  s.* 
FROM sys.stats AS s
INNER JOIN sys.objects AS o
ON s.object_id = o.object_id
WHERE o.is_ms_shipped = 0
ORDER BY object, stats_id;
GO

--_WA_Sys_00000003_59063A47

DBCC SHOW_STATISTICS ('HumanResources.Department', 'AK_Department_Name');
GO

DBCC SHOW_STATISTICS ('Sales.SalesOrderHeader', 'IX_SalesOrderHeader_CustomerID');
GO

-------------------------------------
--Histogram and some numbers
-------------------------------------

DBCC SHOW_STATISTICS ('Sales.SalesOrderDetail', 'IX_SalesOrderDetail_ProductID')
 WITH HISTOGRAM;
GO

SELECT SalesOrderID FROM Sales.SalesOrderDetail WHERE ProductID = 707 OPTION (RECOMPILE);
SELECT SalesOrderID FROM Sales.SalesOrderDetail WHERE ProductID = 717 OPTION (RECOMPILE);
SELECT SalesOrderID FROM Sales.SalesOrderDetail WHERE ProductID = 816 OPTION (RECOMPILE);
SELECT SalesOrderID FROM Sales.SalesOrderDetail WHERE ProductID = 817 OPTION (RECOMPILE);
GO

DECLARE @i int = 707;
SELECT SalesOrderID FROM Sales.SalesOrderDetail WHERE ProductID = @i;
GO

-------------------------------
--Numbers matter a lot
-------------------------------

IF OBJECT_ID('dbo.Product') IS NOT NULL
  DROP TABLE dbo.Product;
GO

SELECT *
INTO dbo.Product
FROM Production.Product;
GO

ALTER TABLE dbo.Product
ADD CONSTRAINT PK_Product
PRIMARY KEY (ProductID);
GO

CREATE INDEX IX_Product_ProductSubcategoryID
ON dbo.Product (ProductSubcategoryID);
GO

SELECT P.Name, S.Name FROM dbo.Product AS P 
INNER LOOP JOIN Production.ProductSubcategory AS S
ON P.ProductSubcategoryID = S.ProductSubcategoryID
WHERE P.ProductSubcategoryID = 1;
GO

SELECT name FROM sys.stats WHERE object_id = OBJECT_ID('dbo.Product');
GO

DBCC SHOW_STATISTICS ('dbo.Product', 'IX_Product_ProductSubcategoryID');
GO

--!!!!!!!!!!!!!!!!!!!!!!!! DON'T DO THAT IN PRODUCTION !!!!!!!!!!!!!!!!!!!!!!!!

UPDATE STATISTICS dbo.Product WITH ROWCOUNT = 1000000, PAGECOUNT = 100000;
GO 

--!!!!!!!!!!!!!!!!!!!!!!!! DON'T DO THAT IN PRODUCTION !!!!!!!!!!!!!!!!!!!!!!!!

DBCC SHOW_STATISTICS ('dbo.Product', 'IX_Product_ProductSubcategoryID');
GO

SELECT COUNT(*) FROM dbo.Product;
GO

SELECT * FROM sys.partitions WHERE object_id = OBJECT_ID('dbo.Product');
GO

DBCC FREEPROCCACHE;
GO

SELECT P.Name, S.Name FROM dbo.Product AS P 
INNER LOOP JOIN Production.ProductSubcategory AS S
ON P.ProductSubcategoryID = S.ProductSubcategoryID
WHERE P.ProductSubcategoryID = 1;
GO

--Math
SELECT 32. * (100000 / 504.)
GO

----------------------------------------
--SQL Server 2014 - new CE & trace flags
----------------------------------------

--Check for stats
SELECT  
  s.object_id,
  s.stats_id,
  s.name,
  s.auto_created,
  COL_NAME(s.object_id, sc.column_id) AS col_name
FROM sys.stats AS s
INNER JOIN sys.stats_columns AS sc
ON s.stats_id = sc.stats_id AND s.object_id = sc.object_id
WHERE   s.object_id = OBJECT_ID('Sales.SalesOrderHeader')
ORDER BY s.stats_id, sc.stats_column_id;
GO

DBCC SHOW_STATISTICS ('Sales.SalesOrderHeader', 'PK_SalesOrderHeader_SalesOrderID');
GO

DBCC SHOW_STATISTICS ('Sales.SalesOrderHeader', '_WA_Sys_00000003_4B7734FF');
GO

--Check compatibility level
SELECT compatibility_level
FROM sys.databases
WHERE name = 'AdventureWorks2012';
GO

DBCC FREEPROCCACHE;
GO

----------------------
--Corelated predicates
----------------------

--<<<<<<<<<<<<<<<<<<<<
--SQL 2012
-->>>>>>>>>>>>>>>>>>>>

--
SELECT * FROM Sales.SalesOrderHeader
WHERE SalesOrderID >= 74000 AND SalesOrderID <= 75000 
OPTION (RECOMPILE, QUERYTRACEON 9481);
GO 

--
SELECT * FROM Sales.SalesOrderHeader 
WHERE OrderDate >= '20080626' AND OrderDate <= '20080724'
OPTION (RECOMPILE, QUERYTRACEON 9481);
GO

--
SELECT * FROM Sales.SalesOrderHeader
WHERE SalesOrderID >= 74000 AND SalesOrderID <= 75000 
AND OrderDate >= '20080626' AND OrderDate <= '20080724'
OPTION (RECOMPILE, QUERYTRACEON 9481);
GO

--
SELECT COUNT(*) FROM Sales.SalesOrderHeader;
GO

--SQL 2012: Sel1 * Sel2 * ... * SelN * NumOfRows
SELECT 1;
GO

--<<<<<<<<<<<<<<<<<<<<
--SQL 2014
-->>>>>>>>>>>>>>>>>>>>

--
SELECT * FROM Sales.SalesOrderHeader
WHERE SalesOrderID >= 74000 AND SalesOrderID <= 75000 
OPTION (RECOMPILE, QUERYTRACEON 2312);
GO 

--
SELECT * FROM Sales.SalesOrderHeader 
WHERE OrderDate >= '20080626' AND OrderDate <= '20080724'
OPTION (RECOMPILE, QUERYTRACEON 2312);
GO

--
SELECT * FROM Sales.SalesOrderHeader
WHERE SalesOrderID >= 74000 AND SalesOrderID <= 75000 
AND OrderDate >= '20080626' AND OrderDate <= '20080724'
OPTION (RECOMPILE, QUERYTRACEON 2312);
GO

--SQL 2014: Sel1 * (Sel2)^-2 * (Sel3)^-4 * ... * (SelN)^(2^N-1) * NumOfRows
SELECT 1;
GO

----------------------------------
--Use XE to check how CE works
----------------------------------

EXEC xp_cmdshell 'del C:\Temp\CESession*';
GO

IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'CESession')
  DROP EVENT SESSION CESession ON SERVER;
GO

CREATE EVENT SESSION CESession ON SERVER 
ADD EVENT sqlserver.query_optimizer_estimate_cardinality (
  ACTION (sqlserver.sql_text)
)
ADD TARGET package0.event_file (
  SET filename=N'C:\Temp\CESession.xel', metadatafile = 'C:\Temp\CESession.xem'
);
GO

ALTER EVENT SESSION CESession ON SERVER STATE = START;
GO

SELECT * FROM Sales.SalesOrderHeader
WHERE SalesOrderID >= 74000 AND SalesOrderID <= 75000 
AND OrderDate >= '20080626' AND OrderDate <= '20080724'
OPTION (RECOMPILE, QUERYTRACEON 2312);
GO

ALTER EVENT SESSION CESession ON SERVER STATE = STOP;
GO

!!for /f %F in ('dir C:\Temp\CESession*.xel /b') do ssms "C:\Temp\%F"

--------------------------------------
--Ascending key and out-of-range value
--------------------------------------

--Setup
INSERT INTO Sales.SalesOrderHeader (
  RevisionNumber, OrderDate, DueDate, ShipDate, Status,
  OnlineOrderFlag, PurchaseOrderNumber, AccountNumber, CustomerID,
  SalesPersonID, TerritoryID, BillToAddressID, ShipToAddressID,
  ShipMethodID, CreditCardID, CreditCardApprovalCode,
  CurrencyRateID, SubTotal, TaxAmt, Freight, Comment 
)
VALUES (
  3, '2014-02-02 00:00:00.000', '5/1/2014', '4/1/2014', 5, 
  0, 'SO43659', 'PO522145787', 29825, 279, 5, 
  985, 985, 5, 21, 'Vi84182', 
  NULL, 250.00, 25.00, 10.00, '' 
);
GO 50

--Check for stats
SELECT  
  s.object_id,
  s.name,
  s.auto_created,
  COL_NAME(s.object_id, sc.column_id) AS col_name
FROM sys.stats AS s
INNER JOIN sys.stats_columns AS sc
ON s.stats_id = sc.stats_id AND s.object_id = sc.object_id
WHERE s.object_id = OBJECT_ID('Sales.SalesOrderHeader')
AND COL_NAME(s.object_id, sc.column_id) = 'OrderDate'
ORDER BY s.stats_id, sc.stats_column_id;
GO

DBCC SHOW_STATISTICS ('Sales.SalesOrderHeader', '_WA_Sys_00000003_4B7734FF');
GO

--<<<<<<<<<<<<<<<<<<<<
--SQL 2012
-->>>>>>>>>>>>>>>>>>>>

SELECT SalesOrderID, OrderDate 
FROM Sales.SalesOrderHeader
WHERE OrderDate = '2014-02-02 00:00:00.000'
OPTION (QUERYTRACEON 9481);  
GO

--<<<<<<<<<<<<<<<<<<<<
--SQL 2014
-->>>>>>>>>>>>>>>>>>>>

SELECT SalesOrderID, OrderDate 
FROM Sales.SalesOrderHeader
WHERE OrderDate = '2014-02-02 00:00:00.000'
OPTION (QUERYTRACEON 2312);  
GO

--History: trace flags 2389 + 2390 (http://blogs.msdn.com/b/ianjo/archive/2006/04/24/582227.aspx)

-------------------------------------
--Join Estimate Algorithm
-------------------------------------

USE AdventureWorksDW2012;
GO

--Real number of rows: 70470090

SELECT  
  fs.ProductKey, 
  fs.OrderDateKey, 
  fs.DueDateKey, 
	fs.ShipDateKey, 
  fc.DateKey,
  fc.AverageRate, 
  fc.EndOfDayRate, 
  fc.Date
FROM dbo.FactResellerSales AS fs
INNER JOIN dbo.FactCurrencyRate AS fc 
ON fs.CurrencyKey = fc.CurrencyKey
OPTION (QUERYTRACEON 9481);
GO

SELECT  
  fs.ProductKey, 
  fs.OrderDateKey, 
  fs.DueDateKey, 
	fs.ShipDateKey, 
  fc.DateKey,
  fc.AverageRate, 
  fc.EndOfDayRate, 
  fc.Date
FROM dbo.FactResellerSales AS fs
INNER JOIN dbo.FactCurrencyRate AS fc 
ON fs.CurrencyKey = fc.CurrencyKey
OPTION (QUERYTRACEON 2312);
GO

DBCC SHOW_STATISTICS ('dbo.FactResellerSales', 'IX_FactResellerSales_CurrencyKey');
GO

-------------------------------------
--Equijoin with 2 or more predicates
-------------------------------------

USE AdventureWorksDW2012;
GO

--Setup
ALTER TABLE dbo.FactProductInventory
DROP CONSTRAINT PK_FactProductInventory;
GO

SELECT  
  fs.OrderDateKey, 
  fs.DueDateKey, 
  fs.ShipDateKey,     
  fi.UnitsIn, 
  fi.UnitsOut, 
  fi.UnitsBalance
FROM dbo.FactInternetSales AS fs
INNER JOIN dbo.FactProductInventory AS fi
ON fs.ProductKey = fi.ProductKey AND fs.OrderDateKey = fi.DateKey
OPTION (QUERYTRACEON 9481);
GO

SELECT  
  fs.OrderDateKey, 
  fs.DueDateKey, 
  fs.ShipDateKey,     
  fi.UnitsIn, 
  fi.UnitsOut, 
  fi.UnitsBalance
FROM dbo.FactInternetSales AS fs
INNER JOIN dbo.FactProductInventory AS fi
ON fs.ProductKey = fi.ProductKey AND fs.OrderDateKey = fi.DateKey
OPTION (QUERYTRACEON 2312);
GO

--Fix
ALTER TABLE dbo.FactProductInventory 
ADD  CONSTRAINT PK_FactProductInventory
PRIMARY KEY CLUSTERED 
(
  ProductKey ASC,
  DateKey ASC
);
GO

----------------------------
--Join Containment
----------------------------

USE AdventureWorks2012;
GO

SELECT 
  od.SalesOrderID, 
  od.SalesOrderDetailID
FROM Sales.SalesOrderDetail AS od
INNER JOIN Production.Product AS p
ON od.ProductID = p.ProductID
WHERE p.Color = 'Red' AND od.ModifiedDate = '20080629'
OPTION (QUERYTRACEON 9481); 
GO

SELECT 
  od.SalesOrderID, 
  od.SalesOrderDetailID
FROM Sales.SalesOrderDetail AS od
INNER JOIN Production.Product AS p
ON od.ProductID = p.ProductID
WHERE p.Color = 'Red' AND od.ModifiedDate = '20080629'
OPTION (QUERYTRACEON 2312); 
GO

---------------------------------
--Distinct Value Count Estimation
---------------------------------

USE AdventureWorksDW2012;
GO

SELECT 
  f.ProductKey, 
  d.DayNumberOfYear
FROM dbo.FactInternetSales AS f
INNER JOIN dbo.DimDate AS d 
ON f.OrderDateKey = d.DateKey
INNER JOIN dbo.FactProductInventory AS fi
ON  fi.DateKey = d.DateKey
WHERE f.SalesTerritoryKey = 8
GROUP BY f.ProductKey, d.DayNumberOfYear
OPTION (QUERYTRACEON 9481); 
GO

SELECT 
  f.ProductKey, 
  d.DayNumberOfYear
FROM dbo.FactInternetSales AS f
INNER JOIN dbo.DimDate AS d 
ON f.OrderDateKey = d.DateKey
INNER JOIN dbo.FactProductInventory AS fi
ON  fi.DateKey = d.DateKey
WHERE f.SalesTerritoryKey = 8
GROUP BY f.ProductKey, d.DayNumberOfYear
OPTION (QUERYTRACEON 2312); 
GO

----------------------------------------
--Multi-statement table-valued functions
----------------------------------------

USE tempdb;
GO

IF OBJECT_ID('fn_foo') IS NOT NULL
  DROP FUNCTION fn_foo;
GO

CREATE FUNCTION fn_foo()
RETURNS @t TABLE(a int)
AS
BEGIN
INSERT INTO @t VALUES (1),(2)
RETURN;
END
GO

--SQL Server 2012
SELECT * FROM fn_foo() OPTION (QUERYTRACEON 9481);
GO

--SQL Server 2014
SELECT * FROM fn_foo() OPTION (QUERYTRACEON 2312); 
GO

------------------------
--Incremental Statistics
------------------------

--Setup
USE master;
GO

IF DB_ID('DemoDB') IS NOT NULL
BEGIN
  ALTER DATABASE DemoDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE DemoDB;
END;
GO

CREATE DATABASE DemoDB;
GO

USE DemoDB;
GO

IF OBJECT_ID('dbo.FactInternetSales', 'U') IS NOT NULL
  DROP TABLE dbo.FactInternetSales;
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
INTO dbo.FactInternetSales
FROM AdventureWorksDW2012.dbo.FactInternetSales;
GO

SELECT COUNT(*) FROM dbo.FactInternetSales;
GO

IF EXISTS (SELECT * FROM sys.partition_schemes WHERE name = 'PS_FactInternetSales_OrderDateKey')
  DROP PARTITION SCHEME PS_FactInternetSales_OrderDateKey;
GO

IF EXISTS (SELECT * FROM sys.partition_functions WHERE name = 'PF_FactInternetSales_OrderDateKey')
  DROP PARTITION FUNCTION PF_FactInternetSales_OrderDateKey;
GO

CREATE PARTITION FUNCTION PF_FactInternetSales_OrderDateKey (int)
AS RANGE RIGHT FOR VALUES (
  20051001, 20060101, 20060401, 20060701, 20061001,
  20070101, 20070401, 20070701, 20071001,
  20080101, 20080401, 20080701
);
GO

CREATE PARTITION SCHEME PS_FactInternetSales_OrderDateKey
AS 
PARTITION PF_FactInternetSales_OrderDateKey
ALL TO ([PRIMARY]);
GO

ALTER TABLE dbo.FactInternetSales
ADD CONSTRAINT PK_FactInternetSales
PRIMARY KEY CLUSTERED (OrderDateKey, SalesOrderNumber, SalesOrderLineNumber)
ON PS_FactInternetSales_OrderDateKey(OrderDateKey);
GO

--See data distribution
WITH CTE_P AS (
  SELECT *
  FROM sys.partitions
  WHERE object_id = OBJECT_ID('dbo.FactInternetSales')
), CTE_T AS (
  SELECT 
    $partition.PF_FactInternetSales_OrderDateKey(OrderDateKey) AS partition, 
    MIN(OrderDateKey) AS min_value,
    MAX(OrderDateKey) AS max_value,
    COUNT(*) AS row_count,
    100. * COUNT(*) / (SELECT COUNT(*) FROM dbo.FactInternetSales) AS pct
  FROM dbo.FactInternetSales
  GROUP BY $partition.PF_FactInternetSales_OrderDateKey(OrderDateKey)
)
SELECT 
  CTE_P.partition_number, 
  CTE_P.rows,
  CTE_T.min_value,
  CTE_T.max_value,
  CTE_T.pct
FROM CTE_P 
LEFT JOIN CTE_T
ON CTE_P.partition_number = CTE_T.partition
ORDER BY 1
GO

--Check for stats
SELECT  
  s.object_id,
  s.name,
  s.auto_created,
  COL_NAME(s.object_id, sc.column_id) AS col_name,
  s.is_incremental
FROM sys.stats AS s
INNER JOIN sys.stats_columns AS sc
ON s.stats_id = sc.stats_id AND s.object_id = sc.object_id
WHERE s.object_id = OBJECT_ID('dbo.FactInternetSales')
ORDER BY s.stats_id, sc.stats_column_id;
GO

--Create incremental stats
CREATE STATISTICS STATS_FactInternetSales_ProductKey
ON dbo.FactInternetSales (ProductKey) 
WITH INCREMENTAL = ON
GO

--Check for stats again
SELECT  
  s.object_id,
  s.name,
  s.auto_created,
  COL_NAME(s.object_id, sc.column_id) AS col_name,
  s.is_incremental
FROM sys.stats AS s
INNER JOIN sys.stats_columns AS sc
ON s.stats_id = sc.stats_id AND s.object_id = sc.object_id
WHERE s.object_id = OBJECT_ID('dbo.FactInternetSales')
ORDER BY s.stats_id, sc.stats_column_id;
GO

DBCC SHOW_STATISTICS ('dbo.FactInternetSales', 'STATS_FactInternetSales_ProductKey');
GO

SELECT ProductKey, COUNT(*) AS cnt
FROM dbo.FactInternetSales
GROUP BY ProductKey
ORDER BY 2 DESC;
GO

SELECT $partition.PF_FactInternetSales_OrderDateKey(OrderDateKey), ProductKey, COUNT(*) AS cnt
FROM dbo.FactInternetSales
GROUP BY $partition.PF_FactInternetSales_OrderDateKey(OrderDateKey), ProductKey
ORDER BY 3 DESC;
GO

UPDATE dbo.FactInternetSales
SET ProductKey = 324
WHERE OrderDateKey BETWEEN 20080401	AND 20080630
AND ProductKey = 477;
GO

--Check stats
DBCC SHOW_STATISTICS ('dbo.FactInternetSales', 'STATS_FactInternetSales_ProductKey');
GO

--Update stats on partition 12
UPDATE STATISTICS dbo.FactInternetSales (STATS_FactInternetSales_ProductKey)
WITH RESAMPLE ON PARTITIONS (12);
GO

--Check stats again
DBCC SHOW_STATISTICS ('dbo.FactInternetSales', 'STATS_FactInternetSales_ProductKey');
GO

--Enable auto create incremental stats
ALTER DATABASE DemoDB
SET AUTO_CREATE_STATISTICS ON (INCREMENTAL = ON);
GO

SELECT name, is_auto_create_stats_incremental_on 
FROM sys.databases WHERE database_id = DB_ID();
GO

