use master
go
drop database rangersalchampstwoinarow
go
create database rangersalchampstwoinarow
go
use rangersalchampstwoinarow
go
drop table beattheyankeesagain
go
create table beattheyankeesagain (rangersno1 int, rangersalltheway char(7000))
go
set nocount on
go
declare @x int
set @x = 0
while (@x < 100000)
begin
	insert into beattheyankeesagain values (@x, 'Josh and the boys')
	set @x = @x + 1
end
go
set nocount off
go