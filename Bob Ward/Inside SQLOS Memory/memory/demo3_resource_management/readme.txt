3. Resource Monitor and Brokers

a. Make sure 'max server memory' is 0 and restart SQL Server

b. Load up resource_monitor_ring_buffer.sql. You should see RESOURCE_MEMPHYSICAL_HIGH. point out target,
committed, and available physical memory. The <Effect> node is when SQL Server "overrides"
what Windows says because it is monitoring our working set utilization.

c. Load up memory_broker_ring_buffer.sql and talk about how all notifications are to grow.
Run select * from sys.dm_os_memory_brokers. Notice the target is about 80% of overall target

d. Load hercomethebears.sql and run it. This will populate plan cache with a bunch of
procedures.

e. Look at allocations for MEMORYBROKER_FOR_CACHE for pool = 2. Notice the growth

f. Run a multi-user sort job with run_sort.cmd. Look at brokers again. No shrink occurred,
but notice the targets of all other brokers is lower. This is in response to the RESERVE memory. Other broker targets are
actually lowered.

g. Stop the sort and look at SQL Server:Memory Manager/Free Memory (KB) has increased. Why?
This is because sort commits memory from the block alloactor but unlike caches gives
its memory back to SQLOS

NOTE: Don't use 'max server memory' decrease to show pressure for plan cache as it will cause a plan cache flush
without using any RM actions.

h. Let's introduce some pressure by actually chewing up physical memory with the eatmem.exe program. Run
eatmem 14000000000 (or whatever value will induce pressure on your computer)

i. Look at DMVs and perfmon to see what happened

Look at RM ring buffer and broker ring buffers
Now look at broker values overall
Look at perfmon counters
Go back and look at RM ring buffers

j. After a while our targets start increasing. Why?