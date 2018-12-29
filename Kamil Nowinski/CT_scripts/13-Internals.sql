USE ChangeTracking
GO


---------------------------------------------
-- INTERNALS
---------------------------------------------


--If you never enabled change tracking on the database, then the DMV is empty.
select * from sys.dm_tran_commit_table   --43
order by commit_time
/*
commit_ts:	A monotonically increasing number that serves as a database-specific timestamp for each committed transaction.
xdes_id:	A database-specific internal ID for the transaction.
commit_lbn: The number of the log block that contains the commit log record for the transaction.
commit_csn: The instance-specific commit sequence number for the transaction.
commit_time: The time when the transaction was committed.
*/


--Since it is an internal table, it can only be viewed in DAC connection. [ http://technet.microsoft.com/pl-pl/library/ms178068(v=sql.105).aspx ]
select OBJECT_ID('dbo.Person');
select * from sys.[change_tracking_245575913]; 

/*
Here are the columns of the table:
sys_change_xdes_id: Transaction ID of the transaction that modified the row.
sys_change_xdes_id_seq: Sequence identifier for the operation within the transaction.
sys_change_operation: Type of operation that affected the row: insert, update, or delete.
sys_change_columns: List of which columns were modified (used for updates, only if column tracking is enabled).
sys_change_context: Application-specific context information provided during the DML operation using the WITH CHANGE_ TRACKING_CONTEXT option.
k_[name]_[ord]: Primary key column(s) from the target table. [name] is the name of the primary key column, [ord] is the ordinal position in the key, and [type] is the data type of the column.
*/


--Iloœæ zajmowanego miejsca przez mechanizm dla tabeli:
EXEC sp_spaceused 'sys.change_tracking_245575913';
EXEC sp_spaceused 'sys.syscommittab';


--Wrzucimy trochê danych
INSERT INTO [dbo].[Person]
([BusinessEntityID],[FirstName],[LastName],[NationalIDNumber],[LoginID],[JobTitle],[BirthDate],[MaritalStatus])
SELECT [BusinessEntityID],[FirstName],[LastName], '8457383495', 'kamil@nowinski.net', 'Senior Software Developer/DBA', ModifiedDate, '-'
from [AdventureWorks2012].[Person].[Person] where [BusinessEntityID] > 20
GO

EXEC sp_spaceused 'dbo.Person';
EXEC sp_spaceused 'sys.change_tracking_245575913';


------------------------------------------------------------------------------------
-- Jak sprawdziæ jakiego typu kolumny zawiera tabela systemowa? Zrobiæ kopiê :)
------------------------------------------------------------------------------------
select TOP 5 * 
into dbo.[change_tracking_245575913]
from sys.[change_tracking_245575913];
GO

