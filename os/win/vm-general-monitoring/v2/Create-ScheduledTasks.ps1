<#
.SYNOPSIS
    Creates and starts SQL Server Performance Analyzer scheduled tasks, appending the instance name to each task.

.DESCRIPTION
    This script creates several scheduled tasks for SQL Server Performance Analyzer monitoring, zipping logs, and cleaning up old logs.
    The SQL Server instance name is supplied as a parameter and appended to each scheduled task name.
    The script also starts the associated Perfmon log.
    Before creating each scheduled task, the script creates a copy of the XML file with $InstanceName replaced appropriately.

.PARAMETER InstanceName
    The name of the SQL Server instance to append to each scheduled task.

.EXAMPLE
    .\Create-ScheduledTasks.ps1 -InstanceName "MSSQLSERVER"
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0, HelpMessage = "Specify the SQL Server instance name.")]
    [string]$InstanceName
)

function Copy-And-PrepareXml {
    <#
    .SYNOPSIS
        Copies the XML file and replaces $InstanceName with the appropriate value.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$XmlFile,
        [Parameter(Mandatory = $true)]
        [string]$InstanceName
    )
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($XmlFile)
    $ext = [System.IO.Path]::GetExtension($XmlFile)
    $suffix = if ($InstanceName) { $InstanceName } else { '$' }
    $newFile = "$baseName-$suffix$ext"

    $replaceValue = if ($InstanceName) { " - $InstanceName" } else { "" }
    $content = Get-Content $XmlFile -Raw
    $content = $content -replace '\$InstanceName', $replaceValue
    Set-Content -Path $newFile -Value $content

    return $newFile
}

function ScheduledTask-Exists {
    param (
        [Parameter(Mandatory = $true)]
        [string]$TaskName
    )
    $task = SCHTASKS /Query /TN "$TaskName" 2>$null
    return $LASTEXITCODE -eq 0
}

function Create-InstanceTask {
    param (
        [string]$TaskBaseName,
        [string]$XmlFile
    )
    $TaskName = if ($InstanceName) { "$TaskBaseName - $InstanceName" } else { $TaskBaseName }
    Write-Host "Preparing XML for scheduled task: $TaskName"
    $PreparedXmlFile = Copy-And-PrepareXml -XmlFile $XmlFile -InstanceName $InstanceName
    Write-Host "Creating scheduled task: $TaskName using $PreparedXmlFile"
    SCHTASKS /CREATE /TN "$TaskName" /XML "$PreparedXmlFile" /F
}

try {
    # Create all instance-specific scheduled tasks
    Create-InstanceTask -TaskBaseName "VM Performance Trace" -XmlFile "VM Performance Trace - Scheduled Task.xml"
    Create-InstanceTask -TaskBaseName "VM Performance Trace Restart" -XmlFile "VM Performance Trace Restart - Scheduled Task.xml"
    Create-InstanceTask -TaskBaseName "Zip Perfmon Logs" -XmlFile "Zip Perfmon Logs - Scheduled Task.xml"
    Create-InstanceTask -TaskBaseName "Remove old logs" -XmlFile "Remove old logs - Scheduled Task.xml"

    # Start the Perfmon log for the specified instance
    $PerfmonName = if ($InstanceName) { "VM Performance Trace - $InstanceName" } else { "VM Performance Trace" }
    Write-Host "Starting Perfmon log: $PerfmonName"
    logman start "$PerfmonName"
}
catch {
    Write-Error "An error occurred: $_"
}