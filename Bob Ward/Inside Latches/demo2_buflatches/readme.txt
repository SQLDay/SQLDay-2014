1. Bring up bufsandpages.sql and follow the comments in the script
2. Now let's attach the debugger and try to look at the BUF structure in memory (without using private symbols). The memory address of
the BUF is at the top of the DBCC PAGE output where it says BUF @<address>
3. Run dd <buf address>
4. Notice the first 8 bytes matches bpage from DBCC page (byte swapped)
4a. Now run dd <bpage address>
4b. This is the actual database PFS page in memory
5. Look for the blog value from DBCC PAGE
6. We need to go down 52 bytes from blog do run just "dd"
7. 52 bytes down is the start of the Latch class. This is actually 0x80 or 128 bytes from the start of the BUF structure. There is another way
to find this when there is BUF latch waiting. I'll show you that later.
8. Notice that most of the class appears to be 0 values. Why? That is because there is no waiters, no owner, and the latch class is 0.
9. 24 more bytes from the start of this is the Latch class ID. This value is 0x1c which in decimal is 28. What is this value? This ID
is the index into the list of latch classes in the code. This ID is actually the row value of sys.dm_os_latch_stats as it appears in default
order.
10. Run .detach from the debug comamnd window and q
11. Now run select * from sys.dm_os_latch_stats and find row 28. This is the BUFFER latch class which lines up that this latch class is associated
with the BUFFER for this PFS page.
