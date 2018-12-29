USE ChangeTracking
GO


---------------------------------------------
-- Co siê stanie gdy zmieni siê kolumna PK?
---------------------------------------------

-- 1. Create new ROWGUID column with newID() function
-- 2. Remove PK & create new PK

BEGIN TRANSACTION

ALTER TABLE dbo.Person 
ADD [Guid] uniqueidentifier NOT NULL CONSTRAINT DF_Person_Guid DEFAULT (NEWID())

ALTER TABLE dbo.Person 
DROP CONSTRAINT PK_Person

ALTER TABLE dbo.Person 
ADD CONSTRAINT PK_Person PRIMARY KEY CLUSTERED ([Guid])

IF @@ERROR > 0 
	ROLLBACK TRANSACTION
ELSE
	COMMIT TRANSACTION
GO











/*
'Person' table
- Unable to delete index 'PK_Person'.  
The primary key constraint 'PK_Person' on table 'Person' cannot be dropped because change tracking is enabled on the table. 
Change tracking requires a primary key constraint on the table. Disable change tracking before dropping the constraint.
Could not drop constraint. See previous errors.
*/



