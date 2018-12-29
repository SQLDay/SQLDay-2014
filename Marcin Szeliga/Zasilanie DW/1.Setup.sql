USE [master];
GO

IF DATABASEPROPERTYEX (N'StageV1', N'Version') > 0
BEGIN
	ALTER DATABASE StageV1 SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE StageV1;
END
GO

CREATE DATABASE StageV1
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Stage', 
FILENAME = N'C:\SQL\Stage.mdf' , 
SIZE = 1000MB , FILEGROWTH = 100MB )
 LOG ON 
( NAME = N'Stage_log', FILENAME = N'C:\SQL\Stage_log.ldf' , 
SIZE = 750MB , FILEGROWTH = 50MB )
GO

ALTER DATABASE StageV1 SET RECOVERY SIMPLE;
GO

IF DATABASEPROPERTYEX (N'DW', N'Version') > 0
BEGIN
	ALTER DATABASE DW SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DW;
END
GO

CREATE DATABASE DW
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'DW', 
FILENAME = N'C:\SQL\DW.mdf' , 
SIZE = 1000MB , FILEGROWTH = 100MB )
 LOG ON 
( NAME = N'DW_log', FILENAME = N'C:\SQL\DW_log.ldf' , 
SIZE = 750MB , FILEGROWTH = 50MB )
GO

ALTER DATABASE DW SET RECOVERY SIMPLE;
GO

USE [StageV1]
GO

SELECT [ProductKey], [EnglishProductName], [ListPrice], [Size], [EnglishDescription], [LargePhoto]
INTO DimProducts
FROM [AdventureWorksDW2012].[dbo].[DimProduct];
GO

ALTER TABLE DimProducts
ADD PRIMARY KEY ([ProductKey]);
GO

UPDATE [dbo].[DimProducts]
SET [EnglishProductName] = [EnglishProductName] + ' ' + CAST([ProductKey] AS VARCHAR(5));
GO

SELECT [CustomerKey], [FirstName], [LastName], [Title], [BirthDate], [EnglishEducation], [Phone]
INTO DimCustomers
FROM [AdventureWorksDW2012].[dbo].[DimCustomer];
GO

ALTER TABLE [dbo].[DimCustomers]
ADD [CustomerBusinessKey] INT;
GO
UPDATE [dbo].[DimCustomers]
SET [CustomerBusinessKey] = [CustomerKey];
GO
ALTER TABLE [dbo].[DimCustomers]
DROP COLUMN [CustomerKey];
GO
ALTER TABLE [dbo].[DimCustomers]
ALTER COLUMN [CustomerBusinessKey] INT NOT NULL;
GO
ALTER TABLE [dbo].[DimCustomers]
ADD PRIMARY KEY ([CustomerBusinessKey]);
GO

SELECT *
INTO DimCustomersDups
FROM DimCustomers;

INSERT INTO DimCustomersDups
SELECT TOP 100 *
FROM DimCustomers;
GO

CREATE INDEX IDXCustomerKey
ON DimCustomersDups ([CustomerBusinessKey]);
GO


USE DW
GO

SELECT TOP 10000 [CustomerKey] AS TempKey, [FirstName], [LastName], [Title], [BirthDate], [EnglishEducation], [Phone]
INTO DimCustomers
FROM [AdventureWorksDW2012].[dbo].[DimCustomer];
GO

ALTER TABLE [dbo].[DimCustomers]
ADD [CustomerBusinessKey] INT;
GO
UPDATE [dbo].[DimCustomers]
SET [CustomerBusinessKey] = TempKey;
GO
ALTER TABLE [dbo].[DimCustomers]
DROP COLUMN TempKey;
GO
ALTER TABLE DimCustomers
ADD CustomerKey INT IDENTITY PRIMARY KEY;
GO


--STOP 
USE DW
GO
ALTER TABLE DimCustomers
ADD StartDate Date;
GO
ALTER TABLE DimCustomers
ADD EndDate Date;
GO

TRUNCATE TABLE DimCustomers;
GO

USE StageV1
GO

UPDATE [dbo].[DimCustomers]
SET [LastName] = 'XYZ ' + [LastName] 
WHERE [CustomerBusinessKey] <11500;

UPDATE [dbo].[DimCustomers]
SET [EnglishEducation] = 'ABC'
WHERE [CustomerBusinessKey] BETWEEN 15000 AND 16000;

INSERT INTO [dbo].[DimCustomers]
VALUES ('Marcin','Szeliga','Mr.','19700101',NULL,NULL,999999)
GO

UPDATE [dbo].[DimCustomers]
SET [LastName] = 'ABC ' + [LastName] 
WHERE [CustomerBusinessKey] <11500;

UPDATE [dbo].[DimCustomers]
SET [EnglishEducation] = 'XYZ'
WHERE [CustomerBusinessKey] BETWEEN 15000 AND 16000;
GO