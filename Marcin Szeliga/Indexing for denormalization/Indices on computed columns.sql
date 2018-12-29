--Establish a baseline
USE Indices
GO

CREATE TABLE dbo.SellingPrice
(
    SellingPriceID int IDENTITY(1,1) 
      CONSTRAINT PK_SellingPrice PRIMARY KEY,
    SubTotal decimal(18,2) NOT NULL,
    TaxAmount decimal(18,2) NOT NULL,
    OrderQty int NOT NULL,
	Filler char(300) DEFAULT 'a'
);
GO

DECLARE @StartTime DATETIME;
SET @StartTime = GETDATE();

INSERT INTO dbo.SellingPrice (SubTotal,TaxAmount,OrderQty)
SELECT SubTotal, TaxAmount, OrderQty
FROM dbo.SellingPriceTemplate;

PRINT 'Base table load duration: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) as varchar(10)) + ' ms'
GO
--Base table load duration: 606585 rows in 1600 ms 
--Not so important --> this is not typical workload for OLTP DBs

DECLARE @StartTime DATETIME
SET @StartTime = GETDATE()

UPDATE dbo.SellingPriceTemplate 
SET SubTotal = SubTotal-1
WHERE [SellingPriceID]%1000=1

DELETE dbo.SellingPriceTemplate 
WHERE [SellingPriceID]%1000=2

PRINT 'Base table UPDATE/DELETE duration: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) as varchar(10)) + ' ms'
GO
--'Base table UPDATE/DELETE duration: 1214 rows in 70 ms --> 17 rows per ms

DECLARE @StartTime DATETIME
SET @StartTime = GETDATE()

SELECT *
FROM dbo.SellingPrice
WHERE (SubTotal + TaxAmount ) * OrderQty >30000;

PRINT 'Base table SELECT duration: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) as varchar(10)) + ' ms'
GO
--Base table select duration: 30 rows in 130 ms --> 0.2 row per ms


--BTW Why you should avoid triggers 

CREATE TABLE dbo.SellingPriceV2
(
    SellingPriceID int IDENTITY(1,1) 
      CONSTRAINT PK_SellingPriceV2 PRIMARY KEY,
    SubTotal decimal(18,2) NOT NULL,
    TaxAmount decimal(18,2) NOT NULL,
    OrderQty int NOT NULL,
    LineTotal decimal(18,2) NULL,
	Filler char(300) DEFAULT 'a'
);
GO

CREATE TRIGGER TR_SellingPrice_InsertUpdate
ON dbo.SellingPriceV2
AFTER INSERT, UPDATE AS BEGIN
  SET NOCOUNT ON;
  UPDATE sp
  SET sp.LineTotal = (sp.SubTotal 
                        + sp.TaxAmount )
                        * sp.OrderQty
  FROM dbo.SellingPriceV2 AS sp
  INNER JOIN inserted AS i
  ON sp.SellingPriceID = i.SellingPriceId;
END;
GO

CREATE INDEX SellingPriceV2LineTotal
ON dbo.SellingPriceV2(LineTotal)
GO

DECLARE @StartTime DATETIME
SET @StartTime = GETDATE()

INSERT INTO dbo.SellingPriceV2 (SubTotal,TaxAmount,OrderQty)
SELECT SubTotal, TaxAmount, OrderQty
FROM dbo.SellingPriceTemplate;

PRINT 'Table with trigger load duration: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) as varchar(10)) + ' ms'
GO
--Table with trigger load duration: 605978 rows in 25000 ms 
--Not so important --> this is not typical workload for OLTP
--But still more then 10 times slower

DECLARE @StartTime DATETIME
SET @StartTime = GETDATE()

UPDATE dbo.SellingPriceV2 
SET SubTotal = SubTotal-1
WHERE [SellingPriceID]%1000=1

DELETE dbo.SellingPriceV2 
WHERE [SellingPriceID]%1000=2

PRINT 'Table with trigger UPDATE/DELETE duration: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) as varchar(10)) + ' ms'
GO
--Table with trigger UPDATE/DELETE duration: 1214 rows in 100 ms --> 12 rows per ms

DECLARE @StartTime DATETIME
SET @StartTime = GETDATE()

SELECT *
FROM dbo.SellingPrice
WHERE (SubTotal + TaxAmount ) * OrderQty >30000;

PRINT 'Table with trigger SELECT duration: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) as varchar(10)) + ' ms'
GO
--Table with trigger SELECT duration: 30 rows in 130 ms --> 0.2 row per ms
--We gain nothing - check the execution plan

DECLARE @StartTime DATETIME
SET @StartTime = GETDATE()

SELECT *
FROM dbo.SellingPriceV2
WHERE LineTotal > 30000;

PRINT 'Table with trigger REFACTORED SELECT duration: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) as varchar(10)) + ' ms'
GO
-- Table with trigger REFACTORED SELECT duration: 0 ms.


--Indices on computed columns 

CREATE TABLE dbo.SellingPriceV3
(
    SellingPriceID int IDENTITY(1,1) 
      CONSTRAINT PK_SellingPriceV3 PRIMARY KEY,
    SubTotal decimal(18,2) NOT NULL,
    TaxAmount decimal(18,2) NOT NULL,
    OrderQty int NOT NULL,
    LineTotal AS ((SubTotal + TaxAmount) * OrderQty),
	Filler char(300) DEFAULT 'a'
);
GO

CREATE INDEX SellingPriceV3ExtendedAmount
ON dbo.SellingPriceV3(LineTotal)
GO

DECLARE @StartTime DATETIME
SET @StartTime = GETDATE()

INSERT INTO dbo.SellingPriceV3 (SubTotal,TaxAmount,OrderQty)
SELECT SubTotal, TaxAmount, OrderQty
FROM dbo.SellingPriceTemplate;

PRINT 'Table with computed column load duration: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) as varchar(10)) + ' ms'
GO
--Table with computed column load duration: 605978 rows in 8000 m
--Not so important --> this is not typical workload for OLTP
--Still about 3 times slower than our baseline 
--But also 3 times faster than it was for a table with a trigger

DECLARE @StartTime DATETIME
SET @StartTime = GETDATE()

UPDATE dbo.SellingPriceV3 
SET SubTotal = SubTotal-1
WHERE [SellingPriceID]%1000=1

DELETE dbo.SellingPriceV3 
WHERE [SellingPriceID]%1000=2

PRINT 'Table with trigger UPDATE/DELETE duration: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) as varchar(10)) + ' ms'
GO
--Table with computed column UPDATE/DELETE duration: 1214 rows in 100 ms --> 12 rows per ms

DECLARE @StartTime DATETIME
SET @StartTime = GETDATE()

SELECT *
FROM dbo.SellingPriceV3
WHERE (SubTotal + TaxAmount ) * OrderQty >30000;

PRINT 'Table with trigger SELECT duration: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) as varchar(10)) + ' ms'
GO
--Now it takes 0 milliseconds, the very only right time for OLTP databases

DROP TABLE dbo.SellingPriceV2;
DROP TABLE dbo.SellingPriceV3;
GO

