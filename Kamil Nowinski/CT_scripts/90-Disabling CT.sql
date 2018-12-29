USE ChangeTracking
GO


---------------------------------------------
-- Wy³¹czanie
---------------------------------------------

-- Najpierw - Wy³¹czenie mechanizmu dla tabel
SELECT 'ALTER TABLE [' + SCHEMA_NAME(O.schema_id) + '].[' + object_name(CTT.object_id) + '] DISABLE CHANGE_TRACKING;'
FROM sys.change_tracking_tables CTT 
INNER JOIN sys.objects O on O.object_id = CTT.object_id

--
ALTER TABLE [dbo].[Person] DISABLE CHANGE_TRACKING;



--Wy³¹czenie mechanizmu dla bazy danych
ALTER DATABASE ChangeTracking SET CHANGE_TRACKING = OFF


