USE ChangeTracking
GO

---------------------------------------------
-- Jak zachowa si� tabela �ledzenia gdy usuniemy dane za pomoc� TRUNCATE?
---------------------------------------------
TRUNCATE TABLE dbo.Person;
---------------------------------------------
SELECT * FROM CHANGETABLE(CHANGES [dbo].[Person], 0) AS C 
---------------------------------------------
--Odpowied�
--0 rows!
--TRUNCATE nie jest operacj� DML - czyli jedn� z tych, kt�re �ledzimy.


SELECT 'MinValidVersion' as [Property], CHANGE_TRACKING_MIN_VALID_VERSION(OBJECT_ID('Person')) AS [Value] union all
SELECT 'CurrentVersion', CHANGE_TRACKING_CURRENT_VERSION()
GO
