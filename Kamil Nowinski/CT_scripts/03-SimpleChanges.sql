USE ChangeTracking
GO


--EXAMPLE 1: Delete one row from table.
--------------------------------------------------
DELETE FROM [dbo].[Person]
WHERE LastName ='Tamburello'
--------------------------------------------------

--Example 2: Insert one row into table
--------------------------------------------------
INSERT [dbo].[Person]  
VALUES (16, N'Zygfryd', N'Psikuta', N'090909090', N'adventure-works\zpsikuta', N'Research and Development Manager', CAST(0xB5FD0A00 AS Date), N'S')
--------------------------------------------------

--Example 3: Update one row in table
--------------------------------------------------
UPDATE [dbo].[Person]
SET JobTitle = 'Senior Tool Designer'
WHERE BusinessEntityID = 12
--------------------------------------------------


