-- is the dstabase online?
--
select state_desc from sys.databases where name = 'thenbaplayoffs'
go
-- Well the database is online. I need to truncate out the whowillwin table
-- Huh? Who is blocking me. Load up whatisgoingon.sql to find out.
use thenbaplayoffs
go
begin tran
truncate table whowillwin
go
-- Let's roll it back and see what is in the table
-- Empty no one knows. Probably the Mavericks.
--
rollback tran
go
select * from whowillwin
go