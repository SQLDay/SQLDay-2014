/*============================================================================
  Summary:  Demonstrates the Version Store
------------------------------------------------------------------------------
  Written by Klaus Aschenbrenner, SQLpassion.at

  (c) 2011, SQLpassion.at. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLpassion.at

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- Use the previous created database
USE VersionStoreDemo
GO

-- Begin a new transaction under RCSI.
-- This means that the Version Store prior the current XSN can't be cleaned up.
BEGIN TRANSACTION
	SELECT * FROM TestTable
	WHERE Column1 = 1
	
	SELECT * FROM sys.dm_tran_current_transaction
	
--COMMIT TRANSACTION