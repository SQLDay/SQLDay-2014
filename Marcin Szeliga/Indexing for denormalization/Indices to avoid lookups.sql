USE Indices
GO

--Show execution plan
SELECT P.[Name], COUNT(OD.[SalesOrderID]) as Orders
FROM [dbo].[Product] P
JOIN [dbo].[SalesOrderDetail] OD
	ON P.[ProductID]=OD.ProductID
WHERE OD.LineTotal IS NOT NULL
GROUP BY P.[Name]
GO

CREATE FUNCTION udfOrdersLookup (@ProductID int)
RETURNS money
WITH SCHEMABINDING
AS
BEGIN
RETURN (
	SELECT COUNT([SalesOrderID])
	FROM [dbo].[SalesOrderDetail] 
	WHERE ProductID = @ProductID);
END
GO

ALTER TABLE [dbo].[Product]
ADD Orders AS dbo.udfOrdersLookup(ProductID);
GO

SELECT COLUMNPROPERTY (OBJECT_ID('Product'), 'Orders','IsDeterministic'); 
SELECT COLUMNPROPERTY (OBJECT_ID('Product'), 'Orders','IsIndexable') ; 

CREATE INDEX idx on Product(Orders);
GO

