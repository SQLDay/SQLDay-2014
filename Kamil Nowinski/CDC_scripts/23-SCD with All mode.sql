USE CDC_SQLDay2014
GO


--23 SCD with All mode
--Wiêcej zmian na jednym rekordzie "w trakcie doby"

declare @i int = 40;
while @i < 45
begin
	update dbo.Person set [LastName] = 'D-Agostino ' + cast(@i as char(2)) where BusinessEntityID = 9;
	set @i = @i + 1;
end
select * from dbo.Person where BusinessEntityID = 9;
select * from dbo.DimPerson where BusinessEntityID = 9;



--Niestety - w przypadku seryjnych zmian nie dzia³a dobrze!
--Nie mamy wype³nione kolumny EndDate (poza pierwszym wierszem)

update dbo.Person set [FirstName] = 'Gigiano', Suffix = 'Agent2' where BusinessEntityID = 9;
select * from dbo.DimPerson where BusinessEntityID = 9;




