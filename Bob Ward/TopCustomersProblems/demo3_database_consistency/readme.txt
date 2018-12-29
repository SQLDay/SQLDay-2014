1. Go through commands in themavs.sql
2. Use hex editor to change bits on the page you found. You need to multiply the page number * 8192,
convert to hex. Then in list.exe hit F2 for offst and put in that hex number. You are at byte 0 of
that database page. Change some bytes, esc, and save
3. Restart SQL Server
4. Open up whowillwinthenbaplayoff.sql and go through steps
5. Look at ERRORLOG for symptoms of the problem
6. Use SSMS to restore the bad page
7. Notice the truncate has finished
