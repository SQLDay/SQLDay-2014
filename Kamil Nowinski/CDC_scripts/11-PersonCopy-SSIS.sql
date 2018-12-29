-- Execute the following system stored procedure to enable CDC for the customer table:
USE CDC_SQLDay2014
GO
----------------------------------------------------------------------------------------------------
 
select * from dbo.Person
where LastName = 'Duffy';

select * from [cdc].[dbo_Person_CT]


select * from [dbo].[cdc_states];
--TFEND/CS/0x00000041000005C10001/TS/2014-03-25T08:14:26.9861886/
--TFEND/CS/0x0000007F0000077F0001/TS/2014-03-26T20:46:23.2714891/
--TFEND/CS/0x00000084000006560003/TS/2014-03-26T20:48:34.5079954/
--TFEND/CS/0x000000EA00001F700002/TS/2014-04-15T06:23:44.3314094/

select * from dbo.PersonCopy
where LastName = 'Duffy';


select * from dbo.cdc_states;



update dbo.Person
set EmailPromotion = 2, ModifiedDate = getdate()
where BusinessEntityID = 2237

select * from dbo.Person where BusinessEntityID = 2237
select * from dbo.PersonCopy where BusinessEntityID = 2237




----------------
-- Run: SSIS
----------------


SELECT * FROM PersonCopy where BusinessEntityID = 2237;


delete from dbo.Person where BusinessEntityID = 2237;


--Co siê stanie gdy zmian bêdzie wiêcej dla tego samego wiersza?
SELECT * FROM Person where BusinessEntityID = 2200;

UPDATE dbo.Person
set EmailPromotion += 1, ModifiedDate = getdate()
where BusinessEntityID = 2206;
GO 100
DELETE FROM dbo.Person where BusinessEntityID = 2207;
GO
UPDATE dbo.Person
set MiddleName = 'A.', ModifiedDate = getdate()
where BusinessEntityID = 2209;
GO




SELECT * FROM PersonCopy where BusinessEntityID = 2206;

select * from cdc.dbo_Person_CT




update cdc_states
set [state] = 'TFEND/CS/0x0000007F0000077F0001/TS/2014-03-26T20:46:23.2714891/'

