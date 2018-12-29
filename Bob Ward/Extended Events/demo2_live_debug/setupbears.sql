use master
go
drop database baylortothefinalfour
go
create database baylortothefinalfour
go
use baylortothefinalfour
go
drop table bears_march_madness
go
create table bears_march_madness (baylor_score bigint, visitor_score bigint, 
visitor_team varchar(100),
leading_scorer char(5000) not null)
go
set nocount on
go
declare @x int
declare @rnd int
declare @betterrnd int
set @x = 0
while (@x < 1000000)
begin
	set @rnd = RAND(@x)
	set @betterrnd = RAND(@x)*1000
	insert into bears_march_madness values (@betterrnd, @rnd, 'Who Cares', 'The Top Scorer')
	set @x = @x + 1
end
set nocount off
go