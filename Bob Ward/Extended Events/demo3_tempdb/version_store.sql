use master
go
drop database verstore
go
create database verstore
go
alter database verstore set read_committed_snapshot on
go
use verstore
go
drop table myver
go
create table myver (col1 int, col2 char(7000) not null)
go
set nocount on
go
declare @x int
set @x = 0
while (@x < 10000)
begin
	insert into myver values (@x, 'x')
	set @x = @x +1
end
go
set nocount off
go

update myver set col1 = 5
