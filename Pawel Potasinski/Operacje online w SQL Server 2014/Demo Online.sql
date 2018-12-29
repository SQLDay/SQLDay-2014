----------------------------------
--Demo 1a: Online rebuild and locks
----------------------------------

--EXEC sp_configure 'show adv', 1;
--RECONFIGURE;
--GO

--EXEC sp_configure 'xp_cmdshell', 1;
--RECONFIGURE;
--GO

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
USE DemoDB;
GO

ALTER DATABASE DemoDB SET RECOVERY SIMPLE; 
GO

CREATE TABLE dbo.Product (
  ProductID int IDENTITY(1,1) NOT NULL,
  ProductName varchar(50) NOT NULL,
  ProductPrice money NOT NULL,
  CONSTRAINT PK_Product
  PRIMARY KEY (ProductID)
);
GO

INSERT INTO dbo.Product (ProductName, ProductPrice)
SELECT name, column_id
FROM sys.all_columns;
GO

--Use XE to captue locks

--************* CHANGE SPID!!! *************************

EXEC xp_cmdshell 'del "C:\Temp\TrackLocksSession*.xel"';
GO

IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'TrackLocksSession')
  DROP EVENT SESSION TrackLocksSession ON SERVER;
GO

CREATE EVENT SESSION TrackLocksSession ON SERVER 
ADD EVENT sqlserver.lock_acquired (
  WHERE (sqlserver.session_id = 52)
),
ADD EVENT sqlserver.lock_released (
  ACTION (sqlserver.database_id, sqlserver.session_id, sqlserver.sql_text)
  WHERE (sqlserver.session_id = 52)
) 
ADD TARGET package0.event_file (SET FILENAME = 'C:\Temp\TrackLocksSession.xel')
WITH (STARTUP_STATE = OFF)
GO

ALTER EVENT SESSION TrackLocksSession ON SERVER
STATE = START;
GO

--Rebuid index ONLINE
ALTER INDEX PK_Product 
ON dbo.Product
REBUILD WITH (ONLINE = ON);
GO

ALTER EVENT SESSION TrackLocksSession ON SERVER
STATE = STOP;
GO

--This numbers we need for filtering XE output
SELECT DB_ID(), OBJECT_ID('dbo.Product');
GO

--See XE file in SSMS
!!for /f %F in ('dir C:\Temp\TrackLocksSession*.xel /b') do ssms "C:\Temp\%F"

-------------------------------------
--Demo 1b: Partition switch and locks
-------------------------------------

--Setup
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
  20050101, 20050401, 20050701, 20051001,
  20060101, 20060401, 20060701, 20061001,
  20070101, 20070401, 20070701, 20071001,
  20080101, 20080401, 20080701, 20081001
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

SELECT 
  $partition.PF_FactInternetSales_OrderDateKey(OrderDateKey) AS partition, 
  MIN(OrderDateKey) AS min_value,
  COUNT(*) AS row_count,
  100. * COUNT(*) / (SELECT COUNT(*) FROM dbo.FactInternetSales) AS pct
FROM dbo.FactInternetSales
GROUP BY $partition.PF_FactInternetSales_OrderDateKey(OrderDateKey)
ORDER BY 1;
GO

IF OBJECT_ID('dbo.NewFactInternetSales', 'U') IS NOT NULL
  DROP TABLE dbo.NewFactInternetSales;
GO

SELECT TOP 0 *
INTO dbo.NewFactInternetSales
FROM dbo.FactInternetSales;
GO

ALTER TABLE dbo.NewFactInternetSales
ADD CONSTRAINT PK_NewFactInternetSales
PRIMARY KEY CLUSTERED (OrderDateKey, SalesOrderNumber, SalesOrderLineNumber);
GO

ALTER TABLE dbo.NewFactInternetSales
ADD CONSTRAINT CK_NewFactInternetSales
CHECK (OrderDateKey >= 20081001);
GO

INSERT INTO dbo.NewFactInternetSales (
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
SELECT TOP (3)
  'SO75124',
  ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),
  ProductKey, 
  20081001, 
  21768, 
  PromotionKey, 
  CurrencyKey, 
  1, 
  OrderQuantity, 
  UnitPrice, 
  SalesAmount, 
  TaxAmt, 
  Freight
FROM dbo.FactInternetSales
GO

SELECT * FROM dbo.NewFactInternetSales;
GO

--Use XE to captue locks

--*************** CHANGE SPID!!! ******************************************

EXEC xp_cmdshell 'del "C:\Temp\TrackLocksSession*.xel"';
GO

IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'TrackLocksSession')
  DROP EVENT SESSION TrackLocksSession ON SERVER;
GO

