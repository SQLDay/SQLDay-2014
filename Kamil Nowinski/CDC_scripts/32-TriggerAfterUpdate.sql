USE CDC_SQLDay2014
GO

IF OBJECT_ID ('dbo.utDimPerson','TR') IS NOT NULL
   DROP TRIGGER dbo.utDimPerson 
GO

CREATE TRIGGER dbo.utDimPerson ON  dbo.DimPerson  AFTER INSERT
AS 

	UPDATE dbo.DimPerson 
	SET EndDate = inserted.ModifiedDate FROM inserted 
	--WHERE dbo.DimPerson.BusinessEntityID = inserted.BusinessEntityID --and dbo.DimPerson.ID < inserted.ID
	--AND  dbo.DimPerson.ID < (SELECT Max(ID) FROM dbo.DimPerson WHERE BusinessEntityID = inserted.BusinessEntityID)

	DECLARE @rc int = @@ROWCOUNT;
	INSERT INTO dbo.SysLog (TS, opis) 
	SELECT GETDATE(),  'Inserted-ID = ' + cast(inserted.ID as varchar(8)) + ' | cnt:' + cast(@rc as varchar(8))
	FROM inserted;

GO

