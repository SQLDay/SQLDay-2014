USE StageV1
GO

SELECT COUNT([CustomerBusinessKey])
FROM [dbo].[DimCustomersDups];

SELECT COUNT (DISTINCT [CustomerBusinessKey])
FROM [dbo].[DimCustomersDups];

--Show Execution Plan
/*
SELECT DISTINCT *
FROM [dbo].[DimCustomersDups];
/*