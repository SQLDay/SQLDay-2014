use master
go
drop database mavsnbachampsiwish
go
CREATE DATABASE [mavsnbachampsiwish] ON  PRIMARY 
( NAME = N'mavsnbachampsiwish', FILENAME = N'C:\temp\mavsnbachampsiwish.mdf' , SIZE = 200000KB , FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'mavsnbachampsiwish_log', FILENAME = N'C:\temp\mavsnbachampsiwish_log.ldf' , SIZE = 25000KB , FILEGROWTH = 10%)
GO
use mavsnbachampsiwish
go
drop table mytab
go
create table mytab (col1 int primary key clustered, col2 char(4000) not null)
go
set nocount on
go
declare @x int
set @x = 0
while (@x < 50000)
begin
	insert into mytab values (@x, 'x')
	set @x = @x + 1
end
go
set nocount off
go
drop proc tempproc
go
create proc tempproc @throttle int
as
select * into #x from mytab where col1 < @throttle
go