CREATE EVENT SESSION TrackLocksSession ON SERVER 
ADD EVENT sqlserver.lock_acquired,
ADD EVENT sqlserver.lock_released (
  ACTION (sqlserver.database_id, sqlserver.session_id, sqlserver.sql_text)
  WHERE (sqlserver.session_id = 52)
) 
ADD TARGET package0.event_file (SET FILENAME = 'C:\Temp\TrackLocksSession.xel')
WITH (STARTUP_STATE = OFF)
GO

ALTER EVENT SESSION TrackLocksSession ON SERVER
STATE = START;
GO

--Switch partitions
ALTER TABLE dbo.NewFactInternetSales
SWITCH TO dbo.FactInternetSales PARTITION 17;
GO

ALTER EVENT SESSION TrackLocksSession ON SERVER
STATE = STOP;
GO

--This numbers we need for filtering XE output
SELECT DB_ID(), OBJECT_ID('dbo.FactInternetSales'), OBJECT_ID('dbo.NewFactInternetSales');
GO

--See XE file in SSMS
!!for /f %F in ('dir C:\Temp\TrackLocksSession*.xel /b') do ssms "C:\Temp\%F"

--------------------------------------
--Demo 1c: Online rebuild and blocking
--------------------------------------

--Session 1
BEGIN TRAN;
SELECT ProductName, ProductPrice 
FROM dbo.Product WITH (REPEATABLEREAD) 
WHERE ProductID = 1;
--COMMIT;
GO

--Session 2
ALTER INDEX PK_Product 
ON dbo.Product
REBUILD WITH (ONLINE = ON);
GO

--Session 3
SELECT ProductName, ProductPrice 
FROM dbo.Product WITH (NOLOCK)
WHERE ProductID = 2;
GO

--See blocking
SELECT request_session_id, request_mode, request_status, *
FROM sys.dm_tran_locks
WHERE resource_type <> 'KEY';
GO

SELECT session_id, wait_time, wait_type, blocking_session_id, command
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0;
GO

---------------------------------------
--Demo1d: Partition SWITCH and blocking
---------------------------------------

--Setup
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
  20050101, 20050401, 20050701, 20051001,
  20060101, 20060401, 20060701, 20061001,
  20070101, 20070401, 20070701, 20071001,
  20080101, 20080401, 20080701, 20081001
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

SELECT 
  $partition.PF_FactInternetSales_OrderDateKey(OrderDateKey) AS partition, 
  MIN(OrderDateKey) AS min_value,
  COUNT(*) AS row_count,
  100. * COUNT(*) / (SELECT COUNT(*) FROM dbo.FactInternetSales) AS pct
FROM dbo.FactInternetSales
GROUP BY $partition.PF_FactInternetSales_OrderDateKey(OrderDateKey)
ORDER BY 1;
GO

IF OBJECT_ID('dbo.NewFactInternetSales', 'U') IS NOT NULL
  DROP TABLE dbo.NewFactInternetSales;
GO

SELECT TOP 0 *
INTO dbo.NewFactInternetSales
FROM dbo.FactInternetSales;
GO

ALTER TABLE dbo.NewFactInternetSales
ADD CONSTRAINT PK_NewFactInternetSales
PRIMARY KEY CLUSTERED (OrderDateKey, SalesOrderNumber, SalesOrderLineNumber);
GO

ALTER TABLE dbo.NewFactInternetSales
ADD CONSTRAINT CK_NewFactInternetSales
CHECK (OrderDateKey >= 20081001);
GO

INSERT INTO dbo.NewFactInternetSales (
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
SELECT TOP (3)
  'SO75124',
  ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),
  ProductKey, 
  20081001, 
  21768, 
  PromotionKey, 
  CurrencyKey, 
  1, 
  OrderQuantity, 
  UnitPrice, 
  SalesAmount, 
  TaxAmt, 
  Freight
FROM dbo.FactInternetSales
GO

SELECT * FROM dbo.NewFactInternetSales;
GO

--Session 1
BEGIN TRAN;
SELECT SalesOrderNumber, OrderDateKey, ProductKey, OrderQuantity, SalesAmount
FROM dbo.FactInternetSales WITH (REPEATABLEREAD)
WHERE SalesOrderNumber = 'SO43697';
--COMMIT

--Session 2
ALTER TABLE dbo.NewFactInternetSales
SWITCH TO dbo.FactInternetSales PARTITION 17;
GO

--Session 3
SELECT SalesOrderNumber, OrderDateKey, ProductKey, OrderQuantity, SalesAmount
FROM dbo.FactInternetSales WITH (NOLOCK)
WHERE SalesOrderNumber = 'SO43698';
GO 

--Session 4
SELECT * FROM dbo.NewFactInternetSales WITH (NOLOCK);
GO

--See blocking
SELECT request_session_id, request_mode, request_status, *
FROM sys.dm_tran_locks
WHERE resource_type <> 'KEY';
GO

SELECT session_id, wait_time, wait_type, blocking_session_id, command
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0;
GO

-------------------------------------
--Demo 2: Managed lock priority (MLP)
-------------------------------------

--<<<<<<<<<Kill all blockers

