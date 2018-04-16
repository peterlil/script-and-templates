################################################################################
### Initial checks and preparations
################################################################################

# Make sure we are in the script dir...
$check = Get-Item -Path .\deploy-templates.ps1 -ErrorAction SilentlyContinue
if(!$check) {
    Write-Host "Error: The current directory needs to be the scripts directory. Terminating."
    #exit
    break
}

################################################################################
### Login to Azure. 
################################################################################
.\azure-ad\login-azurerm.ps1


################################################################################
### Set the variables for the script
### TODO: Carefully go through each variable and change to appropriate
###       values. 
### NOTE: DO NOT CHECK IN CLIENT SECRET ANYWHERE
################################################################################

# Location of the resources that are to be provisioned
$Location = 'West Europe'

# Name of the resource group, which the resources will go into
$ResourceGroupName = 'SurveyTest'

# Name of a storage account used during deployment. Only necessary if you are 
# using nested deployment templates or DSC. 
$DeployStorageAccount = 'peterlildeploywe'

# Name of the Azure Key Vault that will be created
$keyVaultName = 'mynewkv'

# Azure AD Application Name, this must be unique within your tenant
$aadAppDisplayName = "app-for-vm-encryption-$ResourceGroupName"

# Azure AD Application Client secret. KEEP THIS OUT OF SOURCE CONTROL
$aadClientSecret = '<YourJediMindTricksDoNotWorkOnMe>'

# Name of the key used to encrypt the VMs
#$vmEncryptionKeyName = 'vm-encryption-key'

# Name of the key encryption key
$keyEncryptionKeyName = 'vm-kek'

# Name of the VM that will be created
$vmName = 'gpuvmpeterlil2'

# Declaration of runtime variables, they are populated by the script
$aadClientId = ''
$aadServicePrincipalId = ''
$currentUserObjectId = ''


################################################################################
### Get hold of the JSON parameters for the network
################################################################################

$SolutionNetworkParams = ((Get-Content -Raw .\templates\azuredeploy.solution-network.parameters.json) | ConvertFrom-Json)
$solutionNwName = $SolutionNetworkParams.parameters.solutionNwName.value
$solutionSubnetName = $SolutionNetworkParams.parameters.solutionNwSubnet3Name.value

