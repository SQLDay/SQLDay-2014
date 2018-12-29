1. Show errorlog_buf_latchtimeout.txt for buf latch timeout. Break out the fields

In the timeout message for BUF: type = enum of modes (KP=1,SH=2, ...), bp=BUF address, flags=m_count; stat=bstat from BUF
In the timeout message for non-BUF you get class name and other fields like BUF. id is the address of the latch class itself.

Task is task address. The number after the colon corresponds to exec_context_id in sys.dm_os_tasks.  
QUESTION TO AUDIENCE?: What if this value is > 0?

QUESTION FOR AUDIENCE: Why is task and owner the same in my BUF timeout example?

TODO: http://support.microsoft.com/kb/968543 is an example of a deadlatch
