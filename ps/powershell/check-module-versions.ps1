# List modules and their versions


# DSC
#$moduleNames = @("xPSDesiredStateConfiguration", "xActiveDirectory", "xNetworking", "xPendingReboot", "xStorage", "PSDscResources", "xDSCResourceDesigner") #PSDscResources
#$moduleNames = @("xDSCResourceDesigner")
$moduleNames = @("AzureRM.Automation", "AzureRM.Compute", "AzureRM.Network", "AzureRM.Profile", "AzureRM.Resources", "AzureRM.Storage", "AzureRM.KeyVault", "AzureRM.OperationalInsights", "AzureRM.Insights", "Azure", "MSOnline", "AzureAD")
$moduleNames = @("AzureRM.Billing")
#$moduleNames = @("AzureRM.Storage")
#$moduleNames = @("AzureRM.Compute")
#$moduleNames = @("AzureRM.Resources")
#$moduleNames = @("AzureRM.Network")
#$moduleNames = @("AzureRM.KeyVault")
#$moduleNames = @("AzureRM.OperationalInsights")
#$moduleNames = @("Azure")
#$moduleNames = @("MSOnline")
#$moduleNames = @("Microsoft.PowerShell.Utility")
#$moduleNames = @("AzureAD")

# Most common Azure
#$moduleNames = @("AzureRM.Automation", "AzureRM.Compute", "AzureRM.Network", "AzureRM.Profile", "AzureRM.Resources", "AzureRM.Storage", "AzureRM.KeyVault", "Azure", "MSOnline")

$moduleVersionList = @()
ForEach ($moduleName in $moduleNames)
{
    $currentModule = (Get-Module -Name $moduleName -ListAvailable)
    $newestModule = (Find-Module -Name $moduleName)

    $moduleVersionListItem = new-Object -typename System.Object
    $moduleVersionListItem | Add-Member -MemberType noteProperty -Name "Name" -Value $moduleName
    $moduleVersionListItem | Add-Member -MemberType noteProperty -Name "Installed" -Value $currentModule.Version
    $moduleVersionListItem | Add-Member -MemberType noteProperty -Name "Newest" -Value $newestModule.Version
    
    if ( $currentModule.Version -eq $newestModule.Version )
    {
        $moduleVersionListItem | Add-Member -MemberType noteProperty -Name "NeedsUpgrade" -Value $false
    }
    else
    {
        $moduleVersionListItem | Add-Member -MemberType noteProperty -Name "NeedsUpgrade" -Value $true
    }

    if ( $moduleName -eq "Azure" ) {
        $moduleVersionListItem | Add-Member -MemberType noteProperty -Name "InstallCmd" `
            -Value "Install-Module $moduleName -RequiredVersion $($newestModule.Version) -Force -AllowClobber"
        $moduleVersionListItem | Add-Member -MemberType noteProperty -Name "UpdateCmd" `
            -Value "Update-Module $moduleName -RequiredVersion $($newestModule.Version) -Force"
    }
    else {
        $moduleVersionListItem | Add-Member -MemberType noteProperty -Name "InstallCmd" `
            -Value "Install-Module $moduleName -RequiredVersion $($newestModule.Version) -Force"
        $moduleVersionListItem | Add-Member -MemberType noteProperty -Name "UpdateCmd" `
            -Value "Update-Module $moduleName -RequiredVersion $($newestModule.Version) -Force"
    }    
    $moduleVersionList += $moduleVersionListItem
}

$a = @{Expression={$_.Name};Label="Name";width=20}, `
    @{Expression={$_.Installed};Label='Installed';width=20}, `
    @{Expression={$_.Newest};Label='Newest';width=10}, `
    @{Expression={$_.NeedsUpgrade};Label='NeedsUpgrade';width=12}, `
    @{Expression={$_.InstallCmd};Label='InstallCmd';width=80}, `
    @{Expression={$_.UpdateCmd};Label='UpdateCmd';width=80}
    
$moduleVersionList | ft $a -Wrap

$a =@{Expression={$_.InstallCmd};Label='InstallCmd';width=80}
$moduleVersionList | ft $a -Wrap

$a =@{Expression={$_.UpdateCmd};Label='UpdateCmd';width=80}
$moduleVersionList | ft $a -Wrap


