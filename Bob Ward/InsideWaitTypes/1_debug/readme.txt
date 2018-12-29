Demo instructions:

Show mavs.sql
Open delete_caron.sql to delete Caron from the starting lineup. Run it
Open insert_sean.sql to insert Sean Marion. Run it. It blocks
Break into the debugger and find the blocking thread by searching for LockOwner::Sleep

Here is the debugger command to use for public symbols:

windbg -y srv*c:\public_symbols*http://msdl.microsoft.com/download/symbols -pn sqlservr.exe
