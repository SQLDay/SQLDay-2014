/*

 T-SQL Enhancements
 http://msdn.microsoft.com/en-us/library/bb510411(v=sql.120).aspx#TSQL
 Inline specification of CLUSTERED and NONCLUSTERED
 ...indexes is now allowed for disk-based tables.
 Creating a table with inline indexes is equivalent to issuing 
 a create table followed by corresponding CREATE INDEX statements. 
 Included columns and filter conditions are not supported with inline indexes.

*/

USE tempdb
GO

/*
  
  1A 

*/


CREATE TABLE dbo.Products (
	ID int identity PRIMARY KEY,
	CategoryID int INDEX IDX_Products_CategoryID,
	Name varchar(50),
	Color varchar(50)
)
GO

EXEC sp_helpindex Products

DROP TABLE dbo.Products
GO



CREATE TABLE dbo.Products (
	ID int identity PRIMARY KEY,
	CategoryID int,
		INDEX IDX_Products_CategoryID (CategoryID),
	Name varchar(50),
	Color varchar(50),
		INDEX IDX_Products_Name_Color (Name, Color)
)
GO

DROP TABLE dbo.Products
GO



CREATE TABLE dbo.Products (
	ID int identity PRIMARY KEY,
	CategoryID int INDEX IDX_Products_CategoryID,
	Name varchar(50),
	Color varchar(50) INDEX IDX_Products_Name_Color (CategoryID, Name),
)


EXEC sp_helpindex Products

DROP TABLE dbo.Products
GO




-- fillfactor
CREATE TABLE dbo.Products (
	ID int identity PRIMARY KEY,
	CategoryID int,
	Name varchar(50),
	Color varchar(50) INDEX IDX WITH (FILLFACTOR = 80)
)

SELECT name, index_id, type, type_desc, fill_factor
FROM sys.indexes WHERE object_id = OBJECT_ID('Products')
GO

DROP TABLE dbo.Products
GO




-- !!! unique indexes
CREATE TABLE dbo.Products (
	ID int identity PRIMARY KEY,
	CategoryID int,
	Name varchar(50),
	Color varchar(50),
		--UNIQUE INDEX IDX_Products_Name_Color (Name, Color) -- !
		CONSTRAINT IDX_Products_Name_Color UNIQUE (Name, Color) 
)

EXEC sp_helpindex Products

DROP TABLE dbo.Products
GO


-- !!! indexes with include clause
CREATE TABLE dbo.Products (
	ID int identity PRIMARY KEY,
	CategoryID int,
	Name varchar(50),
	Color varchar(50),
		INDEX IDX (CategoryID) INCLUDE (Name, Color)
)



-- !!! filtered indexes 
CREATE TABLE dbo.Products (
	ID int identity PRIMARY KEY,
	CategoryID int,
	Name varchar(50),
	Color varchar(50),
		INDEX IDX (Name) WHERE Color = 'Red'
)











/*

  1B :  Improved temp table caching

*/



USE tempdb
GO

-- DROP PROCEDURE UseTempTable
CREATE PROCEDURE UseTempTable
AS
BEGIN
SET NOCOUNT ON
	
	CREATE TABLE #Products  (
		ID int identity,
		CategoryID int,
		Name char(1000)
	)
	
	CREATE UNIQUE CLUSTERED INDEX IDX1 ON #Products(ID)
	CREATE NONCLUSTERED INDEX IDX2 ON #Products(CategoryID)

	INSERT INTO #Products (CategoryID, Name) VALUES (38, 'Bike SJ')
END
GO


DECLARE @TempTablesCounter INT, @i INT;
SELECT @TempTablesCounter = cntr_value FROM sys.dm_os_performance_counters
WHERE counter_name = 'Temp Tables Creation Rate'

SET @i = 0
WHILE (@i < 1000)
BEGIN
	EXEC UseTempTable
	SET @i += 1
END

SELECT cntr_value - @TempTablesCounter AS 'Temp Tables Creation Rate'
FROM sys.dm_os_performance_counters WHERE counter_name = 'Temp Tables Creation Rate'




-- DROP PROCEDURE UseTempTable2
CREATE PROCEDURE UseTempTable2
AS
BEGIN
SET NOCOUNT ON
	
	CREATE TABLE #Products (
		ID int identity PRIMARY KEY,
		CategoryID int,
		Name char(1000)
		--,CONSTRAINT PK_Prod PRIMARY KEY (ID)
	)
	
	INSERT INTO #Products (CategoryID, Name) VALUES (38, 'Bike SJ')
END
GO


DECLARE @TempTablesCounter INT, @i INT;
SELECT @TempTablesCounter = cntr_value FROM sys.dm_os_performance_counters
WHERE counter_name = 'Temp Tables Creation Rate'

SET @i = 0
WHILE (@i < 1000)
BEGIN
	EXEC UseTempTable2
	SET @i += 1
