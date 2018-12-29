drop database falconswilldestroyeagles
go
create database falconswilldestroyeagles
go
drop table youbetthecowboysdid
go
use falconswilldestroyeagles
go
create table pleasesackvick (gofalcons int, beateagles char(7000))
go
set nocount on
go
declare @x int
set @x = 0
while (@x < 500000)
begin
	insert into pleasesackvick values (@x, 'I do not like the Eagles')
	set @x = @x + 1
end
go
set nocount off
go