
/*
  USE master
  DROP DATABASE BackupTest
*/

CREATE DATABASE BackupTest
GO

USE BackupTest
GO

CREATE TABLE Users (ID int, Name varchar(50))
GO

INSERT INTO Users VALUES (1, 'Kowalski')

BACKUP DATABASE BackupTest TO DISK = 'D:\SQLServer_BACKUP\BackupTest.bak' 
WITH INIT, FORMAT, NAME = 'BackupTest-Full Database Backup', NO_COMPRESSION
GO



-- Backup encryption
USE master
GO



CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Pa$$w0rd'
GO

CREATE CERTIFICATE BackupCert
WITH SUBJECT = 'Backup Encryption Certificate'
GO


BACKUP CERTIFICATE BackupCert TO FILE = 'D:\SQLServer_BACKUP\BackupCert.dat'
WITH PRIVATE KEY
(
  ENCRYPTION BY PASSWORD = 'Pa$$w0rd',
  FILE = 'D:\SQLServer_BACKUP\BackupCert_PrivateKey.dat'
)




BACKUP DATABASE BackupTest TO  DISK = 'D:\SQLServer_BACKUP\BackupTestEncrypt.bak' 
WITH FORMAT, INIT, NAME = 'BackupTest-Full Database Encrypted Backup', STATS = 10,
ENCRYPTION(ALGORITHM = AES_128, SERVER CERTIFICATE = [BackupCert])
GO


-- Failed - Appended backup is not supported
BACKUP DATABASE BackupTest TO  DISK = 'D:\SQLServer_BACKUP\BackupTestEncrypt.bak' 
WITH NOFORMAT, NOINIT, NAME = 'BackupTest-Full Database Encrypted Backup #2', STATS = 10,
ENCRYPTION(ALGORITHM = AES_128, SERVER CERTIFICATE = [BackupCert])
GO




SELECT b.backup_set_id, b.name, b.key_algorithm, b.encryptor_thumbprint, b.encryptor_type,
	 bm.is_password_protected, bm.is_compressed, bm.is_encrypted
FROM msdb.dbo.backupset AS b
JOIN msdb.dbo.backupmediaset AS bm ON bm.media_set_id = b.media_set_id
WHERE backup_start_date > DATEADD(MINUTE, -10, GETDATE())
GO



-- SQLEXPRESS....

-- without key
RESTORE DATABASE BackupTest 
FROM  DISK = 'D:\SQLServer_BACKUP\BackupTestEncrypt.bak' WITH  FILE = 1, 
MOVE N'BackupTest' TO N'D:\SQLServer_DATA\EXPR_BackupTest.mdf',  
MOVE N'BackupTest_log' TO N'D:\SQLServer_DATA\EXPR_BackupTest_log.ldf',
REPLACE,  STATS = 5
GO


CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Ala123'
GO


CREATE CERTIFICATE BackupCert FROM FILE = 'D:\SQLServer_BACKUP\BackupCert.dat'
WITH PRIVATE KEY
(
FILE = 'D:\SQLServer_BACKUP\BackupCert_PrivateKey.dat',
DECRYPTION BY PASSWORD = 'Pa$$w0rd' 
)


USE master
GO

RESTORE DATABASE BackupTest 
FROM  DISK = 'D:\SQLServer_BACKUP\BackupTestEncrypt.bak' WITH  FILE = 1, 
MOVE N'BackupTest' TO N'D:\SQLServer_DATA\EXPR_BackupTest.mdf',  
MOVE N'BackupTest_log' TO N'D:\SQLServer_DATA\EXPR_BackupTest_log.ldf',
REPLACE,  STATS = 5




BACKUP DATABASE BackupTest TO  DISK = 'D:\SQLServer_BACKUP\EXRP_BackupTestEncrypt.bak' 
WITH FORMAT, INIT, NAME = 'BackupTest-Full Database Encrypted Backup', STATS = 10,
ENCRYPTION(ALGORITHM = AES_128, SERVER CERTIFICATE = [BackupCert])
GO



SELECT * FROM sys.configurations WHERE name LIKE '%checksum%'





/*
  
  Cleanup 

*/
	DROP CERTIFICATE BackupCert
	DROP MASTER KEY
	GO

	USE master
	GO
	DROP DATABASE BackupTest
	GO