END

SELECT cntr_value - @TempTablesCounter AS 'Temp Tables Creation Rate'
FROM sys.dm_os_performance_counters WHERE counter_name = 'Temp Tables Creation Rate'






-- DROP PROCEDURE UseTempTable2014
CREATE PROCEDURE UseTempTable2014
AS
BEGIN
SET NOCOUNT ON
	
	CREATE TABLE #Products  (
		ID int identity PRIMARY KEY,
		CategoryID int INDEX IDX_Products_CategoryID (CategoryID),
		Name char(1000)
	)
	
	INSERT INTO #Products (CategoryID, Name) VALUES (38, 'Bike SJ')
END
GO



DECLARE @TempTablesCounter INT, @i INT;
SELECT @TempTablesCounter = cntr_value FROM sys.dm_os_performance_counters
WHERE counter_name = 'Temp Tables Creation Rate'

SET @i = 0
WHILE (@i < 1000)
BEGIN
	EXEC UseTempTable2014
	SET @i += 1
END

SELECT cntr_value - @TempTablesCounter AS 'Temp Tables Creation Rate'
FROM sys.dm_os_performance_counters WHERE counter_name = 'Temp Tables Creation Rate'



DROP PROCEDURE UseTempTable
DROP PROCEDURE UseTempTable2
DROP PROCEDURE UseTempTable2014
GO





/*

 1C : TABLE VARIABLES and INLINE INDEXES

*/



-- TABLE VARIABLES
DECLARE @Products AS TABLE (
	ID int identity PRIMARY KEY,
	CategoryID int,
	Name varchar(50),
	Color varchar(50),
		INDEX IDX (Name, Color) WITH (FILLFACTOR = 80)	
)


/*

 SQL Server 2014 : TABLE VARIABLES vs TEMP TABLES

*/

USE tempdb

CREATE TABLE #Products (
	ID int identity PRIMARY KEY,
	CategoryID int,
		INDEX IDX_Products_CategoryID (CategoryID),
	Name varchar(50),
	Color varchar(50)
)
GO


INSERT #Products (CategoryID, Name, Color)  
SELECT ProductSubcategoryID, Name, Color
FROM AdventureWorks2012.dbo.bigProduct
UNION 
SELECT 38, 'Bike SJ', 'Red'
UNION
SELECT 38, 'Bike SJ HT', 'Red'
UNION
SELECT 38, 'Bike SJ', 'White'



--SELECT * FROM #Products


-- index seek/ index scan?
SELECT CategoryID FROM #Products
WHERE CategoryID = 38


-- ?
SELECT Name FROM #Products
WHERE CategoryID = 38


SELECT * FROM sys.stats WHERE object_id = OBJECT_ID('#Products')


DROP TABLE #Products





USE tempdb

DECLARE @Products AS TABLE  (
	ID int identity PRIMARY KEY,
	CategoryID int,
		INDEX IDX_Products_CategoryID (CategoryID),
	Name varchar(50),
	Color varchar(50)
)

INSERT @Products (CategoryID, Name, Color)  
SELECT ProductSubcategoryID, Name, Color
FROM AdventureWorks2012.dbo.bigProduct
UNION 
SELECT 38, 'Bike SJ', 'Red'
UNION
SELECT 38, 'Bike SJ HT', 'Red'
UNION
SELECT 38, 'Bike SJ', 'White'



-- index seek/ index scan?
SELECT CategoryID FROM @Products
WHERE CategoryID = 38


-- ?
SELECT Name FROM @Products
WHERE CategoryID = 38

-- ?
SELECT ID, CategoryID FROM @Products
WHERE CategoryID = 38

-- Estimated no of rows = 1 !









/*

  LINKS
  
  Kendra Little - Are Table Variables as Good as Temporary Tables in SQL 2014?
  http://www.brentozar.com/archive/2014/04/table-variables-good-temp-tables-sql-2014/ 

  Pawe³ Potasiñski - SQL Server 2014 – Definicje indeksów inline w sk³adni polecenia CREATE TABLE
  http://blog.sqlgeek.pl/2014/01/10/sql-server-2014-definicje-indeksw-inline-w-skladni-polecenia-create-table/

  Klaus Aschenbrenner - Improved Temp Table Caching in SQL Server 2014
  http://www.sqlpassion.at/archive/2013/06/27/improved-temp-table-caching-in-sql-server-2014/

  Paul White - Temporary Table Caching Explained 
  http://sqlblog.com/blogs/paul_white/archive/2012/08/17/temporary-object-caching-explained.aspx

  Damian Widera, £ukasz Grala - Tabele tymczasowe i zmienne tablicowe – fakty i mity
  http://technet.microsoft.com/pl-pl/library/tabele-tymczasowe-i-zmienne-tablicowe-fakty-i-mity.aspx


*/