################################################################################
### Get the ObjectId of current user
################################################################################
$Sessions = Get-PSSession | Where-Object { $_.ConfigurationName -eq 'Microsoft.Exchange'}
$cred = Get-Credential -Message 'Enter the credentials for AAD'
if( $Sessions ){
    if ($Sessions -is [system.array] ) {
        $Session = $Sessions[0]
    } else {
        $Session = $Sessions
    }
} else {
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange `
        -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
        -Credential $cred -Authentication Basic -AllowRedirection
}

if ( !(Get-Command Connect-MsolService) ) {
    Import-PSSession $Session;
    Import-Module MSOnline;
}
Connect-MsolService -credential $cred
$currentUserObjectId = (Get-MsolUser -UserPrincipalName $cred.UserName).ObjectId


################################################################################
### Create a virtual network for the solution
################################################################################
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation $Location -ResourceGroupName $ResourceGroupName `
    -StorageAccountName $DeployStorageAccount -TemplateFile .\templates\azuredeploy.solution-network.json `
    -TemplateParametersFile .\templates\azuredeploy.solution-network.parameters.json

################################################################################
### Deploy a keyvault, first prepare the parameter file by replacing 
### #keyvaultname# and #objectIdOfUser# with values from the variables.
################################################################################

# Prepare the parameters file
$tempParameterFile = [System.IO.Path]::GetTempFileName()
((Get-Content -Path .\templates\azuredeploy.keyvault.parameters.json) -replace "#keyvaultname#", $keyVaultName) `
    -replace "#objectIdOfUser#", $currentUserObjectId | `
    Out-File $tempParameterFile

# Deploy
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation $Location -ResourceGroupName $ResourceGroupName `
    -StorageAccountName $DeployStorageAccount -TemplateFile .\templates\azuredeploy.keyvault.json `
    -TemplateParametersFile $tempParameterFile

# Prepare a keyvault for vm disk encryption
.\templates\vm-encryption-preparation.ps1 -aadClientSecret $aadClientSecret -keyVaultName $keyVaultName `
    -keyVaultResourceGroupName $ResourceGroupName -keyEncryptionKeyName $keyEncryptionKeyName `
    -appDisplayName $aadAppDisplayName -aadClientId ([ref]$aadClientId) -aadServicePrincipalId ([ref]$aadServicePrincipalId)

# Stop execution
exit


################################################################################
### OPTION: Deploy a standalone Windows VM
################################################################################
$userName = Read-Host 'Type admin user name:'
$tempParameterFile = [System.IO.Path]::GetTempFileName()
((Get-Content -Path .\templates\azuredeploy.standalone-vm.parameters.json) `
    -replace "#vmname#", $vmName `
    -replace "#vnetname#", $solutionNwName `
    -replace "#subnetname#", $solutionSubnetName `
    -replace "#adminusername#", $userName `
    -replace "#keyvaultname#", $keyVaultName `
    -replace "#keyvaultresourcegroup#", $ResourceGroupName `
    -replace "#aadClientID#", $aadClientId `
    -replace "#aadClientSecret#", $aadClientSecret ) | `
    Out-File $tempParameterFile
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation $Location -ResourceGroupName $ResourceGroupName `
    -TemplateFile .\templates\azuredeploy.standalone-vm.json -TemplateParametersFile $tempParameterFile 


################################################################################
### OPTION: Deploy a SQL dev VM
################################################################################
$userName = Read-Host 'Type admin user name:'
$tempParameterFile = [System.IO.Path]::GetTempFileName()
((Get-Content -Path .\templates\azuredeploy.standalone-sql-vm.parameters.json) `
    -replace "#vmname#", $vmName `
    -replace "#vnetname#", $solutionNwName `
    -replace "#subnetname#", $solutionSubnetName `
    -replace "#adminusername#", $userName `
    -replace "#keyvaultname#", $keyVaultName `
    -replace "#keyvaultresourcegroup#", $ResourceGroupName `
    -replace "#aadClientID#", $aadClientId `
    -replace "#aadClientSecret#", $aadClientSecret) | `
    Out-File $tempParameterFile
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation $Location -ResourceGroupName $ResourceGroupName `
    -TemplateFile .\templates\azuredeploy.standalone-sql-vm.json -TemplateParametersFile $tempParameterFile 



################################################################################
### OPTION: Deploy a centos Linux VM
################################################################################
$userName = Read-Host 'Type admin user name:'
$tempParameterFile = [System.IO.Path]::GetTempFileName()
((Get-Content -Path .\templates\azuredeploy.standalone-linux-centos-vm.parameters.json) `
    -replace "#vmname#", $vmName `
    -replace "#vnetname#", $solutionNwName `
    -replace "#subnetname#", $solutionSubnetName `
    -replace "#adminusername#", $userName ) | `
    Out-File $tempParameterFile
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation $Location -ResourceGroupName $ResourceGroupName `
    -TemplateFile .\templates\azuredeploy.standalone-linux-vm.json -TemplateParametersFile $tempParameterFile 


################################################################################
### OPTION: Deploy a standalone Windows VM with 32 disks
################################################################################
$userName = Read-Host 'Type admin user name:'
$tempParameterFile = [System.IO.Path]::GetTempFileName()
((Get-Content -Path .\templates\azuredeploy.standalone-vm-with-32-disks.parameters.json) `
    -replace "#vmname#", $vmName `
    -replace "#vnetname#", $solutionNwName `
    -replace "#subnetname#", $solutionSubnetName `
    -replace "#adminusername#", $userName `
    -replace "#keyvaultname#", $keyVaultName `
    -replace "#keyvaultresourcegroup#", $ResourceGroupName `
    -replace "#aadClientID#", $aadClientId `
    -replace "#aadClientSecret#", $aadClientSecret ) | `
    Out-File $tempParameterFile
.\Deploy-AzureResourceGroup.ps1 `
    -ResourceGroupLocation $Location `
    -ResourceGroupName $ResourceGroupName `
    -UploadArtifacts `
    -StorageAccountName $DeployStorageAccount `
    -TemplateFile .\templates\azuredeploy.standalone-vm-with-32-disks.json `
    -TemplateParametersFile $tempParameterFile `
    -DSCSourceFolder 'dsc-stripe-32-disks'
    
