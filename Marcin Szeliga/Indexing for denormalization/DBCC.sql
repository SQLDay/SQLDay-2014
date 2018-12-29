USE Indices;
GO


DECLARE @StartTime DATETIME;
SET @StartTime = GETDATE();
DBCC CHECKDB WITH NO_INFOMSGS;
PRINT 'Initial DBCC CHECKDB duration: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) as varchar(10)) + ' ms'
GO
--About 2 sec

ALTER TABLE [dbo].[SellingPriceTemplate]
ADD LineTotal AS ((SubTotal + TaxAmount) * OrderQty);
GO

CREATE INDEX SellingPriceExtendedAmount
ON [dbo].[SellingPriceTemplate](LineTotal)
GO

ALTER TABLE [dbo].[SellingPriceTemplate]
ADD FillerUp AS (UPPER(RIGHT(Filler,1)));
GO

CREATE INDEX SellingPriceInitial
ON [dbo].[SellingPriceTemplate](FillerUp)
GO

DBCC CHECKDB WITH NO_INFOMSGS;
GO

DECLARE @StartTime DATETIME;
SET @StartTime = GETDATE();
DBCC CHECKDB WITH NO_INFOMSGS;
PRINT 'DBCC CHECKDB duration with TWO indexed computed column: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) as varchar(10)) + ' ms'
GO
--About 6 sec

DECLARE @StartTime DATETIME;
SET @StartTime = GETDATE();
DBCC CHECKDB WITH PHYSICAL_ONLY, NO_INFOMSGS;
PRINT 'DBCC CHECKDB PHYSICAL_ONLY duration with TWO indexed computed columns: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) as varchar(10)) + ' ms'
GO
--A second and a half

ALTER INDEX SellingPriceExtendedAmount
ON [dbo].[SellingPriceTemplate]
DISABLE;

ALTER INDEX SellingPriceInitial
ON [dbo].[SellingPriceTemplate]
DISABLE;

DECLARE @StartTime DATETIME;
SET @StartTime = GETDATE();
DBCC CHECKDB WITH NO_INFOMSGS;
PRINT 'DBCC CHECKDB duration with disabled indices on computed columns: ' + CAST(DATEDIFF(ms, @StartTime, GETDATE()) as varchar(10)) + ' ms'
GO

--Back to 2 sec