param ([string] $Servername, [string] $Template = "PerformanceMonitorTemplate_WindowsServer2012.xml")
Write-Host "Loading $Template"
$strarr = Get-Content $Template
Write-Host "Replacing the servername placeholder with $Servername."
for ( $i = 0; $i -lt $strarr.Length; $i++ )
{ 
	$strarr[$i] = ($strarr[$i] -replace "#SERVER#", $ServerName); 
}
Write-Host "Writing output as $Servername-PerfmonTemplate.xml"
Set-Content -Path ($Servername + "-PerfmonTemplate.xml") -Value $strarr