use master
go
-- Have to backup the current tail of log first
--
backup log thenbaplayoffs to disk = 'c:\europe_pass_2010\precon_internal_tools_for_the_dba\advanced_recovery\deferred_transactions\thenbaplayoffs_log.bak' with init
go
-- Restore the page all while db online
--
restore database thenbaplayoffs page = '1:153' from disk = 'c:\europe_pass_2010\precon_internal_tools_for_the_dba\advanced_recovery\deferred_transactions\thenbaplayoffs.bak'
with norecovery
go
-- Restore back the tail
--
restore log thenbaplayoffs from disk = 'c:\europe_pass_2010\precon_internal_tools_for_the_dba\advanced_recovery\deferred_transactions\thenbaplayoffs_log.bak'
go
-- Go notice the truncate finished now and is not blocked anymore