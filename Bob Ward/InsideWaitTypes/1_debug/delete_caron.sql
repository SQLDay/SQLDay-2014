use mavstothenbafinals
go
set transaction isolation level serializable
go
begin tran
delete from themavsstarters where name = 'Caron Butler'
go



