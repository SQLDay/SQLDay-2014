use mavsnbachampsiwish
go
begin tran
select * from mytab with (holdlock)
go
--- go run up to comment in deadlock2.sql
--- and then come back here
delete from mytab2
go

rollback tran