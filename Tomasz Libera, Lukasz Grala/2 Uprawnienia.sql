/*

 T-SQL Security Enhancements
 
*/



/*
  
  2A 

*/

-- USE tempdb
-- DROP DATABASE Salaries
CREATE DATABASE Salaries
GO

USE Salaries
GO

CREATE TABLE dbo.Employees (
	ID int identity PRIMARY KEY,
	Name nvarchar(50) NULL,
	Salary money NULL
) 
GO

INSERT INTO Employees (Name, Salary)
     VALUES ('Kamiñski',12000)
GO

INSERT INTO Employees(Name, Salary)
     VALUES ('Zieliñski', 15000)
GO

SELECT * FROM Employees
GO



USE master
GO

CREATE LOGIN Nowak WITH PASSWORD = 'Pa$$w0rd'
GO


GRANT CONTROL SERVER to Nowak
GO
DENY SELECT ALL USER SECURABLES to Nowak -- SQL Server 2014
GO




-- as Nowak

USE Salaries
GO

SELECT * FROM Employees
GO

SELECT * FROM sys.tables

INSERT INTO Employees(Name, Salary) VALUES ('Nowak',50000)
GO

SELECT * FROM AdventureWorks2012.Person.Person
GO




USE msdb
GO
SELECT * FROM dbo.backupset
GO


USE master
GO 
GRANT SELECT ALL USER SECURABLES TO Nowak -- failed
GO
-- as sysadmin:  DENY ALTER ANY LOGIN TO Nowak



-- test restore database -> this should succeed
BACKUP DATABASE Salaries
TO DISK = 'D:\SQLServer_BACKUP\SalariesDatabase.bak'
WITH FORMAT, INIT, STATS=10
GO

-- test restore database -> this should succeed (but not using SSMS)
USE [master]
DROP DATABASE Salaries
RESTORE DATABASE Salaries 
FROM  DISK = N'D:\SQLServer_BACKUP\SalariesDatabase.bak' WITH  FILE = 1, REPLACE
GO


SELECT * FROM Salaries.dbo.Employees -- permission was denied 



-- SSMS problems...




/*
  
  2B 

*/

-- as sa
CREATE LOGIN Kowalski WITH PASSWORD = 'Pa$$w0rd'
GO


GRANT CONNECT ANY DATABASE to Kowalski
GO
GRANT SELECT ALL USER SECURABLES to Kowalski
GO


-- as Kowalski (SSMS)







/*
  
  Cleanup 

*/

DROP LOGIN Nowak
GO
DROP LOGIN Kowalski
GO


DROP DATABASE Salaries
GO





/*
 
  LINKS

  David Barbarin - SELECT ALL USERS SECURABLES & DB admins
  http://www.dbi-services.com/index.php/blog/entry/sql-server-2014-select-all-users-securables-a-db-admins

  Biz Nigatu - SQL Server 2014 new Server Roles
  http://blog.dbandbi.com/tag/select-all-user-securables/

  What's new in SQL Server 2014? Is it worth the upgrade?
  http://www.mssqltips.com/sqlservertip/3120/whats-new-in-sql-server-2014-is-it-worth-the-upgrade/


*/