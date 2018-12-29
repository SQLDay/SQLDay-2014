USE ChangeTracking
GO

---------------------------------------------
-- Wiêksza liczba operacji 
---------------------------------------------
UPDATE [Person]
set LastName = LastName
GO 10

---------------------------------------------
SELECT * FROM CHANGETABLE(CHANGES [dbo].[Person], 0) AS C 
---------------------------------------------
--14 rows, but not 14x10!

UPDATE [Person]
set FirstName = LastName
where BusinessEntityID = 5

---------------------------------------------
SELECT * FROM CHANGETABLE(CHANGES [dbo].[Person], 0) AS C 
---------------------------------------------

delete from person
where BusinessEntityID = 5

---------------------------------------------
SELECT * FROM CHANGETABLE(CHANGES [dbo].[Person], 0) AS C 
---------------------------------------------




TRUNCATE TABLE [dbo].[Person]
---------------------------------------------
SELECT * FROM CHANGETABLE(CHANGES [dbo].[Person], 0) AS C 
---------------------------------------------
SELECT 'MinValidVersion' as [Property], CHANGE_TRACKING_MIN_VALID_VERSION(OBJECT_ID('Person')) AS [Value] union all
SELECT 'CurrentVersion', CHANGE_TRACKING_CURRENT_VERSION()
