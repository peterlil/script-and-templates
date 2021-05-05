# HOWTO
#
# First you need to uninstall Azure PowerShell modules that has been installed by other means than through PowerShell (i.e. msi packages and installation program):
# 1. Open "Add or remove programs" in Windows 10.
# 2. Search for "Azure". 
# 3. If you found "Azure PowerShell" in the list, uninstall it.
#
# Secondly, install the modules you want by using this script:
# 1. Open PowerShell ISE in an elevated mode.
# 2. Open this file in the PowerShell ISE editor.
# 3. Uncomment or write the right line below so you populate the moduleNames array with the names of the modules you want to install.
# 4. Run the complete script. NOTE: THIS WILL NOT MAKE ANY CHANGES TO YOUR SYSTEM, it will only:
#    - Look for installed versions of the modules you are interested in.
#    - Look for the latest available version of the modules and compare.
#    - Output the status of installed modules
#    - Output Install-commands for all modules
#    - Output Update-commands for all modules. 
# 5. Review what modules you are completely missing, copy the install-command for those to a new file.
# 6. Review what modules you need to update, copy the update-command for those to the new file.
# 7. Run the commands in the new file. 
# 8. Done.



# List modules and their versions.

# Totti
#$moduleNames = @("Az") 

#More granular
#$moduleNames = @("Az.Compute", "Az.Accounts", "Az.Storage", "Az.Resources", "Az.Compute", "Az.Sql", "Az.Network", "Az.KeyVault", "Az.Peering", "MSOnline", "AzureAD")


# Find all Az-modules
Find-Module -Name Az.*

# Uninstall all AzureRm-modules
#Get-Module -Name AzureRm.* -ListAvailable | Uninstall-Module -Force

#$moduleNames = @("MSOnline")
#$moduleNames = @("Microsoft.PowerShell.Utility")
#$moduleNames = @("AzureAD")
#$moduleNames = @("Az")

# Modules for Desired State Configuration
#$moduleNames = @("xPSDesiredStateConfiguration", "xActiveDirectory", "xNetworking", "xPendingReboot", "xStorage", "PSDscResources", "xDSCResourceDesigner") #PSDscResources
#$moduleNames = @("xDSCResourceDesigner")


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

    $moduleVersionListItem | Add-Member -MemberType noteProperty -Name "InstallCmd" `
        -Value "Install-Module $moduleName -RequiredVersion $($newestModule.Version) -Force"
    $moduleVersionListItem | Add-Member -MemberType noteProperty -Name "UpdateCmd" `
        -Value "Update-Module $moduleName -RequiredVersion $($newestModule.Version) -Force"

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


