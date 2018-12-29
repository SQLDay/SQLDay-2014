-- create fresh AdventureWorks2012
USE master;
GO
IF DB_ID('AdventureWorks2012') IS NOT NULL
BEGIN;
	ALTER DATABASE AdventureWorks2012 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE AdventureWorks2012;
END;

RESTORE DATABASE AdventureWorks2012
	FROM Disk = 'AdventureWorks2012.bak';
ALTER AUTHORIZATION ON Database::AdventureWorks2012 TO sa;
GO

USE AdventureWorks2012;
GO

-------

-- enable CDC for the database
EXEC sys.sp_cdc_enable_db;

-- enable CDC on a requested table
EXEC sys.sp_cdc_enable_table 'Sales', 'CurrencyRate', @role_name='CDCDataReaders';

-- check that CDC is active
EXEC sys.sp_cdc_help_change_data_capture;

-- make some changes
INSERT INTO Sales.CurrencyRate (CurrencyRateDate,
	FromCurrencyCode, ToCurrencyCode, AverageRate, EndOfDayRate)
VALUES
	(CONVERT(DATE, SYSDATETIME()), 'PLN', 'USD', 3.21, 3.21),
	(CONVERT(DATE, SYSDATETIME()), 'PLN', 'EUR', 4.18, 4.18),
	(CONVERT(DATE, SYSDATETIME()), 'PLN', 'GBP', 5.0, 5.02);

UPDATE Sales.CurrencyRate
	SET EndOfDayRate = 3.22 WHERE FromCurrencyCode='PLN' AND ToCurrencyCode='USD';
UPDATE Sales.CurrencyRate
	SET EndOfDayRate = 4.19 WHERE FromCurrencyCode='PLN' AND ToCurrencyCode='EUR';

DELETE FROM Sales.CurrencyRate WHERE FromCurrencyCode='PLN' AND ToCurrencyCode='GBP';

-- get the change info
WAITFOR DELAY '0:00:05';

SELECT *
FROM cdc.fn_cdc_get_all_changes_Sales_CurrencyRate(
    sys.fn_cdc_get_min_lsn('Sales_CurrencyRate'), sys.fn_cdc_get_max_lsn(),
	'all update old'
);

-- this is how to get the time
SELECT sys.fn_cdc_map_lsn_to_time([__$start_lsn]) AS event_time 
	, *
FROM cdc.fn_cdc_get_all_changes_Sales_CurrencyRate(
    sys.fn_cdc_get_min_lsn('Sales_CurrencyRate'), sys.fn_cdc_get_max_lsn(),
	'all update old'
);

-- try to change table definition

ALTER TABLE Sales.CurrencyRate ADD IsActive BIT NOT NULL CONSTRAINT df_IsActive_1 DEFAULT (1);
GO

SELECT * FROM Sales.CurrencyRate WHERE FromCurrencyCode='PLN';

-- see that these changes aren't tracked
SELECT *
FROM cdc.fn_cdc_get_all_changes_Sales_CurrencyRate(
    sys.fn_cdc_get_min_lsn('Sales_CurrencyRate'), sys.fn_cdc_get_max_lsn(),
	'all update old'
);

-- now change existing column in incompatible way
ALTER TABLE Sales.CurrencyRate ALTER COLUMN EndOfDayRate NVARCHAR(10);

UPDATE Sales.CurrencyRate SET EndOfDayRate='10.00000'
	WHERE FromCurrencyCode='PLN';

EXEC sys.sp_cdc_get_ddl_history 'Sales_CurrencyRate';

-- as long as the data is convertible back to money, CDC will handle this
-- we will have correct data, but not identical to what we entered
-- (need to be aware of this)

SELECT *
FROM cdc.fn_cdc_get_all_changes_Sales_CurrencyRate(
    sys.fn_cdc_get_min_lsn('Sales_CurrencyRate'), sys.fn_cdc_get_max_lsn(),
	'all update old'
);

ALTER TABLE Sales.CurrencyRate ALTER COLUMN EndOfDayRate MONEY;

UPDATE Sales.CurrencyRate SET EndOfDayRate=5.55
	WHERE FromCurrencyCode='PLN';

EXEC sys.sp_cdc_get_ddl_history 'Sales_CurrencyRate';

SELECT *
FROM cdc.fn_cdc_get_all_changes_Sales_CurrencyRate(
    sys.fn_cdc_get_min_lsn('Sales_CurrencyRate'), sys.fn_cdc_get_max_lsn(),
	'all update old'
);

