
--Statistics details

USE AdventureWorks2012;
go
DBCC SHOW_STATISTICS ('Person.Person', 'IX_Person_LastName_FirstName_MiddleName');
go

--Backup to 1 file

BACKUP DATABASE [AdventureWorks2012] 
TO  DISK = N'E:\TEST\AdventureWorks2012.bak' 
WITH FORMAT, INIT,  
NAME = N'AdventureWorks2012-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

BACKUP LOG [AdventureWorks2012] 
TO  DISK = N'E:\TEST\AdventureWorks2012.trn' 
WITH FORMAT, INIT,  
NAME = N'AdventureWorks2012-Translog Backup', 
SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

--Backup to multiple files

BACKUP DATABASE [AdventureWorks2012] 
TO  DISK = N'E:\TEST\AdventureWorks2012_01.bak',
DISK = N'E:\TEST\AdventureWorks2012_02.bak',
DISK = N'E:\TEST\AdventureWorks2012_03.bak',
DISK = N'E:\TEST\AdventureWorks2012_04.bak' 
WITH FORMAT, INIT,  
NAME = N'AdventureWorks2012-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

--Mirrored backup


BACKUP DATABASE [AdventureWorks2012] 
TO  DISK = N'E:\TEST\AdventureWorks2012_1.bak' 
MIRROR TO DISK = N'E:\TEST\AdventureWorks2012_2.bak'
WITH FORMAT, INIT,  
NAME = N'AdventureWorks2012-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO


--Backup to 1 file with options

BACKUP DATABASE [AdventureWorks2012] 
TO  DISK = N'E:\TEST\AdventureWorks2012.bak' 
WITH FORMAT, INIT,  
NAME = N'AdventureWorks2012-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD, STATS = 10
-- Magic: 
,BUFFERCOUNT = 100
,BLOCKSIZE = 65536
,MAXTRANSFERSIZE=2097152 

GO

--Backup to multiple files with options

BACKUP DATABASE [AdventureWorks2012] 
TO  DISK = N'E:\TEST\AdventureWorks2012_01.bak',
DISK = N'E:\TEST\AdventureWorks2012_02.bak',
DISK = N'E:\TEST\AdventureWorks2012_03.bak',
DISK = N'E:\TEST\AdventureWorks2012_04.bak' 
WITH FORMAT, INIT,  
NAME = N'AdventureWorks2012-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD,  STATS = 10
-- Magic: 
,BUFFERCOUNT = 100
,BLOCKSIZE = 65536
,MAXTRANSFERSIZE=2097152 
GO


--Drop DB
USE [master]
GO
DROP DATABASE [AdventureWorks2012]
GO

--Restore DB

RESTORE DATABASE AdventureWorks2012
FROM DISK = 'E:\TEST\AdventureWorks2012.bak'
WITH RECOVERY;

--Drop DB
USE [master]
GO
DROP DATABASE [AdventureWorks2012]
GO

RESTORE DATABASE AdventureWorks2012
FROM DISK = 'E:\TEST\AdventureWorks2012.bak'
WITH NORECOVERY;

RESTORE LOG AdventureWorks2012
FROM DISK = 'E:\TEST\AdventureWorks2012.trn'
WITH RECOVERY;


-- DMVs
select * from sys.dm_os_wait_stats --Na co SQL czeka
select * from sys.dm_exec_requests -- Co sie wykonuje
select * from sys.dm_os_waiting_tasks -- Na co czekaja taski
select * from sys.dm_exec_query_stats --statystyki zapytania
select * from sys.dm_exec_sql_text(0x050005001014855180D8BA2D0200000001000000000000000000000000000000000000000000000000000000) -- text zapytania
select * from sys.dm_exec_query_plan ( 0x05000500AB59313FF0CA69EB0100000001000000000000000000000000000000000000000000000000000000 ) -- zapisany plan
sys.dm_db_stats_properties (object_id, stats_id) -- Statystyki

select top 100 *
from sys.dm_exec_query_stats qs
	cross apply sys.dm_exec_sql_text(qs.plan_handle) st
	cross apply sys.dm_exec_query_plan(qs.plan_handle)
order by total_logical_reads desc


--index fragmentation
DECLARE @DatabaseID int

SET @DatabaseID = DB_ID()

SELECT DB_NAME(@DatabaseID) AS DatabaseName,
       schemas.[name] AS SchemaName,
       objects.[name] AS ObjectName,
       indexes.[name] AS IndexName,
       objects.type_desc AS ObjectType,
       indexes.type_desc AS IndexType,
       dm_db_index_physical_stats.partition_number AS PartitionNumber,
       dm_db_index_physical_stats.page_count AS [PageCount],
       dm_db_index_physical_stats.avg_fragmentation_in_percent AS AvgFragmentationInPercent
FROM sys.dm_db_index_physical_stats (@DatabaseID, NULL, NULL, NULL, 'LIMITED') dm_db_index_physical_stats
INNER JOIN sys.indexes indexes ON dm_db_index_physical_stats.[object_id] = indexes.[object_id] AND dm_db_index_physical_stats.index_id = indexes.index_id
INNER JOIN sys.objects objects ON indexes.[object_id] = objects.[object_id]
INNER JOIN sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id]
WHERE objects.[type] IN('U','V')
AND objects.is_ms_shipped = 0
AND indexes.[type] IN(1,2,3,4)
AND indexes.is_disabled = 0
AND indexes.is_hypothetical = 0
AND dm_db_index_physical_stats.alloc_unit_type_desc = 'IN_ROW_DATA'
AND dm_db_index_physical_stats.page_count >= 1000


