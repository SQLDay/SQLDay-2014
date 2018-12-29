USE ChangeTracking
GO

----------------------------------------------------
-- Enabling CT on our database
----------------------------------------------------
USE [master]
GO
ALTER DATABASE [ChangeTracking] SET CHANGE_TRACKING = ON (AUTO_CLEANUP = OFF)
GO


----------------------------------------------------
-- Enabling the CT for our table
----------------------------------------------------
USE ChangeTracking
GO
ALTER TABLE [dbo].[Person] 
ENABLE CHANGE_TRACKING				WITH (TRACK_COLUMNS_UPDATED = OFF)
GO
----------------------------------------------------------
--TRACK_COLUMNS_UPDATED: This parameter is used to indicate the columns which are changed by UPDATE operation and also indicates that row has changed. By default, it is OFF. 


----------------------------------------------------
-- DMV: Information about databases with CT ON
----------------------------------------------------
SELECT * FROM sys.change_tracking_databases 
SELECT * FROM sys.change_tracking_tables
SELECT * FROM sys.internal_tables WHERE parent_object_id = OBJECT_ID('Person')


select o.name, o.type, o.type_desc from sys.objects o where o.type <> 'S';
select o.name, o.type, o.type_desc from sys.objects o where o.name like 'change_tracking%';
select o.object_id, o.name, o.type, o.type_desc from sys.objects o where o.name like 'Person';

