/*
    Zarz¹dzanie funkcj¹ CDC
*/
use [CDC_SQLDay2014]
GO

DROP PROCEDURE dbo.cdc_GetAllNetChangesForPerson;

CREATE PROCEDURE dbo.cdc_GetAllNetChangesForPerson
AS
BEGIN
    declare @begin_lsn binary(10), @end_lsn binary(10)
    select @begin_lsn = sys.fn_cdc_get_min_lsn('dbo_person')
    select @end_lsn = sys.fn_cdc_get_max_lsn()
    select * from cdc.fn_cdc_get_net_changes_dbo_person(@begin_lsn, @end_lsn, 'all'); 

END
GO

EXEC dbo.cdc_GetAllNetChangesForPerson;

/*
    Zmiany schematu
*/
--Dodanie kolumny
ALTER TABLE dbo.Person ADD JobTitle varchar(80) NULL;
GO
EXEC dbo.cdc_GetAllNetChangesForPerson;
GO
--Rezultat: Nowa kolumna jest ignorowana;


--Usuniêcie kolumny
ALTER TABLE dbo.Person DROP COLUMN [rowguid];
GO
EXEC dbo.cdc_GetAllNetChangesForPerson;
GO
--Rezultat: Bez zmian - Dotychczasowe wpisy w tabeli zmian nadal s¹ widoczne.

SELECT * FROM dbo.Person;


UPDATE dbo.Person
SET [Title] = 'Mr.', [JobTitle] = 'Writer' where BusinessEntityID = 10
GO
EXEC dbo.cdc_GetAllNetChangesForPerson;
GO

--Rezultat: W kolumnie [rowguid] wprowadzony zosta³ NULL

--Dlatego CDC przechowuje historiê zmian DDL:
EXEC sys.sp_cdc_get_ddl_history N'dbo_Person';

--> Zaleta mo¿liwoœci stosowania dwóch instancji przechwytywania:
--  1. App wykorzystuj¹ pierwsz¹ instancjê do momentu utworzenia nowej
--  2. Wówczas pobieraæ min(LSN) nowej instancji i pobraæ wszystkie zmiany przed ni¹
--  3. Nastêpnie stosowaæ nowsz¹ instancjê do czasu a¿ wszystkie app klienckie zrezygnuj¹ ze stosowania starej

