USE ChangeTracking
GO

---------------------------------------------
-- Jak zachowa siê tabela œledzenia gdy usuniemy dane za pomoc¹ TRUNCATE?
---------------------------------------------
TRUNCATE TABLE dbo.Person;
---------------------------------------------
SELECT * FROM CHANGETABLE(CHANGES [dbo].[Person], 0) AS C 
---------------------------------------------
--OdpowiedŸ
--0 rows!
--TRUNCATE nie jest operacj¹ DML - czyli jedn¹ z tych, które œledzimy.


SELECT 'MinValidVersion' as [Property], CHANGE_TRACKING_MIN_VALID_VERSION(OBJECT_ID('Person')) AS [Value] union all
SELECT 'CurrentVersion', CHANGE_TRACKING_CURRENT_VERSION()
GO
