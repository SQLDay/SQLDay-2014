use master
go
drop database rangerstotheworldseriesagain
go
create database rangerstotheworldseriesagain
go
use rangerstotheworldseriesagain
go
drop table canwewinwithoutjosh
go
create table canwewinwithoutjosh (answer int, description char(4000) not null)
go
set nocount on
go
declare @x int
set @x = 0
while (@x < 100000)
begin
	insert into canwewinwithoutjosh values (@x, 'Yes we can')
	set @x = @x + 1
end
set nocount off
go