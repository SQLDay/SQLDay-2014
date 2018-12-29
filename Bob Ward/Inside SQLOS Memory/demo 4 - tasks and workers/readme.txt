DEMO4 - .\demo 4 - tasks and workers

Load threads_workers_and_tasks.sql and show first query
Run ihogcpu.cmd and run the query again to show differences
Run the second query to show mapping of workers to tasks
Find LAZYWRITER task and note its thread id. Convert it to hex.
Now attach debugger
Use the .formats 0n<threadid> to show the hex value
Use the ~~[<threadid in hex>]k command to see if we can find its stack
Do this for LOCK MONITOR
What is the difference at the top of the stack for LockMonitor and LazyWriter?
Show in the debugger an idle worker and how it is waiting on a queue. Show its thread function starting point.