--Session 1
BEGIN TRAN;
SELECT ProductName, ProductPrice 
FROM dbo.Product WITH (REPEATABLEREAD) 
WHERE ProductID = 1;
--COMMIT;
GO

--Session 2
ALTER INDEX PK_Product 
ON dbo.Product
REBUILD WITH (
  ONLINE = ON (
    WAIT_AT_LOW_PRIORITY (MAX_DURATION = 1, ABORT_AFTER_WAIT = BLOCKERS)
  )
);
GO

--Session 3
SELECT ProductName, ProductPrice 
FROM dbo.Product
WHERE ProductID = 2;
GO

--See blocking
SELECT request_session_id, request_mode, request_status, *
FROM sys.dm_tran_locks
WHERE resource_type <> 'KEY';
GO

SELECT session_id, wait_time, wait_type, blocking_session_id, command
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0;
GO

EXEC sp_readerrorlog;
GO

--<<<<<<<<Kill self

--Session 1
BEGIN TRAN;
SELECT ProductName, ProductPrice 
FROM dbo.Product WITH(REPEATABLEREAD) 
WHERE ProductID = 1;
--COMMIT;
GO

--Session 2
ALTER INDEX PK_Product 
ON dbo.Product
REBUILD WITH (
  ONLINE = ON (
    WAIT_AT_LOW_PRIORITY (MAX_DURATION = 1, ABORT_AFTER_WAIT = SELF)
  )
);
GO

--Session 3
SELECT ProductName, ProductPrice 
FROM dbo.Product
WHERE ProductID = 2;
GO

EXEC sp_readerrorlog;
GO

--New wait types
SELECT * FROM sys.dm_os_wait_stats 
WHERE wait_type LIKE '%ABORT[_]BLOCKERS' OR wait_type LIKE '%LOW[_]PRIORITY';
GO

--XE
SELECT *
FROM sys.dm_xe_objects
WHERE name LIKE '%low%priority%';
GO

-------------------------------------------------------
--Demo 3: Single Partition Online Index Rebuild (SPOIR)
-------------------------------------------------------

IF OBJECT_ID('dbo.FactInternetSales', 'U') IS NOT NULL
  DROP TABLE dbo.FactInternetSales;
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
INTO dbo.FactInternetSales
FROM AdventureWorksDW2012.dbo.FactInternetSales;
GO

INSERT INTO dbo.FactInternetSales (
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

INSERT INTO dbo.FactInternetSales (
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
SELECT TOP 100000
  'SO' + RIGHT('00000000' + CONVERT(varchar(12), DENSE_RANK() OVER (ORDER BY SalesOrderNumber)+(SELECT MAX(CONVERT(int, RIGHT(SalesOrderNumber, 12))) FROM dbo.FactInternetSales)), 12),
  ROW_NUMBER() OVER (PARTITION BY SalesOrderNumber ORDER BY SalesOrderLineNumber), 
  ProductKey, OrderDateKey, CustomerKey, PromotionKey, CurrencyKey, SalesTerritoryKey, OrderQuantity, UnitPrice, SalesAmount, TaxAmt, Freight
FROM dbo.FactInternetSales
ORDER BY NEWID();
CHECKPOINT;
GO 10

SELECT COUNT(*) FROM dbo.FactInternetSales;
GO

CREATE PARTITION FUNCTION PF_FactInternetSales_OrderDateKey(int)
AS RANGE RIGHT FOR VALUES (
  20050101, 20050401, 20050701, 20051001,
  20060101, 20060401, 20060701, 20061001,
  20070101, 20070401, 20070701, 20071001,
  20080101, 20080401, 20080701, 20081001
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

SELECT * 
FROM sys.partitions 
WHERE [object_id] = OBJECT_ID('dbo.FactInternetSales');
GO

SELECT 
  $partition.PF_FactInternetSales_OrderDateKey(OrderDateKey) AS partition, 
  MIN(OrderDateKey) AS min_value,
  COUNT(*) AS row_count,
  100. * COUNT(*) / (SELECT COUNT(*) FROM dbo.FactInternetSales) AS pct
FROM dbo.FactInternetSales
GROUP BY $partition.PF_FactInternetSales_OrderDateKey(OrderDateKey)
ORDER BY 1;
GO

SET STATISTICS TIME ON;
GO

ALTER INDEX PK_FactInternetSales 
ON dbo.FactInternetSales
REBUILD;
GO

ALTER INDEX PK_FactInternetSales 
ON dbo.FactInternetSales
REBUILD PARTITION = 15;
GO

ALTER INDEX PK_FactInternetSales 
ON dbo.FactInternetSales
REBUILD
WITH (ONLINE = ON);
GO

ALTER INDEX PK_FactInternetSales 
ON dbo.FactInternetSales
REBUILD PARTITION = 15
WITH (ONLINE = ON);
GO

SET STATISTICS TIME OFF;
GO
