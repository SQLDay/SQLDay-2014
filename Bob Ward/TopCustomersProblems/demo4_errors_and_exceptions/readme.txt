1. Open up the system health XEL files and show error_reported events, sp_server_diagnostics_event,
and deadlock event. Add the xml_report column to the grid and double-click on it. Save the .xml file
to and .xdl file and open it in SSMS to show the graphical deadlock view. error_reported XEvent is a way
for you to find out the query or get a stack dump for any error.
2. Open up errorlog.assert_and_av and walk through dumps. Here is an example of an assertion followed by
AV. The AV in this case is just a "victim" of the assertion. The assertion is the main thing to focus
on
3. Go to the LOG directory and show the various .mdmp, .log, and .txt files. Open up the .log files
to show the various type of problems on this machine including non-yielding and latch timeouts.
SQLDump0001.log has a non-yielding scheduler example. sqldump0021.log has a latch timeout example.