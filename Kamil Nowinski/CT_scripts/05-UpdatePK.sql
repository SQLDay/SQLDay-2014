USE ChangeTracking
GO


--------------------------------------------------
-- In the above example, we updated Non Primary Key column. 
-- But when we update non Primary key column, CT works differently compare to when we update Primary key column. 
--------------------------------------------
UPDATE [dbo].[Person]
SET BusinessEntityID = 999
WHERE BusinessEntityID = 7
--------------------------------------------
SELECT * FROM CHANGETABLE(CHANGES Person, 0) AS P
ORDER BY SYS_CHANGE_VERSION -- 6 rows! (+2)
----------------------------------------------------------------


------------------------------------------------------------------------
-- Pe³na informacja o tabeli - tylko zmienione wiersze, ale bie¿¹ce (nieusuniête!)
------------------------------------------------------------------------
SELECT * FROM CHANGETABLE(CHANGES [dbo].[Person], 0) AS P
INNER JOIN [dbo].[Person] AS P ON P.BusinessEntityID = C.BusinessEntityID
------------------------------------------------------------------------

