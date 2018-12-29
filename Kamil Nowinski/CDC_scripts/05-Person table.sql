USE CDC_SQLDay2014
GO

SELECT [BusinessEntityID]
      ,[PersonType]
      ,[NameStyle]
      ,[Title]
      ,[FirstName]
      ,[MiddleName]
      ,[LastName]
      ,[Suffix]
      ,[EmailPromotion]
      ,[rowguid]
      ,[ModifiedDate]
into CDC_SQLDay2014.dbo.Person
from [AdventureWorks2012].[Person].[Person]
GO

ALTER TABLE dbo.Person ADD CONSTRAINT PK_Person PRIMARY KEY CLUSTERED 
	(BusinessEntityID ) WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


--W³¹cz CDC dla tabeli Person:
exec sys.sp_cdc_enable_table 
    @source_schema = 'dbo', 
    @source_name = 'Person' ,
    @role_name = 'CDCRole',
    @supports_net_changes = 1;
select object_id, SCHEMA_NAME(schema_id) as sch, name, type, type_desc, is_tracked_by_cdc from sys.tables where SCHEMA_NAME(schema_id) != 'cdc';
GO

