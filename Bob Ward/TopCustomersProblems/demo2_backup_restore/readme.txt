1. Show errorlog_os_error_64.txt for example error. 
Note that in many cases this error occurs during the backup which indicates a problem with network
writing/reading
2. Show errorlog_vdi_error.txt for example error. This error is almost always the VDI application
aborting the backup during the request. This is not a SQL Server problem so you should first work
with your VDI vendor.
3. Now run backup_the_bears.sql (restore the original from this directory first)
4. Go to the temp directly, bring up the file with list.exe. Go to offset 001024C0, hack it and save
5. Load up restore_verifyonly.sql and run the steps in the script