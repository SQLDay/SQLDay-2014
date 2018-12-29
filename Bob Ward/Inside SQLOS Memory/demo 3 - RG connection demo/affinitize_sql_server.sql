-- Let's dynamic adjust affinity
--
-- First affinitize only for Node 0
--
ALTER SERVER CONFIGURATION 
SET PROCESS AFFINITY NUMANODE=1
go
-- Now just affinitize half of CPUs from both nodes
--
ALTER SERVER CONFIGURATION
SET PROCESS AFFINITY CPU=0 TO 5, 12 to 17
go
-- Go back to AUTO
--
ALTER SERVER CONFIGURATION 
SET PROCESS AFFINITY CPU=AUTO
go