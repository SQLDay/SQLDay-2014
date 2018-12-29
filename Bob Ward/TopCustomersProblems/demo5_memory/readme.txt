0. Restart SQL Server
1. Bring up Task Manager and show the columns for SQLSERVR.EXE.
2. Bring up show_sql_memory.sql and show the DMV columsn and compare to Task Manager
3. Open up perfmon with the following counters:

SQL Server:Memory Manager\Target Server Memory (KB)
SQL Server:Memory Manager\Total Server Memory (KB)

Notice that Target is really large, about 12Gb which is almost 100% of available physical memory
on my laptop. This is ourrent maximum memory SQL Server can grow to.

Total Server Memory is the memory we are currently using (but does not include memory such as thread
stacks, heaps, executables, etc).

4. Load up gocowboys.sql and run the query
5. Look at perfmon and see the Total start increasing. It stops when the query stops. 
It is now almost 8Gb. Notice though in Task Manager it doesn't look like we are using near that much.
This is because we are using locked pages which are not accounted for in Task Manager
6. Load up lower_the_ceiling.sql and run it
7. See the target change and the total memory go down until it gets right at or below target