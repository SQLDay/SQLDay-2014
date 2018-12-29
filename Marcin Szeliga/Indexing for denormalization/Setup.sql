USE [master];
GO

IF DATABASEPROPERTYEX (N'Indices', N'Version') > 0
BEGIN
	ALTER DATABASE Indices SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE Indices;
END
GO

CREATE DATABASE Indices
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Indices', 
FILENAME = N'C:\SQL\Indices.mdf' , 
SIZE = 1000MB , FILEGROWTH = 100MB )
 LOG ON 
( NAME = N'Indices_log', FILENAME = N'C:\SQL\Indices_log.ldf' , 
SIZE = 750MB , FILEGROWTH = 50MB )
GO

ALTER DATABASE Indices SET RECOVERY SIMPLE;
GO

USE Indices
GO

CREATE TABLE dbo.Customers
(
	CustomerID int IDENTITY (1,1)
		CONSTRAINT PK_Customers PRIMARY KEY,
	FirstName nvarchar(50),
	LastName nvarchar(50),
	MiddleName nvarchar(50),
	BirthDate date,
	Gender nchar(1),
	Adress nvarchar(120)
);
GO

INSERT INTO dbo.Customers (FirstName,LastName,MiddleName,BirthDate,Gender,Adress)
SELECT FirstName,LastName,MiddleName,BirthDate,Gender, AddressLine1
FROM [ContosoRetailDW].dbo.DimCustomer;
GO 10

UPDATE [dbo].[Customers]
SET LastName = 'Szeliga'
WHERE Adress = '3761 N. 14th St';

UPDATE [dbo].[Customers]
SET LastName = 'SZELIGA'
WHERE Adress = '2243 W St.'
GO

UPDATE [dbo].[Customers]
SET [MiddleName] = NULL
WHERE [CustomerID]%3=1
GO

CREATE TABLE dbo.SellingPriceTemplate
(
    SellingPriceID int IDENTITY(1,1) 
      CONSTRAINT PK_SellingPriceTemplate PRIMARY KEY,
    SubTotal decimal(18,2) NOT NULL,
    TaxAmount decimal(18,2) NOT NULL,
    OrderQty int NOT NULL,
	Filler char(300)
);
GO

INSERT INTO dbo.SellingPriceTemplate (SubTotal,TaxAmount,OrderQty)
SELECT [UnitPrice], [UnitPrice]*.23, [OrderQty]
FROM [AdventureWorks2008R2].Sales.SalesOrderDetail
GO 5

CREATE TABLE dbo.[SalesOrderDetail](
	[SalesOrderID] [int] NOT NULL,
	[SalesOrderDetailID] [int] IDENTITY(1,1) NOT NULL,
	[CarrierTrackingNumber] [nvarchar](25) NULL,
	[OrderQty] [smallint] NOT NULL,
	[ProductID] [int] NOT NULL,
	[SpecialOfferID] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[UnitPriceDiscount] [money] NOT NULL,
	[LineTotal]  AS (isnull(([UnitPrice]*((1.0)-[UnitPriceDiscount]))*[OrderQty],(0.0))),
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID] PRIMARY KEY CLUSTERED 
(
	[SalesOrderID] ASC,
	[SalesOrderDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY];
GO

INSERT INTO dbo.[SalesOrderDetail] (SalesOrderID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID,UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate)
SELECT SalesOrderID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID,UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate
FROM [AdventureWorks2008R2].Sales.SalesOrderDetail
GO 10

CREATE NONCLUSTERED INDEX [AK_SalesOrderDetail_rowguid] ON dbo.[SalesOrderDetail]
(
	[rowguid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_SalesOrderDetail_ProductID] ON dbo.[SalesOrderDetail]
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SELECT *
INTO [SalesOrderDetailV2] 
FROM dbo.SalesOrderDetail;
GO

CREATE UNIQUE CLUSTERED INDEX PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID
ON [SalesOrderDetailV2](SalesOrderID, SalesOrderDetailID);
GO

SELECT *
INTO dbo.Product
FROM [AdventureWorks2008].Production.Product;
GO