use master
go
drop database bearswinthebig12
go
create database bearswinthebig12
go
use bearswinthebig12
go
declare @x int
declare @y varchar(1000)
declare @z varchar(1000)
set @x = 0
while (@x < 10000)
begin
	set @y = 'create procedure myproc'+cast(@x as varchar(50))+' as declare @x int set @x = 1'
	--select @y
	exec (@y)
	set @z = 'exec myproc'+cast(@x as varchar(50))
	exec (@z)
	set @x = @x + 1
end
go