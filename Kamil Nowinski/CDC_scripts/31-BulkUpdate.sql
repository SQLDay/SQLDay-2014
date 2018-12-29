USE CDC_SQLDay2014
GO

declare @i int = 73;
while @i < 76
begin
	update dbo.Person set [LastName] = 'D-Agostino ' + cast(@i as char(2)), ModifiedDate = GETDATE() where BusinessEntityID = 9;
    WAITFOR DELAY '00:00:01';
	set @i = @i + 1;
end
select * from dbo.Person where BusinessEntityID = 9;

select * from cdc.dbo_Person_CT where BusinessEntityID = 9 and ModifiedDate >= '20140421 14:20:00';


select * from dbo.DimPersonStage;
select * from dbo.DimPerson where BusinessEntityID = 9;

select * from dbo.SysLog;

---------------------------------------------------------------
