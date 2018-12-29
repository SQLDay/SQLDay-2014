alter database tempdb add file (name = 'tempdev2', filename = 'c:\program files\microsoft sql server\MSSQL10_50.MSSQLSERVER\mssql\data\tempdev2.ndf', size = 100Mb, maxsize = unlimited, filegrowth = 10%)
go
alter database tempdb add file (name = 'tempdev3', filename = 'c:\program files\microsoft sql server\MSSQL10_50.MSSQLSERVER\mssql\data\tempdev3.ndf', size = 100Mb, maxsize = unlimited, filegrowth = 10%)
go
alter database tempdb add file (name = 'tempdev4', filename = 'c:\program files\microsoft sql server\MSSQL10_50.MSSQLSERVER\mssql\data\tempdev4.ndf', size = 100Mb, maxsize = unlimited, filegrowth = 10%)
go
alter database tempdb add file (name = 'tempdev5', filename = 'c:\program files\microsoft sql server\MSSQL10_50.MSSQLSERVER\mssql\data\tempdev5.ndf', size = 100Mb, maxsize = unlimited, filegrowth = 10%)
go
alter database tempdb add file (name = 'tempdev6', filename = 'c:\program files\microsoft sql server\MSSQL10_50.MSSQLSERVER\mssql\data\tempdev6.ndf', size = 100Mb, maxsize = unlimited, filegrowth = 10%)
go
shutdown
go