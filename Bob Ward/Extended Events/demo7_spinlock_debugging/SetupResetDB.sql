use master
go

drop database ResetTestDB
go
create database ResetTestDB
go
alter database ResetTestDB set recovery simple
go

backup database ResetTestDB to disk = 'nul'
go

use ResetTestDB
go

/*
	Remote database
	
	create table tblTest(iID int)

	create procedure spTest
	as
	begin
		select * from tblTest
	end
*/

create table tblTest(iID int)
go
create procedure spTest
as
begin

	set REMOTE_PROC_TRANSACTIONS OFF		--	Avoid DTC

	insert into tblTest
		exec [LC2-7C01\RDORRSQL05].ChRobRemoteTest..spTest
end
go