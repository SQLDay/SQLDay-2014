use [CDC_SQLDay2014]
GO

select object_id, SCHEMA_NAME(schema_id) as sch, name, type, type_desc, is_tracked_by_cdc from sys.tables where SCHEMA_NAME(schema_id) != 'cdc';


/*
You can disable CDC on a particular table by executing the following T-SQL script:
*/
exec sys.sp_cdc_disable_table 
  @source_schema = 'dbo', 
  @source_name = 'Person',
  @capture_instance = 'all'


exec sys.sp_cdc_disable_table 
  @source_schema = 'dbo', 
  @source_name = 'customerWithoutPK',
  @capture_instance = 'dbo_customerWithoutPK' -- or 'all'


exec sys.sp_cdc_disable_table 
  @source_schema = 'dbo', 
  @source_name = 'customer',
  @capture_instance = 'dbo_customer' -- or 'all'


/*
You can disable CDC at the database level by executing the following T-SQL script:
*/
declare @rc int
exec @rc = sys.sp_cdc_disable_db
select @rc
-- show databases and their CDC setting
select name, is_cdc_enabled from sys.databases;
GO


