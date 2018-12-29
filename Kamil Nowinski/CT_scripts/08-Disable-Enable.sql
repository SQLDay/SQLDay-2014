USE ChangeTracking
GO

---------------------------------------------
-- Co siê stanie gdy wy³¹czymy œledzenie?
---------------------------------------------
ALTER TABLE [dbo].[Person]
DISABLE CHANGE_TRACKING
---------------------------------------------
SELECT * FROM CHANGETABLE(CHANGES [dbo].[Person], 0) AS C 
--Msg 22105, Level 16, State 1, Line 1
--Change tracking is not enabled on table 'dbo.Person'.

SELECT CHANGE_TRACKING_CURRENT_VERSION()



---------------------------------------------
-- Czy dotychczasowe zmiany s¹ zachowane? SprawdŸmy.
---------------------------------------------
ALTER TABLE [dbo].[Person]
ENABLE CHANGE_TRACKING
---------------------------------------------
SELECT * FROM CHANGETABLE(CHANGES [dbo].[Person], 0) AS C 
--0 rows
---------------------------------------------

SELECT 'MinValidVersion' as [Property], CHANGE_TRACKING_MIN_VALID_VERSION(OBJECT_ID('Person')) AS [Value] union all
SELECT 'CurrentVersion', CHANGE_TRACKING_CURRENT_VERSION()
GO
