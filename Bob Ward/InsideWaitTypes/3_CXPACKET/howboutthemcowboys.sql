drop database whenwillthecowboysevermakeitbacktothesuperbowl
go
create database whenwillthecowboysevermakeitbacktothesuperbowl
go
use whenwillthecowboysevermakeitbacktothesuperbowl
go
drop table arethecowboysmediocre
go
create table arethecowboysmediocre (tabkey char(10) primary key clustered, answer char (7000) not null)
go
set nocount on
go
declare @x int
set @x = 0
while (@x < 1000000)
begin
	insert into arethecowboysmediocre values (cast(@x as char(10)), 'Yes we are')
	set @x = @x + 1
end
set nocount off
go