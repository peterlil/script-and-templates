<#
.SYNOPSIS
    Creates a perfmon trace from a template. 

.DESCRIPTION
    This script creates a Data Collector Set (DCS) for performance monitoring using a specified XML template.
    If a DCS with the same name exists, it is deleted before creating a new one.

.PARAMETER Name
    The name of the Data Collector Set to create.

.PARAMETER Template
    The path to the XML template file to use for the DCS.

.EXAMPLE
    .\Create-PerfmonTrace.ps1 -ServerName "MyServer" -InstanceName "MyInstance" -Template ".\SERVERNAME_INSTANCENAME-PerformanceMonitorTemplate.xml"
#>

[CmdLetBinding()]
param (
    [Parameter(Position = 0, HelpMessage = "Specify the name of the Data Collector Set.")]
    [string] $Name,
    [Parameter(Position = 1, HelpMessage = "Specify the path to the XML template file. Paths relative to the script location are supported.")]
    [string] $Template
)

try {
    
    # If a DCS with the same name exists, delete it (optional safety)
    Write-Host "Checking for existing Data Collector Set '$Name'..."
    if (logman query $Name *>$null) {
        logman stop $Name *>$null
        logman delete $Name
    }

    # Import from template and create the new DCS
    logman import -n $Name -xml $Template
    Write-Host "Data Collector Set '$Name' created successfully from template '$Template'."
}
catch {
    Write-Host "An error occurred: $_"
}

