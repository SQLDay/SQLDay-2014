/*
    CDC DEMO
*/
USE [CDC_SQLDAY2014]
GO

SELECT * FROM dbo.Person;
UPDATE dbo.Person set [LastName] = 'Follett', ModifiedDate=GETDATE() where [LastName] = 'Sánchez';		--5 rows Updated
DELETE from dbo.Person where ModifiedDate <'20020101';							--8 rows deleted

SELECT * FROM [cdc].[dbo_Person_CT];


/*
Now let's take a look at a query that will show us a record of the above changes:
*/
declare @begin_lsn binary(10), @end_lsn binary(10)
-- get the first LSN for person changes
select @begin_lsn = sys.fn_cdc_get_min_lsn('dbo_Person')
-- get the last LSN for person changes
select @end_lsn = sys.fn_cdc_get_max_lsn()
-- get net changes; group changes in the range by the pk
select * from cdc.fn_cdc_get_net_changes_dbo_Person(@begin_lsn, @end_lsn, 'all') --ORDER BY __$start_lsn;
-- get individual changes in the range
select * from cdc.fn_cdc_get_all_changes_dbo_Person(@begin_lsn, @end_lsn, 'all update old');
select * from cdc.fn_cdc_get_all_changes_dbo_Person(@begin_lsn, @end_lsn, 'all');

/*
The __$operation column values are: 1 = delete, 2 = insert,  3 = update (values before update), 4 = update (values after update)
*/


--...http://www.mssqltips.com/sqlservertip/1474/using-change-data-capture-cdc-in-sql-server-2008/


select * from [cdc].[change_tables]
select * from [cdc].[captured_columns]
select * from [cdc].[dbo_person_CT]
select * from [cdc].[ddl_history]
select * from [cdc].[index_columns]
select * from [cdc].[lsn_time_mapping]   --Log Sequence Number
select * from [dbo].[systranschemas]

exec sys.sp_cdc_help_change_data_capture






