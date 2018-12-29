select spid, ecid, cmd, status, waittype, waittime, waitresource, 
lastwaittype
from sys.sysprocesses
go