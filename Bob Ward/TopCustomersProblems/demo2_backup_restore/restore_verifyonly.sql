-- Cleanup
--
use master
go
drop database bearswinthebig12_alt 
go
-- Try to verify it
--
restore verifyonly from disk = 'c:\temp\bearswinthebig12.bak'
go
-- Try to restore it to a different location
--
restore database bearswinthebig12_alt from disk = 'c:\temp\bearswinthebig12.bak'
with move 'bearswinthebig12' to  'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\bearswinthebig12_alt.mdf',
move 'bearswinthebig12_log' to 'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\bearswinthebig12_log_alt.ldf'
go
-- Try to restore it to a different location with continue_after_error
--
restore database bearswinthebig12_alt from disk = 'c:\temp\bearswinthebig12.bak'
with move 'bearswinthebig12' to  'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\bearswinthebig12_alt.mdf',
move 'bearswinthebig12_log' to 'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\bearswinthebig12_log_alt.ldf',
continue_after_error
go
--dbcc checkdb(bearswinthebig12_alt)
--go
-- Try to look at the procs. Ouch!
--
use bearswinthebig12_alt
go
select * from sys.sql_modules
go