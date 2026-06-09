<#
.SYNOPSIS
    Prepare the Perfmon template for a specific server and instance.

.DESCRIPTION
    This script customizes a Performance Monitor XML template by replacing placeholders with the actual server name and instance name.

.PARAMETER ServerName
    The name of the VM to monitor.

.PARAMETER Template
	The path to the XML template file to use for the Perfmon configuration.

.PARAMETER LogRoot
	The root path to where to keep the scripts and logs. Path should be absolute.

.OUTPUTS
	The path to the newly created Perfmon template file.

.EXAMPLE
    $FileName = .\Prepare-PerfmonTemplate.ps1 -ServerName "MyServer" -Template ".\PerformanceMonitorTemplate_WindowsServer2022.xml"
#>

[CmdletBinding()]
param (
    [Parameter(Position = 0, Mandatory = $false, HelpMessage = "Specify the name of the VM to monitor. Leave empty to use the local computer name.")]
    [string] $ServerName,
    [Parameter(Position = 1, Mandatory = $true, HelpMessage = "Specify the path to the XML template file. Paths relative to the script location are supported.")]
	[string] $Template,
	[Parameter(Position = 2, Mandatory = $true, HelpMessage = "Specify the root path to where to keep the scripts and logs. Path should be absolute.")]
	[string] $LogRoot
)

# Prepare the Perfmon template
if ([string]::IsNullOrEmpty($ServerName))
{
	$ServerName = $env:computername
}
if ([string]::IsNullOrEmpty($InstanceName))
{
	$InstanceName = ""
}

$strarr = Get-Content $Template

for ( $i = 0; $i -lt $strarr.Length; $i++ )
{ 
	$strarr[$i] = ($strarr[$i] -replace "#SERVER#", $ServerName); 
	$strarr[$i] = ($strarr[$i] -replace "#LogRoot#", $LogRoot); 
}
$FilePrefix = $Servername

$NewTemplateFileName = "$FilePrefix-PerfmonTemplate.xml"
Set-Content -Path $NewTemplateFileName -Value $strarr
Write-Host "Prepared Perfmon template: $NewTemplateFileName from $Template"

return $NewTemplateFileName
