USE ChangeTracking
GO

-----------------------------------------------
-- Œledzenie WITH (TRACK_COLUMNS_UPDATED = ON)
-----------------------------------------------
ALTER TABLE [dbo].[Person]
DISABLE CHANGE_TRACKING
GO

TRUNCATE TABLE dbo.Person
GO
---------------------------------------------------------------
-- Insert 14 records into [dbo].[Person] table
---------------------------------------------------------------
BEGIN TRANSACTION [CT]
 BEGIN TRY
INSERT [dbo].[Person]  VALUES (1, N'Ken', N'Sánchez', N'295847284', N'adventure-works\ken0', N'Chief Executive Officer', CAST(0x79EF0A00 AS Date), N'S')
INSERT [dbo].[Person]  VALUES (2, N'Terri', N'Duffy', N'245797967', N'adventure-works\terri0', N'Vice President of Engineering', CAST(0x0BF30A00 AS Date), N'S')
INSERT [dbo].[Person]  VALUES (3, N'Roberto', N'Tamburello', N'509647174', N'adventure-works\roberto0', N'Engineering Manager', CAST(0xBAF70A00 AS Date), N'M')
INSERT [dbo].[Person]  VALUES (4, N'Rob', N'Walters', N'112457891', N'adventure-works\rob0', N'Senior Tool Designer', CAST(0xE3F70A00 AS Date), N'S')
INSERT [dbo].[Person]  VALUES (5, N'Gail', N'Erickson', N'695256908', N'adventure-works\gail0', N'Design Engineer', CAST(0x29D80A00 AS Date), N'M')
INSERT [dbo].[Person]  VALUES (6, N'Jossef', N'Goldberg', N'998320692', N'adventure-works\jossef0', N'Design Engineer', CAST(0x5DE10A00 AS Date), N'M')
INSERT [dbo].[Person]  VALUES (7, N'Dylan', N'Miller', N'134969118', N'adventure-works\dylan0', N'Research and Development Manager', CAST(0x41090B00 AS Date), N'M')
INSERT [dbo].[Person]  VALUES (8, N'Diane', N'Margheim', N'811994146', N'adventure-works\diane1', N'Research and Development Engineer', CAST(0x39080B00 AS Date), N'S')
INSERT [dbo].[Person]  VALUES (9, N'Gigi', N'Matthew', N'658797903', N'adventure-works\gigi0', N'Research and Development Engineer', CAST(0xB5FD0A00 AS Date), N'M')
INSERT [dbo].[Person]  VALUES (10, N'Michael', N'Raheem', N'879342154', N'adventure-works\michael6', N'Research and Development Manager', CAST(0x11060B00 AS Date), N'M')
INSERT [dbo].[Person]  VALUES (11, N'Ovidiu', N'Cracium', N'974026903', N'adventure-works\ovidiu0', N'Senior Tool Designer', CAST(0x44FC0A00 AS Date), N'S')
INSERT [dbo].[Person]  VALUES (12, N'Thierry', N'D''Hers', N'480168528', N'adventure-works\thierry0', N'Tool Designer', CAST(0xE9E10A00 AS Date), N'M')
INSERT [dbo].[Person]  VALUES (13, N'Janice', N'Galvin', N'486228782', N'adventure-works\janice0', N'Tool Designer', CAST(0x790C0B00 AS Date), N'M')
INSERT [dbo].[Person]  VALUES (14, N'Michael', N'Sullivan', N'42487730', N'adventure-works\michael8', N'Senior Design Engineer', CAST(0x47FE0A00 AS Date), N'S')
COMMIT TRANSACTION [CT]
 END TRY
BEGIN CATCH
ROLLBACK TRANSACTION [CT]
END CATCH
GO




ALTER TABLE [dbo].[Person]        -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ENABLE CHANGE_TRACKING				WITH (TRACK_COLUMNS_UPDATED = ON)
GO

-------------------------------------------------------------
SELECT * FROM [dbo].[Person] WHERE BusinessEntityID = 2;
UPDATE [dbo].[Person]
SET LastName ='Duffy', MaritalStatus = 'M'
WHERE BusinessEntityID = 2;
-------------------------------------------------------------
SELECT * FROM CHANGETABLE(CHANGES [dbo].[Person], 0) AS C 
-------------------------------------------------------------
SELECT * FROM [dbo].[Person]
-------------------------------------------------------------
-- JAK CZYTAÆ KOLUMNÊ SYS_CHANGE_COLUMNS ?
-------------------------------------------------------------
select CHANGE_TRACKING_IS_COLUMN_IN_MASK(7, 0x000000000300000008000000)
--LUB
SELECT name, CHANGE_TRACKING_IS_COLUMN_IN_MASK(column_id, 0x000000000300000008000000) as IsColumnChanged
FROM sys.columns where object_id = OBJECT_ID('dbo.Person')
GO

--W przypadku operacji INSERT - kolumna SYS_CHANGE_COLUMNS zawiera NULL
