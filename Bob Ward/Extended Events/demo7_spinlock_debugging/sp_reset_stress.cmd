set SERVERNAME=tcp:.

# ".\Debuggers\X64\Kill.exe" /f HoldOpenConnections.exe
start "Hold Conns" HoldOpenConnections.exe "%SERVERNAME%;Database=ResetTestDB" 12000

sleep 60

ostress -dResetTestDB -UTest -P"B&K2Replay" -S"%SERVERNAME%" -Q"{call sp_reset_connection()}" -o".\Output_sp_reset_stress" -n100 -r100000 -l120
