-- cleanup and start afresh
USE master;
GO

IF DB_ID('AdventureWorks2012') IS NOT NULL
BEGIN;
	ALTER DATABASE AdventureWorks2012 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE AdventureWorks2012;
END;

RESTORE DATABASE AdventureWorks2012
	FROM Disk = 'AdventureWorks2012.bak';
ALTER AUTHORIZATION ON Database::AdventureWorks2012 TO sa;
GO

-----

IF EXISTS(SELECT * FROM sys.server_audit_specifications WHERE name='SampleServerAuditSpec')
BEGIN;
	ALTER SERVER AUDIT SPECIFICATION SampleServerAuditSpec WITH (STATE = OFF);
	DROP SERVER AUDIT SPECIFICATION SampleServerAuditSpec;
END;

IF EXISTS(SELECT * FROM sys.server_audits WHERE name='SampleServerAudit')
BEGIN;
	ALTER SERVER AUDIT SampleServerAudit WITH (STATE = OFF);
	DROP SERVER AUDIT SampleServerAudit;
END;

-- delete old log files
EXEC sp_configure 'show advanced options',1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell',1;
RECONFIGURE;
GO

EXEC xp_cmdshell 'del /s /q c:\Audits\*';
GO

--------------

CREATE SERVER AUDIT SampleServerAudit TO FILE (
	FILEPATH = 'c:\Audits\',
	MAXSIZE = 100 MB,
    MAX_ROLLOVER_FILES = 100,
    RESERVE_DISK_SPACE = OFF
) WITH (
    QUEUE_DELAY = 1000,
    ON_FAILURE = CONTINUE,
    AUDIT_GUID = '8019CFA6-CE9F-42E9-B632-FFC5875B6697'
);

ALTER SERVER AUDIT SampleServerAudit WITH (STATE = ON);
GO

-- audit specification for interesting server-level events
CREATE SERVER AUDIT SPECIFICATION SampleServerAuditSpec
	FOR SERVER AUDIT SampleServerAudit
	ADD (AUDIT_CHANGE_GROUP),
	ADD (BACKUP_RESTORE_GROUP),
	ADD (DATABASE_CHANGE_GROUP),
	ADD (DATABASE_OBJECT_CHANGE_GROUP),
	ADD (USER_DEFINED_AUDIT_GROUP)
WITH (STATE = ON);
GO

USE AdventureWorks2012;
GO

-- audit specification for interesting database-level events
CREATE DATABASE AUDIT SPECIFICATION AWDatabaseAuditSpec
	FOR SERVER AUDIT SampleServerAudit
	ADD (INSERT, UPDATE, DELETE ON DATABASE::AdventureWorks2012 BY public)
WITH (STATE = ON);
GO


CREATE TABLE dbo.table1 (ID INT, VAL NVARCHAR(100));

INSERT INTO dbo.table1 VALUES 
	(1, N'Test 1'),
	(2, N'Test 2');

SELECT * FROM dbo.table1;

-- query the audit log, extended version
SELECT
    SWITCHOFFSET(CONVERT(DATETIMEOFFSET, af.event_time), 
                 DATENAME(TZOFFSET,SYSDATETIMEOFFSET())) AS LocalTime,
    aa.name AS ActionName, 
	ct.class_type_desc as class_type_desc,
	af.* 
FROM sys.fn_get_audit_file (
    (SELECT log_file_path FROM sys.server_file_audits
    WHERE name='SampleServerAudit') + '*.sqlaudit', 
    DEFAULT, DEFAULT) AS af 
JOIN (SELECT DISTINCT action_id, name FROM sys.dm_audit_actions) AS aa
    ON af.action_id=aa.action_id
JOIN sys.dm_audit_class_type_map AS ct
	ON af.class_type = ct.class_type
ORDER BY event_time, sequence_number;

-- values are not always available
DECLARE @ID INT = 3, @VAL NVARCHAR(100) = N'Test 3';
INSERT INTO dbo.table1 VALUES
	(@ID, @VAL);

-- write custom event
EXEC sys.sp_audit_write
	@user_defined_event_id = 123, 
	@succeeded = 1, 
	@user_defined_information = N'SQL Audit demo completed.';

