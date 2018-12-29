USE [CDC_SQLDay2014]
GO

MERGE INTO CDC_SQLDay2014.dbo.DimPersonStage AS tgt
USING dbo.DimPersonStage AS src
ON (tgt.BusinessEntityID=src.BusinessEntityID)
WHEN MATCHED THEN 
	begin
		UPDATE SET
		tgt.PersonType=src.PersonType, tgt.NameStyle=src.NameStyle, tgt.Title=src.Title, tgt.FirstName=src.FirstName, tgt.MiddleName=src.MiddleName, tgt.LastName=src.LastName, tgt.Suffix=src.Suffix, tgt.EmailPromotion=src.EmailPromotion, tgt.rowguid=src.rowguid, tgt.ModifiedDate=src.ModifiedDate, tgt.StartDate=src.StartDate, tgt.EndDate=src.ModifiedDate
	--!!!!!!!!!!!!!!!!!!!!!!!!!
		INSERT (BusinessEntityID, PersonType, NameStyle, Title, FirstName, MiddleName, LastName, Suffix, EmailPromotion, rowguid, ModifiedDate, StartDate, EndDate)
		VALUES (src.BusinessEntityID, src.PersonType, src.NameStyle, src.Title, src.FirstName, src.MiddleName, src.LastName, src.Suffix, src.EmailPromotion, src.rowguid, src.ModifiedDate, src.ModifiedDate, null);
	--!!!!!!!!!!!!!!!!!!!!!!!!!
	end
WHEN NOT MATCHED THEN 
	INSERT (BusinessEntityID, PersonType, NameStyle, Title, FirstName, MiddleName, LastName, Suffix, EmailPromotion, rowguid, ModifiedDate, StartDate, EndDate)
	VALUES (src.BusinessEntityID, src.PersonType, src.NameStyle, src.Title, src.FirstName, src.MiddleName, src.LastName, src.Suffix, src.EmailPromotion, src.rowguid, src.ModifiedDate, src.ModifiedDate, null);
