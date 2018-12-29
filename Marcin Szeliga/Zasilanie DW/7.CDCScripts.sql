UPDATE dest
SET    
	dest.FirstName = stg.FirstName,    
	dest.LastName = stg.LastName,    
	dest.Title = stg.Title,
	dest.BirthDate = stg.BirthDate,
	dest.EnglishEducation = stg.EnglishEducation,
	dest.Phone = stg.Phone
FROM    
	[DimCustomer_Destination] dest,    
	[stg_DimCustomer_UPDATES] stg
WHERE    
	stg.[CustomerBusinessKey] = dest.[CustomerBusinessKey];



DELETE FROM [DimCustomer_Destination]  
WHERE [CustomerBusinessKey] 
	IN(    
		SELECT [CustomerBusinessKey]    
		FROM [dbo].[stg_DimCustomer_DELETES]
		);

TRUNCATE TABLE stg_DimCustomer_UPDATES   
TRUNCATE TABLE stg_DimCustomer_DELETES   