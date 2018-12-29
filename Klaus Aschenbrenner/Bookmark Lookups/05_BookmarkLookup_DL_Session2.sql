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

USE BookmarkLookupDL
GO

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
GO

WHILE (1 = 1)
BEGIN
	SELECT * FROM Deadlock WITH (INDEX(idx_Col3)) -- Hint is necessary to overcome the Tipping Point, and to produce a Bookmark Lookup
	WHERE Col3 = 1
END
GO