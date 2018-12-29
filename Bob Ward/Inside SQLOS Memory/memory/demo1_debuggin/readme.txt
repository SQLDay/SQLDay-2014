1a. Show breakpoints for VirtualAlloc

Make sure SQL Server is shutdown

. Start server from command line with windbg like this (from the context of the binn directory)

windbg -y srv*c:\public_symbols*http://msdl.microsoft.com/download/symbols sqlservr.exe -c -sMSSQLSERVER

. Set a breakpoint of the base allocator VirtualAlloc by typing

bp kernelbase!VirtualAlloc

. Now hit 'g' to start SQL Server

. When you see breakpoint hit, type in 'k' to get a call stack

The first call stack is SQLOS initializing itself to commit memory directly what the
"emergency allocator"

Hit 'g' again to go

The next breakpoint is directly allocating memory for the structure that supports the memory
node

. Now disable the first breakpoint by typing in 'bd 0'

and set a new one for sqldk!SOS_MemoryFragmentManager::ReplenishFragmentList64 by typing in

bp sqldk!SOS_MemoryFragmentManager::ReplenishFragmentList64

How hit 'g' again to go

This is a great stack to see how we are creating a memory object, which leads to page
allcoation, when lead to block allocation, which leads to creating the initial fragments.

Now type in 'be 0' to enable VirtualAlloc breakpoint and hit 'g'

This the stack of the fragment manager reserving our large reservation at startup

disable all breakpoints by typing in 'bd *'

. Lets show XEvent creating a memory object

bp sqldk!XE_Engine::InitializeMemorySubsystem

and hit 'g'

now re-enable VirtualAlloc by typing 'be 0' and hit 'g'

This is a good stack of creating a memory object, allocating pages, and then the block
allocator committing memory from the fragments already reserved. Note the call to
check for NUMA.

What can you tell about the memory model of SQL Server based on this stack?

Disable all breakpionts by typing in 'bd *'

Let's stop and restart SQL Server

1b. Run select * From sys.dm_os_virtual_address_dump and talk about region sizes and states 

1c. Run the vmmap.exe program from sysinternals

Show the size, committed size, locked size, and heap size. If earlier I said we were using
conventional why now do I see locked pages?
Restart SQL Server with -T835 and show it again. 
Why is locked still there? Large page support but not the large page model.

1d. Let's poke at the inside of a memory object

. Run this query

select * from sys.dm_os_memory_objects where type = 'MEMOBJ_SNIPACKETOBJECTSTORE'

. Copy the memory_object_address for the row with the largest pages_in_bytes

. Attach the debugger with this comamnd

windbg -y srv*c:\public_symbols*http://msdl.microsoft.com/download/symbols -pn sqlservr.exe

. Run this command to dump out any symbols found with this memory object address

dps <memory_object_address>

You should see the top address show something like qldk!CMemThread<CMemObj>::`vftable'
This is the virtual table for a CMemThread object and tells us this a thread safe
memory object

Let's see if we can find an actual input buffer in this memory object

Run this command on the memory object address

dd <memory_object_address>

About 0x50 bytes down there is something that appears to be a pointer (make sure to swap it)

It looks something like this

00000004`7700a0b0  68072000 00000004 00000000 00000000

So the pointer is 0000000468072000

Let's try to dump this out in byte format by running 

db 0000000468072000

Find what looks to be the start of the T-SQL statement and use du <address> to dump out the query

1e. Dump out the heaps 

Run the following command:

!heap -s

to dump out all of the heaps created in the process



