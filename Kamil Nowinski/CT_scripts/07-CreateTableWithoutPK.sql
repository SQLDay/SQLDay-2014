USE ChangeTracking
GO


------------------------------------------------------------------------
-- Dzia³anie na tabeli bez klucza g³ównego
------------------------------------------------------------------------
CREATE TABLE [dbo].[PersonWithoutPK]
(
	[BusinessEntityID] [int] NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[NationalIDNumber] [nvarchar](15) NOT NULL,
	[LoginID] [nvarchar](256) NOT NULL,
	[JobTitle] [nvarchar](50) NOT NULL,
	[BirthDate] [date] NOT NULL,
	[MaritalStatus] [nchar](1) NOT NULL
)
GO

---------------------------------------------
ALTER TABLE [dbo].[PersonWithoutPK]
ENABLE CHANGE_TRACKING
--------------------------------------------- 














--Msg 4997, Level 16, State 1, Line 1
--Cannot enable change tracking on table 'PersonWithoutPK'. 
--Change tracking requires a primary key on the table. Create a primary key on the table before enabling change tracking.

--The secret is: we CAN ENABLE CT on a table when table is having Primary Key on it. Otherwise we can’t enable CT.


