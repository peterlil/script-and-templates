
# Make up your own secret
$aadClientSecret = "YourJediMindTricksDon'tWorkOnMe"

#Give the application a name
$AppName = "VmCreatorAppHackathon2017"


# Create the AAD application and a service principal that the application can use to access Key Vault.
$azureAdApplication = New-AzureRmADApplication -DisplayName $AppName -HomePage "https://$($AppName)/" -IdentifierUris "https://$($AppName)" -Password $aadClientSecret
$servicePrincipal = New-AzureRmADServicePrincipal –ApplicationId $azureAdApplication.ApplicationId

Write-Host "Application ID:$($azureAdApplication.ApplicationId)"
Write-Host "Client Secret: $($aadClientSecret)"

#Set up the key vault access policy for the Azure AD application
$keyVaultName = 'HackathonKeyVault8998'
$aadClientID = $azureAdApplication.ApplicationId
$rgname = 'RG-Shared'
Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ServicePrincipalName $aadClientID -PermissionsToKeys 'WrapKey' -PermissionsToSecrets 'Set' -ResourceGroupName $rgname

# Encrypt the VM
$vmName = 'hackathonVm1'
$KeyVault = Get-AzureRmKeyVault -VaultName $KeyVaultName -ResourceGroupName $rgname;
$diskEncryptionKeyVaultUrl = $KeyVault.VaultUri;
$KeyVaultResourceId = $KeyVault.ResourceId;
$rgname = 'RG-Workloads'
Set-AzureRmVMDiskEncryptionExtension -ResourceGroupName $rgname -VMName $vmName -AadClientID $aadClientID -AadClientSecret $aadClientSecret -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl -DiskEncryptionKeyVaultId $KeyVaultResourceId -Force
