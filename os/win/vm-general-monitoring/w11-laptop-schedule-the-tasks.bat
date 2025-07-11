SCHTASKS /CREATE /TN "W11 Laptop Performance Trace" /XML "W11 Laptop Performance Trace - Scheduled Task.xml" /F
SCHTASKS /CREATE /TN "W11 Laptop Performance Trace Restart" /XML "W11 Laptop Performance Trace Restart - Scheduled Task.xml" /F
SCHTASKS /CREATE /TN "Zip Perfmon Logs" /XML "Zip Perfmon Logs - Scheduled Task.xml" /F
SCHTASKS /CREATE /TN "Remove old logs" /XML "Remove old logs - Scheduled Task.xml" /F

logman start "W11 Laptop Performance Trace"


