
# Make up your own secret
$aadClientSecret = "YourJediMindTricksDon'tWorkOnMe"

#Give the application a name
$AppName = "VmCreatorAppHackathon2017"


# Create the AAD application and a service principal that the application can use to access Key Vault.
$azureAdApplication = New-AzureRmADApplication -DisplayName $AppName -HomePage "https://$($AppName)/" -IdentifierUris "https://$($AppName)" -Password $aadClientSecret
$servicePrincipal = New-AzureRmADServicePrincipal –ApplicationId $azureAdApplication.ApplicationId

Write-Host "Application ID: $($azureAdApplication.ApplicationId)"
Write-Host "Client Secret: $($aadClientSecret)"

#Application ID: fd190491-a117-4e72-a0df-4bad6a652154
#Client Secret: YourJediMindTricksDon'tWorkOnMe

#Set up the key vault access policy for the Azure AD application
$keyVaultName = 'HackathonKeyVault8998'
$aadClientID = $azureAdApplication.ApplicationId
$rgname = 'RG-Shared'
Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ServicePrincipalName $aadClientID -PermissionsToKeys 'WrapKey' -PermissionsToSecrets 'Set' -ResourceGroupName $rgname

# Set up an encryption key if one does not exists.
$vmEncryptionKeyName = 'VmEncryptionKey'
$keyVaultKey = Get-AzureKeyVaultKey -VaultName $keyVaultName -Name $vmEncryptionKeyName
if( !$keyVaultKey )
{
	Write-Host 'Creating KeyVault key.'
	$keyVaultKey = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name $vmEncryptionKeyName -Destination Software
}


# Encrypt the VM
$vmName = 'hackathonVm1'
$KeyVault = Get-AzureRmKeyVault -VaultName $KeyVaultName -ResourceGroupName $rgname;
$diskEncryptionKeyVaultUrl = $KeyVault.VaultUri;
$KeyVaultResourceId = $KeyVault.ResourceId;
$rgname = 'RG-Workloads'
Set-AzureRmVMDiskEncryptionExtension -ResourceGroupName $rgname -VMName $vmName `
    -AadClientID $aadClientID -AadClientSecret $aadClientSecret `
    -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl `
    -DiskEncryptionKeyVaultId $KeyVaultResourceId -VolumeType All -Force

Get-AzureRmVMDiskEncryptionStatus -ResourceGroupName $rgName -VMName $vmName