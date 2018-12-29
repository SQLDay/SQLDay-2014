1. Database can be setup from howboutthemcowboys.sql
2. Load up dmvs.sql
3. Load up countem.sql and run the query
4. Look at DMVs and point out what dm_exec_requests and dm_os_waiting_tasks are saying. Look at wait_resource
for CXPACKET in dm_os_waiting_tasks and see Nodeid.
5. Go back and look at plan for query in countem.sql and find nodeid =3. This is the gather streams operator
which is simply trying to gather all the pages from the scan to aggregrate the count