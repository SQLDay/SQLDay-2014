USE ChangeTracking
GO


------------------------------------------------------------------------
-- CHANGETABLE (VERSION)
------------------------------------------------------------------------
SELECT * FROM CHANGETABLE (VERSION [dbo].[Person], ([BusinessEntityID]), (12) ) AS c;
GO

-- Get all current rows with associated version
SELECT p.[BusinessEntityID], p.[FirstName], p.[LastName],
    c.SYS_CHANGE_VERSION, c.SYS_CHANGE_CONTEXT
FROM [dbo].[Person] AS p
CROSS APPLY CHANGETABLE 
    (VERSION [dbo].[Person], ([BusinessEntityID]), (p.[BusinessEntityID])) AS c;
GO

