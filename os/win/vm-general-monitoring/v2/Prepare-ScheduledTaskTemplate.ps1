<#
.SYNOPSIS
    Prepare the scheduled task template by replacing server name and instance name accordingly and creating the final XML file with standardized name.

.DESCRIPTION
	This script customizes a Scheduled Task XML template by replacing placeholders with the actual instance name.
	It creates a new XML file with the instance name appended to the base filename.
    
.PARAMETER ServerName
    The name of the VM to monitor. Leave empty to use the local computer name.

.PARAMETER Template
	The path to the XML template file to prepare.

.PARAMETER LogRoot
	The root path to where to keep the scripts and logs. Path should be absolute.

.OUTPUTS
	The path to the newly created Scheduled Task template file.

.EXAMPLE
    $FileName = .\Prepare-ScheduledTaskTemplate.ps1 -ServerName "MyServer" -Template ".\ScheduledTaskTemplate.xml"
#>

[CmdletBinding()]
param (
	[Parameter(Position = 0, Mandatory = $false, HelpMessage = "Specify the name of the VM to monitor. Leave empty to use the local computer name.")]
	[string] $ServerName,
	[Parameter(Position = 1, Mandatory = $false, HelpMessage = "Specify the path to the XML template file. Paths relative to the script location are supported.")]
	[string] $Template,
	[Parameter(Position = 2, Mandatory = $false, HelpMessage = "Specify the root path to where to keep the scripts and logs. Path should be absolute.")]
	[string] $LogRoot
)

# Prepare the Perfmon template
if ([string]::IsNullOrEmpty($ServerName))
{
	$ServerName = $env:computername
}

# Get the filename from the template path
$Filename = [System.IO.Path]::GetFileName($Template)

# Prepare the templates for the Scheduled Tasks
$strarr = Get-Content $Template

for ( $i = 0; $i -lt $strarr.Length; $i++ )
{ 
	$strarr[$i] = ($strarr[$i] -replace "#LogRoot#", $LogRoot).TrimEnd();
}

$FilePrefix = "$Servername-"

Set-Content -Path "${FilePrefix}${Filename}" -Value $strarr
Write-Host "Prepared Scheduled Task template: ${FilePrefix}${Filename} from $Template"

return "${FilePrefix}${Filename}"
