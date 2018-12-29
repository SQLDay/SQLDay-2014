1. Load up the query from showlatchandwaitstats.sql
2. Talk about how wait stats will show PAGE latches separate from LATCH_XX
3. So any LATCH_XX is something in sys.dm_os_latch_stats
4. BUFFER in sys.dm_os_latch_stats matches any PAGE or PAGEIO latch waits in sys.dm_os_wait_stats