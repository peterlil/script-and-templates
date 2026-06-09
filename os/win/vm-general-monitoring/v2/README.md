# Setting up VP Performance Trace

## Windows Server 2022 - using the monitoring defaults

1. Extract all files in the zip archive to a folder, for example `C:\temp`.
2. Start *PowerShell* as an administrator.
3. Type `cd C:\temp` and press *Enter*.
4. Type `Set-ExecutionPolicy RemoteSigned -Force` and press *Enter*.
5. Run this.
    ```powershell
    .\Setup-Monitoring.ps1 -LogRoot <PathToLogRoot>
    ```
    Note: LogRoot is the root folder where you want the logs, ex: C:\PerfLogs
    
Done.


## Full sample

```powershell
cd C:\temp

Get-ExecutionPolicy

Set-ExecutionPolicy RemoteSigned -Force

.\Setup-Monitoring.ps1 -LogRoot 'C:\PerfLogs' -Template 'PerformanceMonitorTemplate_WindowsServer2022.xml'
```