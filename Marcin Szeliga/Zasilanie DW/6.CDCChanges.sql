USE StageV1
GO

DELETE FROM DimCustomer_CDC
WHERE [CustomerBusinessKey]  IN (11480, 11501);
GO

UPDATE DimCustomer_CDC
SET  [EnglishEducation]   = UPPER([EnglishEducation])
WHERE  [CustomerBusinessKey] >= 11498  AND [CustomerBusinessKey] < 11503
GO

INSERT INTO DimCustomer_CDC
SELECT *
FROM [dbo].[DimCustomers]
WHERE [CustomerBusinessKey] >= 15200  AND [CustomerBusinessKey] < 15210
GO
