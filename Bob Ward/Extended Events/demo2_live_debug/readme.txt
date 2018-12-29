0. Run primecache.cmd to ensure we have a warm cache
1. Start live_server_debugging extended events session
2. Run repro.cmd
3. Notice task manager high CPU and I/O
4. Select 'Watch Live Data" from the XEvent session
5. While the repro completes talk about what events I'm collecting
5a. Load show_xevent_sessions.sql to show the sessions and the new target for streaming
6. Once the repro completes stop the live data
7. First try to group by statement and aggregate on avg duration desc. Note the duration and CPU are in microseconds.
8. Take off grouping and notice the inaccurate cardinality events
9. Group by activity ID. Find the one with the most events and notice the events associated with statement in the proc
10. Bring up the proc and point out the usage of the table variable (which always has estimate of 1 row). 
The OPTION recopmile comment can be uncommented to resolve this
11. Take off grouping. What about the other statements in the trace. Notice the pattern of queries with "> 991".
12. Point out the query_hash column. Group by query_hash and point out that these queries are really "1 query" to try and tune. In this case we are missing an index. Point out the
high number of logical reads.