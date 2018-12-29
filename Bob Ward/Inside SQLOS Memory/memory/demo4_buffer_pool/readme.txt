4a. Grow and Shrink

Set 'max server memory' to 0 and stop SQL Server
Start under the debugger
Set breakpoint as 'bp sqlmin!BPool::Steal'
Type 'g' to continue
Notice the stack. We are attempting to get the boot page for a db.
Now set breakpoint on 'sqldk!MemoryNode::AllocatePagesInternal'
Type 'g' to continue
This is a stack showing us growing the BPool
Clear breakpoints with 'bc *'
Now set breakpoing on 'sqlmin!BPool::ReplenishFreeList'
Type 'g' to continue
Run gocowboys.cmd to load up a table in memory
Run reduce_max_server_memory.sql
Show stack on breakpoint. Hit 'g' and keep showing different stacks
on various ways to replenish the free list
Run reset_max_memory.sql and restart SQL Server

4b. DBCC BUFFER

Load dbcc_buffer.sql and show the results. Be sure to change the update string.

4c. NUMA node stats

Start SQL Server on multi-node machine with trace flag 842
Run the query select * from sys.dm_os_memory_node_access_stats
Explain the output

Local node - node of worker "getting" the buffer
Remote node - node of the buffer (remember buffers are partitioned by node and CPU)



