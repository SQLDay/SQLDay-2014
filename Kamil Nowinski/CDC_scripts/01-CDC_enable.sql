use [CDC_SQLDay2014]
go

declare @rc int
exec @rc = sys.sp_cdc_enable_db
select @rc
-- new column added to sys.databases: is_cdc_enabled
select name, is_cdc_enabled from sys.databases order by [name]


SELECT name, object_id, parent_class_desc, type_desc from sys.triggers;
SELECT object_id, type_desc FROM sys.trigger_events;




-- Execute the following system stored procedure to enable CDC for the customer table:
exec sys.sp_cdc_enable_table 
     @source_schema = 'dbo' 
    ,@source_name = 'Person'
    ,@role_name = 'CDCRole'
	--@capture_instance = 'dbo_person_CT'
    ,@supports_net_changes = 1
	--,@captured_column_list = ''
	--,@filegroup_name = 'PRIMARY';

select object_id, SCHEMA_NAME(schema_id) as sch, name, type, type_desc, is_tracked_by_cdc from sys.tables where SCHEMA_NAME(schema_id) != 'cdc';
select object_id, SCHEMA_NAME(schema_id) as sch, name, type, type_desc, is_tracked_by_cdc from sys.tables where SCHEMA_NAME(schema_id)  = 'cdc';



/*
	You can examine the schema objects created by running the following T-SQL script:
*/
select o.name, o.type, o.type_desc from sys.objects o
join sys.schemas  s on s.schema_id = o.schema_id
where s.name = 'cdc';
--------------------------------------------------------------------------------------









/*
    Próba za³o¿enia CDC na tabeli bez PK
*/
create table dbo.CustomerWithoutPK
(
id int identity not null
, name varchar(50) not null
, [state] varchar(2) not null
);
go

exec sys.sp_cdc_enable_table 
    @source_schema = 'dbo', 
    @source_name = 'CustomerWithoutPK' ,
    @role_name = 'CDCRole',
    @supports_net_changes = 1;

--Msg 22939, Level 16, State 1, Procedure sp_cdc_enable_table_internal, Line 194
--The parameter @supports_net_changes is set to 1, but the source table does not have a primary key defined and no alternate unique index has been specified.

exec sys.sp_cdc_enable_table 
    @source_schema = 'dbo', 
    @source_name = 'CustomerWithoutPK' ,
    @role_name = 'CDCRole';

--Uda³o siê bez wspierania net_changes :)





