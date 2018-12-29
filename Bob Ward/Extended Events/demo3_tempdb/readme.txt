1. Load up track_tempdb_session_usage.sql to show how we will track session usage
2. Load up get_alloc_ring_buffer.sql and talk about the ring buffer entries
3. Show the properties of the track_tempdb_usage XEvent session. Show how we will filter
on event 10 which is PFS page allocation.
4. Start the session
5. Load up fill_temp_table.sql and run it
6. Look at the session usage in pages
7. Now show the output of the targets. 
The file target just shows everything. 
The event_counter shows the total number of entries, but what query?
The histogram shows which query is using what number of pages
Go back to the file target and group by fileid. Notice file 1 has more allocation
Ask audience why?
8. Now load up sort_query.sql and show the session usage and xevent output of histogram