# List modules and their versions


# DSC
#$moduleNames = @("xPSDesiredStateConfiguration", "xActiveDirectory", "xNetworking", "xPendingReboot", "xStorage", "PSDscResources", "xDSCResourceDesigner") #PSDscResources
$moduleNames = @("xDSCResourceDesigner")
#$moduleNames = @("AzureRM.Automation", "AzureRM.Compute", "AzureRM.Network", "AzureRM.Profile", "AzureRM.Resources", "AzureRM.Storage")
#$moduleNames = @("AzureRM.Storage")
#$moduleNames = @("AzureRM.Compute")
#$moduleNames = @("AzureRM.Resources")
#$moduleNames = @("AzureRM.Network")
#$moduleNames = @("AzureRM.KeyVault")
#$moduleNames = @("AzureRM.OperationalInsights")
#$moduleNames = @("Azure")
#$moduleNames = @("MSOnline")
#$moduleNames = @("Microsoft.PowerShell.Utility")

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


#
#Install-Module Azure
#
#Find-Module -Name Azure
#Get-Module -Name Azure -ListAvailable
#Update-Module -Name Azure -RequiredVersion 4.0.1 -Force
#
#
#
#
#
#
#Get-Module -ListAvailable
## AzureRM.Profile
#
#
#
## Update the modules that needs to be updated (continued from above)
#
#ForEach ($moduleName in $moduleNames)
#{
#    $currentModule = (Get-Module -Name $moduleName)
#    $newestModule = (Find-Module -Name $moduleName)
#
#    if ( $currentModule.Version -eq $newestModule.Version )
#    {
#        Write-Output $moduleName + " does not need an upgrade."
#    }
#    else
#    {
#        Write-Output $moduleName + " starting upgrade to " + $newestModule.Version + "."
#        Update-Module -Name $moduleName -Force
#    }
#
#}
#Get-Module
#Remove-Module -Name AzureRM.Profile
#Install-Module AzureRM.Compute -RequiredVersion 2.5.0 -Force
#Install-Module AzureRM.Network -RequiredVersion 3.4.0 -Force  
#Install-Module AzureRM.Storage -RequiredVersion 2.5.0 -Force 
#
#Install-Module AzureRM.Profile -RequiredVersion 2.5.0
#Install-Module AzureRM.Resources -RequiredVersion 3.5.0
#Install-Module Azure -RequiredVersion 3.4.0 -AllowClobber
#Install-Module AzureRM.Automation -RequiredVersion 2.5.0
#Install-Module AzureRM.Compute -RequiredVersion 2.5.0
#
#Get-Module -Name AzureRM.Profile -All
#Uninstall-Module -Name AzureRM.Profile -RequiredVersion 2.3.0
#Uninstall-Module -Name AzureRM.Resources -RequiredVersion 3.2.0
#Uninstall-Module -Name Azure -RequiredVersion 3.0.0
#Uninstall-Module -Name AzureRM.Automation -RequiredVersion 2.2.0
#
##Name               Current Version Newest Version Needs upgrade
##----               --------------- -------------- -------------
##AzureRM.Profile    2.3.0           2.5.0                   True
##AzureRM.Resources  3.3.0           3.5.0                   True
##Azure              3.1.0           3.4.0                   True
##AzureRM.Automation 2.3.0           2.5.0                   True
#
#Remove-Module -Name AzureRM.Profile
#Remove-Module -Name Azure
#Remove-Module -Name AzureRM.Resources
#Remove-Module -Name AzureRM.Storage
#
#Get-Module -Name AzureRM.Profile
#Find-Module -Name AzureRM.Profile -AllVersions
#Uninstall-Module -Name AzureRM.Profile -RequiredVersion 2.3.0
#Install-Module -Name AzureRM.Profile -RequiredVersion 2.2.0
#
#Uninstall-Module -Name AzureRM.Profile -RequiredVersion 2.2.0
#Uninstall-Module -Name AzureRM.Storage -RequiredVersion 2.3.0
#Uninstall-Module -Name AzureRM.Resources -RequiredVersion 3.2.0
#Uninstall-Module -Name AzureRM.Automation -RequiredVersion 2.2.0
#Uninstall-Module -Name Azure -RequiredVersion 3.0.0
#
#
#Install-Module -Name AzureRM.Profile
#Install-Module -Name AzureRM.Storage -AllowClobber
#Install-Module -Name AzureRM.Resources -AllowClobber
#Install-Module -Name AzureRM.Automation -AllowClobber
#Install-Module -Name AzureRM.Compute -AllowClobber
#
#Install-Module -Name Azure -AllowClobber
#
#
#Find-Module -Name AzureRm.Storage -AllVersions
#
#Get-Module Azure* -ListAvailable
#Get-Module Azure* -ListAvailable | Uninstall-Module
#
#Uninstall-Module Azure
#Uninstall-Module AzureRm
#Uninstall-Module Azure.Storage
#
#Login-AzureRmAccount
#$subscriptionId = 
#    ( Get-AzureRmSubscription |
#        Out-GridView `
#          -Title "Select an Azure Subscription …" `
#          -PassThru
#    ).SubscriptionId
#
#Get-AzureRmSubscription -SubscriptionId $subscriptionId | Select-AzureRmSubscription
#Get-AzureRmStorageAccount
#
#Install-Module AzureRm
#Install-Module Azure -AllowClobber
#
#
#
#
#Uninstall-Module AzureRM.Compute -RequiredVersion 2.5.0 -Force
#
#Uninstall-Module AzureRM.Compute -Force
#Install-Module AzureRM.Network -RequiredVersion 3.5.0 -Force -AllowClobber
#