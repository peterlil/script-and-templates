
Login-Pat

$Location = 'North Europe'
$ResourceGroupName = 'TestNE1'
$DeployStorageAccount = 'peterlildeployne'
$aadClientSecret = '4raXaxqqeok8DruPrz7RuzREzubR3cut'
$aadAppDisplayName = "app-for-vm-encryption-$ResourceGroupName"
$vmEncryptionKeyName = 'vm-encryption-key'
$aadClientId = ''
$aadServicePrincipalId = ''
$currentUserObjectId = ''
$vmName = 'vm2'
$keyVaultName = 'testkvwe'


Set-Location c:\src\github\peterlil\script-and-templates 
#Get hold of the JSON parameters
$SolutionNetworkParams = ((Get-Content -Raw .\templates\azuredeploy.solution-network.parameters.json) | ConvertFrom-Json)
$solutionNwName = $SolutionNetworkParams.parameters.solutionNwName.value
$solutionSubnetName = $SolutionNetworkParams.parameters.solutionNwSubnet3Name.value

# Get the ObjectId of current user
$Sessions = Get-PSSession | Where-Object { $_.ConfigurationName -eq 'Microsoft.Exchange'}
$cred = Get-Credential
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


# Create a virtual network for a solution
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation $Location -ResourceGroupName $ResourceGroupName `
    -StorageAccountName $DeployStorageAccount -TemplateFile .\templates\azuredeploy.solution-network.json `
    -TemplateParametersFile .\templates\azuredeploy.solution-network.parameters.json


# Deploy a keyvault, first prepare the parameter file by replacing #keyvaultname# and #objectIdOfUser# with appropriate values
$tempParameterFile = [System.IO.Path]::GetTempFileName()
((Get-Content -Path .\templates\azuredeploy.keyvault.parameters.json) -replace "#keyvaultname#", $keyVaultName) `
    -replace "#objectIdOfUser#", $currentUserObjectId | `
    Out-File $tempParameterFile

.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation $Location -ResourceGroupName $ResourceGroupName `
    -StorageAccountName $DeployStorageAccount -TemplateFile .\templates\azuredeploy.keyvault.json `
    -TemplateParametersFile $tempParameterFile

# Prepare a keyvault for vm disk encryption
.\templates\vm-encryption-preparation.ps1 -aadClientSecret $aadClientSecret -keyVaultName $keyVaultName `
    -keyVaultResourceGroupName $ResourceGroupName -vmEncryptionKeyName $vmEncryptionKeyName `
    -appDisplayName $aadAppDisplayName -aadClientId ([ref]$aadClientId) -aadServicePrincipalId ([ref]$aadServicePrincipalId)

# Deploy a VM
$userName = Read-Host 'Type admin user name:'
$tempParameterFile = [System.IO.Path]::GetTempFileName()
((Get-Content -Path .\templates\azuredeploy.standalone-vm.parameters.json) `
    -replace "#vmname#", $vmName `
    -replace "#vnetname#", $solutionNwName `
    -replace "#subnetname#", $solutionSubnetName `
    -replace "#adminusername#", $userName `
    -replace "#keyvaultname#", $keyVaultName) `
    -replace "#keyvaultresourcegroup#", $ResourceGroupName `
    -replace "#aadClientID#", $aadClientId `
    -replace "#aadClientSecret#", $aadClientSecret | `
    Out-File $tempParameterFile
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation $Location -ResourceGroupName $ResourceGroupName `
    -TemplateFile .\templates\azuredeploy.standalone-vm.json -TemplateParametersFile $tempParameterFile 
    
    
    `
    -DSCSourceFolder .\DSC

-UploadArtifacts -StorageAccountName $DeployStorageAccount -StorageContainerName "$($DeployStorageAccount)-stageartifacts" `
    
