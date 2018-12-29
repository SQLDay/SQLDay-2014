sqlcmd -E -iremovetempdbfiles.sql -S.
del "c:\program files\microsoft sql server\MSSQL10_50.MSSQLSERVER\mssql\data\tempdev2.ndf"
del "c:\program files\microsoft sql server\MSSQL10_50.MSSQLSERVER\mssql\data\tempdev3.ndf"
del "c:\program files\microsoft sql server\MSSQL10_50.MSSQLSERVER\mssql\data\tempdev4.ndf"
del "c:\program files\microsoft sql server\MSSQL10_50.MSSQLSERVER\mssql\data\tempdev5.ndf"
del "c:\program files\microsoft sql server\MSSQL10_50.MSSQLSERVER\mssql\data\tempdev6.ndf"
net start mssqlserver