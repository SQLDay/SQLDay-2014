USE ChangeTracking
GO


--List of functions used in CT:
/*
CHANGETABLE()   
CHANGE_TRACKING_CURRENT_VERSION()   
CHANGE_TRACKING_MIN_VALID_VERSION()
CHANGE_TRACKING_IS_COLUMN_IN_MASK()   
WITH CHANGE_TRACKING_CONTEXT() 
*/

--Current changes:
select * from CHANGETABLE(CHANGES[dbo].[Person], 0) as P
select CHANGE_TRACKING_CURRENT_VERSION()

SELECT CHANGE_TRACKING_MIN_VALID_VERSION(OBJECT_ID('Person')) AS MinValidVersion


--------------------------------------------------

--select CHANGE_TRACKING_IS_COLUMN_IN_MASK(2, 'Person')
--http://technet.microsoft.com/pl-pl/library/bb895238.aspx

--------------------------------------------------


--------------------------------------------------
-- Odczytanie Kolejnoœci zmian:
--------------------------------------------------
SELECT SYS_CHANGE_VERSION, SYS_CHANGE_OPERATION, BusinessEntityID
FROM CHANGETABLE(CHANGES [dbo].[Person], 0) 
ORDER BY SYS_CHANGE_VERSION
--Note: Aliasing is mandatory while using CHANGETABLE. If you run the below statement, it will throw the error.

SELECT SYS_CHANGE_VERSION, SYS_CHANGE_OPERATION, BusinessEntityID
FROM CHANGETABLE(CHANGES [dbo].[Person], 0) as P
ORDER BY SYS_CHANGE_VERSION

--------------------------------------------------
-- Jeszcze jeden UPDATE
--------------------------------------------------
UPDATE [dbo].[Person]
SET LastName ='Sánchez' WHERE LastName ='Duffy';


SELECT * FROM CHANGETABLE(CHANGES [dbo].[Person], 0) AS P
ORDER BY SYS_CHANGE_VERSION

