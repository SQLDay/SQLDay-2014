2a. Total and nodes

Run query from file process_and_nodes.sql and talk to the numbers
Add the perfmon counters SQL Server: Memory Manager\Total Server Memory (KB)
and SQL Server: Memory Manager\Total Node Memory (KB)

Notice that there is not a way from dm_os_process_memory to compare to these perfmon
counters but if you add up the nodes virt+locked you can line them up

The key is that Total Server Memory (KB) is how much SQL Server itself has allocated
memory through SQLOS allocators

2b. Nodes and clerks

Load the nodes_and_clerks.sql script and go through each query
For the last query compare this to Perfmon counter SQL Server:Memory Manager\Connection Memory (KB)

2c. Memory Objects

Load the memory_objects.sql script and go through each query

2d. Trace memory allocations from objects

Stop SQL Server
Restart with /T3654

Run the queries from memory_allocations.sql
Attach debugger and use dps <stack address> to see the callstack with symbols

2e. Let's look at multi-nodes

Perfmon running with these counters
NUMA Node Memory\Available MBytes (for all nodes)
Total Node Memory (KB) for both SQL nodes

Run my eatmem.exe program as eatmem.exe 24000000000. Let's make sure to run on node 0 by using this syntax from cmd.exe
start /NODE 0 eatmem.exe 24000000000

Notice which NUMA node has almost no memory
Start SQL Server
Notice that it appears that the same SQL Memory Node has a large amount of memory? How?
Run DBCC MEMORYSTATUS and look at the stats for each node
Away Committed for the node that has memory
Taken Away Committed for the node that is depleted.
Show the source of my program (incuded in this demo folder at eatmem.cpp).