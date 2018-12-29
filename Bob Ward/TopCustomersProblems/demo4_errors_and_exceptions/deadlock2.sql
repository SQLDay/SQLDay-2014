use mavsnbachampsiwish
go
begin tran
select * from mytab2 with (holdlock)
go
--- go back to deadlock1.sql and run the delete after teh comments
--- and then come back here and run this delete
delete from mytab
go