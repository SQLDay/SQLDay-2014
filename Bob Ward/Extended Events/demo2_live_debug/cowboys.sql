use master
go
drop database willthecowboysevermakeitbacktothesuperbowl
go
create database willthecowboysevermakeitbacktothesuperbowl
go
use willthecowboysevermakeitbacktothesuperbowl
go
drop table canwewinwithromo
go
create table canwewinwithromo (col1 int primary key clustered, col2 char(5000) not null)
go
set nocount on
go
declare @x int
set @x = 0
while (@x < 100000)
begin
	insert into canwewinwithromo values (@x, 'Probaably not')
	set @x = @x + 1
end
go
set nocount off
go
drop table cowboys_players
go
create table cowboys_players (col1 int, player_name char(100))
go
declare @x int
set @x = 0
while (@x < 10)
begin
	insert into cowboys_players values (@x, 'player')
	set @x = @x + 1
end
go
select count(*) from canwewinwithromo
go
