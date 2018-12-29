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
