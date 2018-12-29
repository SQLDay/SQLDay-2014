/*
    Wydajno��
*/

USE CDC_SQLDay2014
GO

--Domy�lnie teoretyczny limit wydajno�ci to 1000 polece� / sek, bo:
--max. 10 operacji scan x 500 polece� co 5 sek.
SELECT * FROM sys.dm_cdc_log_scan_sessions;

SELECT session_id, start_time, end_time, empty_scan_count, command_count, duration, tran_count, latency, start_lsn, end_lsn 
FROM sys.dm_cdc_log_scan_sessions ORDER BY start_time;

--empty_scan_count
--command_count	- liczba polece�
--duration		- czas trwania skanowania
--latency		- czas trwania zapisania wierszy zmian w tabeli zmian

exec sp_spaceused N'dbo.Person';
exec sp_spaceused N'[cdc].[dbo_Person_CT]';

update dbo.Person set EmailPromotion += 1;

exec sp_spaceused N'dbo.Person';
exec sp_spaceused N'[cdc].[dbo_Person_CT]';

--Dlaczego mamy 2x19972 wierszy? :)
select * from cdc.dbo_Person_CT;

update dbo.Person set EmailPromotion -= 1;
update dbo.Person set EmailPromotion += 3;
update dbo.Person set EmailPromotion -= 3;

exec sp_spaceused N'dbo.Person';
exec sp_spaceused N'[cdc].[dbo_Person_CT]';
SELECT * FROM sys.dm_cdc_log_scan_sessions;

--W sumie "nic" nie robimy podczas UPDATE
update dbo.Person set EmailPromotion = EmailPromotion;
--Rezultat:  Inteligentne zachowanie - brak dodatkowych wpis�w.
--�adne wpisy w tabeli zmian si� nie pojawi�y!
SELECT * FROM cdc.dbo_Person_CT;

--Jak to wygl�da w logu transakcyjnym?
update dbo.Person set EmailPromotion = EmailPromotion;
GO 10

--LOG RO�NIE!!!
--select * from sys.database_files;
DBCC SQLPERF(LOGSPACE);







with tlog as (select * from ::fn_dblog( default, default ) )
--SELECT COUNT(*) FROM tlog where Operation = 'LOP_MODIFY_ROW';
SELECT * FROM tlog;




--B��dy podczas skanowania:
SELECT * FROM sys.dm_cdc_errors;

--Gdy nie wszystkie s� przechwytywane mo�emy wy�wietli� list� kolumn:
EXEC sys.sp_cdc_get_captured_columns N'dbo_Person';

--Sprawdzanie czy wybrana kolumna zosta�a zmodyfikowana:
select sys.fn_cdc_has_column_changed ('dbo_Person','LastName',0x0440);


--Database Mirroring & Log Shipping










