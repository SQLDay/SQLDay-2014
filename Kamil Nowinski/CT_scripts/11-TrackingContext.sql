USE ChangeTracking
GO


---------------------------------------------
--  WITH CHANGE_TRACKING_CONTEXT() 
---------------------------------------------
SELECT * FROM dbo.Person;

DECLARE @originator_id varbinary(128) = CAST('SQLDay' AS varbinary(128));
WITH CHANGE_TRACKING_CONTEXT (@originator_id)
UPDATE dbo.Person
SET BirthDate = '1965-01-09'
WHERE BusinessEntityID = 2;

UPDATE dbo.Person
SET BirthDate = '1965-01-09'
WHERE BusinessEntityID = 8;



SELECT @originator_id;

SELECT * FROM CHANGETABLE(CHANGES [dbo].[Person], 0) AS C 
GO

SELECT C.*, CAST(C.SYS_CHANGE_CONTEXT AS VARCHAR(100)) AS MyContext
FROM CHANGETABLE(CHANGES [dbo].[Person], 0) AS C 




