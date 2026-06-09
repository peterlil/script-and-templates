<#
.SYNOPSIS
    Copies the scripts for compressing and removing old log files to the specified log root folder.

.DESCRIPTION
    Copies the scripts for compressing and removing old log files to the specified log root folder.

.PARAMETER LogRoot
    The root path to where to keep the scripts and logs. Path should be absolute.

.EXAMPLE
    .\copy-scripts.ps1 -LogRoot "C:\PerfLogs"
#>

[CmdletBinding()]
param (
    [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Specify the root path to where to keep the scripts and logs. Path should be absolute.")]
    [string] $LogRoot
)

$destPath = Join-Path -Path $LogRoot -ChildPath "zip-logs.ps1"
Copy-Item zip-logs.ps1 $destPath

Write-Host "File 'zip-logs.ps1' copied to $destPath"

$destPath = Join-Path -Path $LogRoot -ChildPath "remove-old-logs.ps1"
Copy-Item remove-old-logs.ps1 $destPath

Write-Host "File 'remove-old-logs.ps1' copied to $destPath"