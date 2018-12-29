1. Restart SQL Server
1a. Start Task Manager
2. Run gocowboys_once.cmd to load the database into cache. it should take about 23 seconds to complete. notice in Task Manager some CPU for SQLSERVR.EXE but mostly disk. This is likely becasue we are loading up cache.
3. Load up performance dashboard reports
4. Run gocowboys.cmd again. It takes 30 seconds now.  Notice the really high CPU from Task Manager
5. Talk about Performance Dashboard Reports using DMVs and what is on the main page
5a.When the query is done Refresh report a few times until you see the blue bar higher
6. Drill into the blue bar on the CPU graph
7. Notice the top query has a WHERE clause with >. Look at the high number of reads for this even though
executed 90+ times. The @1 is the paramterized look at this query.
8. Drill into the query
9. Notice the esimate rows is 300000 but notice the value of the parmeter at compile time is 999000.
If you knew there were 1000000 unique values in the table, why 300000?
10. look at the statement text an notice the clustered index scan and the CONVERT_IMPLICIT on the column itself
11. Now bring up cowboys_query.sql
12. The first query is the run we are running. Get the estimated plan. Notice the warning on the SELECT
statement. Show the XML plan warnings
13. Get the estimated for the 2nd plan. Notice it is a seek with no warnings. This is because there is
no conversion.