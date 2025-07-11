SCHTASKS /CREATE /TN "VM Performance Trace" /XML "VM Performance Trace - Scheduled Task.xml" /F
SCHTASKS /CREATE /TN "VM Performance Trace Restart" /XML "VM Performance Trace Restart - Scheduled Task.xml" /F
SCHTASKS /CREATE /TN "Zip Perfmon Logs" /XML "Zip Perfmon Logs - Scheduled Task.xml" /F
SCHTASKS /CREATE /TN "Remove old logs" /XML "Remove old logs - Scheduled Task.xml" /F

logman start "VM Performance Trace"


