/*
    CDC Jobs
*/
use [CDC_SQLDay2014]
GO



--exec sp_cdc_change_job 
exec sp_cdc_stop_job;
exec sp_cdc_start_job;

exec sp_cdc_help_jobs;
--retention = 4320 = 3d okres przechowywania
--thresgold = 5000 - max. iloœæ wierszy usuwana w jednej komendzie DELETE


SELECT * FROM sys.dm_cdc_log_scan_sessions;



--ZMIANA parametrów:
--http://msdn.microsoft.com/en-us/library/bb510748.aspx
DECLARE @minutes int = 5; --7*24*60;
exec sp_cdc_change_job @job_type='cleanup', @retention=@minutes;
exec sp_cdc_help_jobs;





