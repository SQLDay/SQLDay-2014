use testqp
go
drop table mytab
go
create table mytab (col1 int, col2 char(7000) not null)
go
declare @x int
set @x = 0
while (@x < 1000)
begin
	insert into mytab values (@x, 'x')
	set @x = @x + 1
end
go
drop table mytab2
go
create table mytab2 (col1 char(5) primary key clustered, col2 char(7000) not null)
go
declare @x int
set @x = 0
while (@x < 1000)
begin
	insert into mytab2 values (cast(@x as char(5)), 'x')
	set @x = @x + 1
end
go


create table t (c1 char(10))
go
create index ix on t(c1)
go
set statistics profile on
go
select * from t where c1 = 1
