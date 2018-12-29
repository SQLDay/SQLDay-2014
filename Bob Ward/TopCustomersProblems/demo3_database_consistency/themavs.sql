use master
go
drop database thenbaplayoffs
go
create database thenbaplayoffs
go
--
-- You have to backup the database in order to
-- take advantage of deferred transactions
--
use thenbaplayoffs
go
create table whowillwin (col1 int, col2 char(4000) not null)
go
insert into whowillwin values (1, 'Mavs will beat the Spurs')
go
checkpoint
go
backup database thenbaplayoffs to disk = 'C:\temp\thenbaplayoffs.bak' with init
go
begin tran
insert into whowillwin values (2, 'Go Mavs!')
go
--
-- Checkpoint the database. We will have a modified page for an uncommitted tran
-- that if the rollback doesn't take place before the server stops must be
-- undone at recovery time
checkpoint
go
-- Find out the page that was created for this database
--
select extent_file_id, extent_page_id, allocated_page_iam_file_id, allocated_page_iam_page_id, allocated_page_file_id, allocated_page_page_id 
from sys.dm_db_database_page_allocations(db_id('thenbaplayoffs'), object_id('whowillwin'), null, null, 'detailed')
go
-- kill sqlservr.exe and then hack that page with a hex editor
-- When you restart SQL Server you will see the problem
-- When you need to fix this try restoring the page with Restore Assistant