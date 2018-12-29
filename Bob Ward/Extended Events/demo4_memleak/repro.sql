use tempdb
go
if object_id ('p_inner') is not null drop procedure p_inner
go
CREATE PROCEDURE dbo.p_inner
@TableName sysname --,
--@ScriptTableName sysname
AS
exec ('
declare C CURSOR FOR SELECT Script FROM ' + @TableName + '
order by OrderID
OPEN C
CLOSE C
DEALLOCATE C'
)
go
if object_id ('p_outer') is not null drop procedure p_outer
go
create procedure p_outer
as
CREATE TABLE #Final(OrderID INT IDENTITY(1, 1), Script nvarchar(3000))
--CREATE TABLE #FinalScript(Script NTEXT)
EXEC p_inner '#Final' --, '#FinalScript'
drop table #Final
--drop table #FinalScript
go

dbcc freeproccache
dbcc freesystemcache('ALL')
set nocount on
go
select type, sum(pages_in_bytes) 'page_in_bytes' from sys.dm_os_memory_objects
where type = 'MEMOBJ_EXECCOMPILETEMP'
group by type
go
exec p_outer
go
--note that there will be 8192 bytes increase for MEMOBJ_EXECCOMPILETEMP
select type, sum(pages_in_bytes) 'page_in_bytes' from sys.dm_os_memory_objects
where type = 'MEMOBJ_EXECCOMPILETEMP'
group by type
　
 
 
repro 2
 
1)restore attached database ScaSystemDB
2)  run  the following procedure

select type, sum(pages_in_bytes) 'page_in_bytes' from sys.dm_os_memory_objects
where type = 'MEMOBJ_EXECCOMPILETEMP'
group by type
 
go
 
exec sca_GetObjectScript N'MA06',N'F0',0,0
 
go
 

select type, sum(pages_in_bytes) 'page_in_bytes' from sys.dm_os_memory_objects
where type = 'MEMOBJ_EXECCOMPILETEMP'
group by type
3)  note MEMOBJ_EXECCOMPILETEMP will go up 8192 bytes for every execution of the procedure
 
