use master
go
drop table simpletable
go
CREATE TABLE SimpleTable
(ProductKey [int] NOT NULL, 
OrderDateKey [int] NOT NULL, 
DueDateKey [int] NOT NULL, 
ShipDateKey [int] NOT NULL);
GO
CREATE CLUSTERED INDEX cl_simple ON SimpleTable (ProductKey);
GO
insert into SimpleTable values (1,1,1,1)
go
CREATE NONCLUSTERED COLUMNSTORE INDEX csindx_simple
ON SimpleTable
(OrderDateKey, DueDateKey, ShipDateKey);
GO
select * from simpletable
go
