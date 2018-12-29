demo 1 – winbag_and_xe

Use windbg and public symbols to tour a SQL Server 
that has just started showing off some of the background threads. 
Notice that almost every thread starts win SQLDK.DLL and not SQLSERVR.EXE. 
Point out there is no “main” SQLOS thread instead SQLOS is infused into all threads.

Bring up sqlos_xe.sql to show how to find all XEvent types for sqlos. 
The SQLOS types are in a separate packaged called sqlos
