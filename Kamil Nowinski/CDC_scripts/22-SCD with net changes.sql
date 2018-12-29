USE CDC_SQLDay2014
GO

select * from [dbo].[cdc_states];
--TFEND/CS/0x0000021D00001A880003/TS/2014-04-25T16:18:59.9288622/


-- 22. SCD with net changes

select * from dbo.Person;
update dbo.Person set [FirstName] = 'Leszek' where BusinessEntityID = 7;
update dbo.Person set ModifiedDate= GETDATE() where BusinessEntityID = 7;
update dbo.Person set [LastName] = 'Margheim-Nowak', EmailPromotion=1, ModifiedDate=GETDATE() where BusinessEntityID = 8;

select * from dbo.Person where BusinessEntityID in (7, 8);

select * from dbo.DimPerson;
select * from dbo.DimPerson where BusinessEntityID in (7, 8);
select * from dbo.DimPerson where [LastName] LIKE 'Foll%'
GO









DELETE FROM dbo.Person WHERE [LastName] = 'Wood';
select * from dbo.DimPerson where EndDate is not null


update dbo.cdc_states set [state] = 'TFEND/CS/0x0000021D00001A880003/TS/2014-04-25T16:18:59.9288622/' where [name] = 'CDC_State_DimPerson';