use willthecowboysevermakeitbacktothesuperbowl
go
begin tran
select * from wishwehadrgiii with (holdlock)
go
--We should block here. Now go back and run the other delete in deadlock_1.sql
delete from shouldwehavegivenromoanextension

rollback tran

