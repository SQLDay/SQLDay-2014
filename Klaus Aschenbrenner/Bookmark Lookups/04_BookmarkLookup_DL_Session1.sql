/*============================================================================
  Summary:  Demonstrates Bookmark Lookup Deadlocks
------------------------------------------------------------------------------
  Written by Klaus Aschenbrenner, SQLpassion.at

  For more scripts and sample code, check out 
    http://www.SQLpassion.at

  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE master
GO

CREATE DATABASE BookmarkLookupDL
GO

USE BookmarkLookupDL
GO

CREATE TABLE Deadlock
(
	Col1 INT NOT NULL PRIMARY KEY CLUSTERED,
	Col2 INT NOT NULL,
	Col3 INT NOT NULL
)
GO

CREATE NONCLUSTERED INDEX idx_Col3 ON Deadlock(Col3)
GO

INSERT INTO Deadlock VALUES (1, 1, 1)
GO

SELECT * FROM Deadlock
GO

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
GO

WHILE (1 = 1)
BEGIN
	UPDATE Deadlock
	SET Col1 = Col1 + 1
	WHERE Col3 = 1
END
GO