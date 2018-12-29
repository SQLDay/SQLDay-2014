USE [master]
GO

CREATE DATABASE [CDC_SQLDay2014]
 CONTAINMENT = NONE
 ON  PRIMARY ( NAME = N'CDC_SQLDay2014', FILENAME = N'D:\MSSQL\MSSQL11.DEV2012\MSSQL\DATA\CDC_SQLDay2014.mdf' , SIZE = 10240KB , MAXSIZE = UNLIMITED, FILEGROWTH = 32768KB )
 LOG ON  ( NAME = N'CDC_SQLDay2014_log', FILENAME = N'D:\MSSQL\MSSQL11.DEV2012\MSSQL\DATA\CDC_SQLDay2014_log.ldf' , SIZE = 4096KB , MAXSIZE = 4194304KB , FILEGROWTH = 16384KB )
GO

ALTER DATABASE [CDC_SQLDay2014] SET COMPATIBILITY_LEVEL = 110
GO

----------------------------------------------------------------------------------------


USE CDC_SQLDay2014
GO

SELECT [BusinessEntityID]
      ,[PersonType]
      ,[NameStyle]
      ,[Title]
      ,[FirstName]
      ,[MiddleName]
      ,[LastName]
      ,[Suffix]
      ,[EmailPromotion]
      ,[rowguid]
      ,[ModifiedDate]
into CDC_SQLDay2014.dbo.Person
from [AdventureWorks2012].[Person].[Person]
GO

ALTER TABLE dbo.Person ADD CONSTRAINT PK_Person PRIMARY KEY CLUSTERED 
	(BusinessEntityID ) WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

