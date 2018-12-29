5a. Clock hands

Make sure max server memory is 0 and restart SQL Server
Run reduce_max_memory to 400
Load up clock_hands.sql. The values of past time means the clock hasn't moved
Run herecomethebears.sql to load up procedure cache.
When total gets to target we have pressure.
Go back and see if the clock hands have moved. Notice they all move for EXTERNAL,
but not all remove entries because it is based on cost and for userstore on their own
algorithm
Which stores removed the most: OBJCP because of all the procs we added

5b. freesystemcache

Load up freesystemcache.sql
Check the value of cache counters
Run iloveadhoc.cmd
Check the value of counters again
Run the query to free 'SQL Plans'
Check the values again
Check the value of all cache counters
Free all caches and check counters again