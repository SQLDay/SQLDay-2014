
select *
from Sales.SalesOrderHeader
order by OrderDate



select * 
from sys.partitions
where object_id = OBJECT_ID('Sales.SalesOrderHeader')

select *
from sys.dm_db_partition_stats
where object_id = OBJECT_ID('Sales.SalesOrderHeader')



select *
from sys.dm_db_persisted_sku_features



CREATE PARTITION FUNCTION PF_SalesOrderHeader(datetime)
AS
RANGE RIGHT FOR VALUES
('20050701','20050801','20050901','20051001','20051101','20051201',
 '20060101','20060201','20060301','20060401','20060501','20060601','20060701','20060801','20060901','20061001','20061101','20061201',
 '20070101','20070201','20070301','20070401','20070501','20070601','20070701','20070801','20070901','20071001','20071101','20071201',
 '20080101','20080201','20080301','20080401','20080501','20080601','20080701','20080801','20080901','20081001','20081101','20081201'
 )
GO

select *
from sys.partition_range_values


CREATE PARTITION SCHEME PS_SalesOrderHeader
AS
PARTITION PF_SalesOrderHeader
ALL TO ([PRIMARY])
GO


ALTER TABLE [Sales].[SalesOrderDetail] DROP CONSTRAINT [PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID]
GO


ALTER TABLE [Sales].[SalesOrderDetail] ADD  CONSTRAINT [PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID] PRIMARY KEY CLUSTERED 
(
	[SalesOrderID] ASC,
	[SalesOrderDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
ON PS_SalesOrderHeader(OrderDate)
GO

select * 
from sys.partitions
where object_id = OBJECT_ID('Sales.SalesOrderHeader')

select *
from sys.dm_db_partition_stats
where object_id = OBJECT_ID('Sales.SalesOrderHeader')







--STEP1 > Create new partition
 DECLARE @Day datetime

 SET @Day = cast((select top 1 [value] from sys.partition_range_values
        where function_id = (select function_id
                from sys.partition_functions
                where name = 'PF_SalesOrderHeader')
       order by boundary_id DESC) as datetime)
--SELECT @Day

 WHILE @Day < DATEADD(MONTH, 1, GETDATE())
 BEGIN
                 SET @Day = DATEADD(MONTH, 1, @Day)

                 ALTER PARTITION SCHEME PS_SalesOrderHeader
                 NEXT USED [PRIMARY];

                 ALTER PARTITION FUNCTION PF_SalesOrderHeader()
                 SPLIT RANGE (@Day);
 END
 GO


 --STEP2 > Switch

 DECLARE @Day datetime

 SET @Day = cast((select top 1 [value] from sys.partition_range_values
           where function_id = (select function_id
                   from sys.partition_functions
                   where name = 'PF_SalesOrderHeader')
          order by boundary_id) as datetime)

 WHILE DATEDIFF(dd, @Day, GETDATE()) > 180
 BEGIN

 ALTER TABLE [Sales].[SalesOrderHeader] SWITCH PARTITION 2 TO [Sales].[SalesOrderHeader_Archive];

 TRUNCATE TABLE [Sales].[SalesOrderHeader_Archive];

 --make sure that the 1st and 2nd partitions are both empty
 IF (select SUM(rows)
                 from sys.partitions
                 where object_id = OBJECT_ID ('[Sales].SalesOrderHeader')
                 AND index_id = 1
                 AND partition_number IN (1,2))=0
 --and remove the first one:
 ALTER PARTITION FUNCTION PF_SalesOrderHeader()
 MERGE RANGE (@Day);

 SET @Day = cast((select top 1 [value] from sys.partition_range_values
           where function_id = (select function_id
                   from sys.partition_functions
                   where name = 'PF_SalesOrderHeader')
          order by boundary_id) as datetime);

 END

