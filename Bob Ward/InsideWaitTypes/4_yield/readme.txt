Run sqlcpudemo.sql in 1 query window
Run wait_stats.sql in another window
Show high wait count but low wait times from sys.dm_os_wait_stats
Now run crankitup.cmd and see what happens
What does sys.dm_exec_requests look like? Talk about last_wait_type and RUNNABLE
Talk about signal_wait_time in wait_stats
Load up rg_cpu_cap.sql and re-run the repro to see what happens in wait_stats