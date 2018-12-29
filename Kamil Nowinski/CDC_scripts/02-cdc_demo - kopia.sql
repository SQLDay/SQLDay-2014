/*
    CDC Demo
*/
use [CDC_SQLDay2014]
GO

select * from dbo.customer;
insert dbo.customer values ('abc company', 'md');
insert dbo.customer values ('xyz company', 'de');
insert dbo.customer values ('xox company', 'va');
select * from dbo.customer;
update dbo.customer set [state] = 'pa' where id = 1;
delete from dbo.customer where id = 3;
update dbo.customer set [state] = 'PA' where id = 1;


/*
Now let's take a look at a query that will show us a record of the above changes:
*/
declare @begin_lsn binary(10), @end_lsn binary(10)
-- get the first LSN for customer changes
select @begin_lsn = sys.fn_cdc_get_min_lsn('dbo_customer')
-- get the last LSN for customer changes
select @end_lsn = sys.fn_cdc_get_max_lsn()
-- get net changes; group changes in the range by the pk
select * from cdc.fn_cdc_get_net_changes_dbo_customer(@begin_lsn, @end_lsn, 'all'); 
-- get individual changes in the range
select * from cdc.fn_cdc_get_all_changes_dbo_customer(@begin_lsn, @end_lsn, 'all update old');

/*
The __$operation column values are: 1 = delete, 2 = insert,  3 = update (values before update), 4 = update (values after update)
*/


--Co siê stanie gdy SQL Agent bêdzie wy³¹czony?
insert customer values ('CAMOsoft', 'DW');
--STOP Agent
delete from customer where [state] = 'DW';
--START Agent
--Wiersz siê dopisa³.
--Kto i kiedy czyœci transaction loga przy RM = Simple?


--...http://www.mssqltips.com/sqlservertip/1474/using-change-data-capture-cdc-in-sql-server-2008/


select * from [cdc].[captured_columns]
select * from [cdc].[change_tables]
select * from [cdc].[dbo_customer_CT]
select * from [cdc].[ddl_history]
select * from [cdc].[index_columns]
select * from [cdc].[lsn_time_mapping]   --Log Sequence Number
select * from [dbo].[systranschemas]

exec sys.sp_cdc_help_change_data_capture

