-- BPE is disabled
SELECT * FROM sys.dm_os_buffer_pool_extension_configuration
GO



-- Enable Buffer Pool Extension at drive D:
ALTER SERVER CONFIGURATION SET BUFFER POOL EXTENSION ON 
(FILENAME = 'D:\DyskSSD\EXTRABUFFER.BPE', SIZE = 10GB)
GO


SELECT
       [path],
	   [state],
       state_description,
       current_size_in_kb / 1024 AS current_size_mb
FROM sys.dm_os_buffer_pool_extension_configuration;



-- Buffer Pool Extension usage (last column of the query result)
SELECT * FROM sys.dm_os_buffer_descriptors
GO


-- Disable Buffer Pool Extension
ALTER SERVER CONFIGURATION SET BUFFER POOL EXTENSION OFF
GO


-- Buffer Pool Extension is disabled
SELECT
       [path],
	   [state],
       state_description,
       current_size_in_kb / 1024 AS current_size_mb
FROM sys.dm_os_buffer_pool_extension_configuration;



-- try to enable BPE again, at 5GB
ALTER SERVER CONFIGURATION SET BUFFER POOL EXTENSION ON 
(FILENAME = 'D:\DyskSSD\EXTRABUFFER.BPE', SIZE = 5GB)
GO

-- we need to:
-- 1/ disable BPE
-- 2/ restart an instance
-- 3/ re-enable it at new size




/*

  LINKS
  
  David Barbarin - Buffer pool extension - an interesting new feature
  http://www.dbi-services.com/index.php/blog/entry/sql-server-2014-buffer-pool-extension-

  Daniel Farina - Increasing Buffer Pool in SQL Server 2014
  http://www.mssqltips.com/sqlservertip/3156/increasing-buffer-pool-in-sql-server-2014/

  Klaus Aschenbrenner - Buffer Pool Extensions in SQL Server 2014
  http://www.sqlpassion.at/archive/2014/03/11/buffer-pool-extensions-in-sql-server-2014/



*/

